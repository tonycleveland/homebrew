class Bokken < Formula
  desc "GUI for the Pyew and Radare projects"
  homepage "https://inguma.eu/projects/bokken"
  url "https://inguma.eu/attachments/download/197/bokken-1.6.tar.gz"
  sha256 "4770602585b3e77b2977a8a6906c91ae0d64373eae328f42688106224c8bbc12"

  bottle do
    cellar :any
    sha256 "c5b0b1f7e134c37387b9ca3f15ab63c424fe1d7a1c3196c4de583feda002c4d3" => :mavericks
    sha256 "870b917d0ad42a4a38a057919946ca099c726b181abc3adf1f6a8242d981bdf4" => :mountain_lion
    sha256 "dcda9a37224afa064e78a0b9575d9e7d1f8032d5b8b44bd95b63fc0768da37c4" => :lion
  end

  depends_on :python
  depends_on "graphviz"
  depends_on "pygtk"
  depends_on "pygtksourceview"
  depends_on "radare2"

  resource "distorm64" do
    url "http://ftp.de.debian.org/debian/pool/main/d/distorm64/distorm64_1.7.30.orig.tar.gz"
    sha256 "98b218e5a436226c5fb30d3b27fcc435128b4e28557c44257ed2ba66bb1a9cf1"
  end

  resource "pyew" do
    # Upstream only provides binary packages so pull from Debian.
    url "http://ftp.de.debian.org/debian/pool/main/p/pyew/pyew_2.0.orig.tar.gz"
    sha256 "64a4dfb1850efbe2c9b06108697651f9ff25223fd132eec66c6fe84d5ecc17ae"
  end

  def install
    resource("distorm64").stage do
      cd "build/mac" do
        system "make"
        mkdir_p libexec/"distorm64"
        (libexec/"distorm64").install "libdistorm64.dylib"
        ln_s "libdistorm64.dylib", libexec/"distorm64/libdistorm64.so"
      end
    end

    resource("pyew").stage do
      (libexec/"pyew").install Dir["*"]
      # Make sure that the launcher looks for pyew.py in the correct path (fixed
      # in pyew ab9ea236335e).
      inreplace libexec/"pyew/pyew", "\./pyew.py", "`dirname $0`/pyew.py"
    end

    python_path = "#{libexec}/lib/python2.7/site-packages:#{libexec}/pyew"
    ld_library_path = "#{libexec}/distorm64"
    (libexec/"bokken").install Dir["*"]
    (bin/"bokken").write <<-EOS.undent
      #!/usr/bin/env bash
      env \
        PYTHONPATH=#{python_path}:${PYTHONPATH} \
        LD_LIBRARY_PATH=#{ld_library_path}:${LD_LIBRARY_PATH} \
        python #{libexec}/bokken/bokken.py "${@}"
    EOS
  end
end
