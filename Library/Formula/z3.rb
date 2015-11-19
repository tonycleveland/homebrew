class Z3 < Formula
  desc "High-performance theorem prover"
  homepage "https://github.com/Z3Prover/z3"
  url "https://github.com/Z3Prover/z3/archive/z3-4.4.0.tar.gz"
  sha256 "65b72f9eb0af50949e504b47080fb3fc95f11c435633041d9a534473f3142cba"
  head "https://github.com/Z3Prover/z3.git"
  revision 1

  option "without-python", "Build without python 2 support"
  depends_on :python => :recommended if MacOS.version <= :snow_leopard
  depends_on :python3 => :optional

  if build.without?("python3") && build.without?("python")
    odie "z3: --with-python3 must be specified when using --without-python"
  end

  bottle do
    cellar :any
    revision 1
    sha256 "5478a9d85f28665ab17d0bf16e42c36cb0a0395c240a6ff02691788f06a6f81d" => :el_capitan
    sha256 "d91ef7d7bbecb962db6ab12053b3dddbcd6e8943e0ed5a5ebd572224743bcead" => :yosemite
    sha256 "f4128b503528a0825bff4da559fffe7c27f7ec3764482eb67cb69f4b89e3010e" => :mavericks
  end

  def install
    inreplace "scripts/mk_util.py", "dist-packages", "site-packages"

    Language::Python.each_python(build) do |python, version|
      system python, "scripts/mk_make.py", "--prefix=#{prefix}"
      cd "build" do
        system "make"
        system "make", "install"
      end
    end

    pkgshare.install "examples"
  end

  test do
    system ENV.cc, "-I#{include}", "-L#{lib}", "-lz3",
           pkgshare/"examples/c/test_capi.c", "-o", testpath/"test"
    system "./test"
  end
end
