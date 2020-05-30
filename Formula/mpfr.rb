class Mpfr < Formula
  revision 100
  desc "C library for multiple-precision floating-point computations"
  homepage "http://www.mpfr.org/"
  url "https://ftp.gnu.org/gnu/mpfr/mpfr-3.1.6.tar.xz"
  mirror "https://ftpmirror.gnu.org/mpfr/mpfr-3.1.6.tar.xz"
  sha256 "7a62ac1a04408614fccdc506e4844b10cf0ad2c2b1677097f8f35d3a1344a950"

  bottle do
    cellar :any
    root_url "https://f002.backblazeb2.com/file/bottles"
    sha256 "373df94d524c50c7b4fa15200f8991a43f729d1ffd4f76f2c449fd898f974497" => :leopard_g5
    sha1 "c4da2628bbb3cff6dc9449875a22b26e477106ff" => :tiger_g4e
    sha1 "4c8cd711ba13659788a8983ac59f912b5a8e46b3" => :tiger_g3
  end

  option "32-bit"

  depends_on "ppcbrew/tiger/gmp"

  fails_with :clang do
    build 421
    cause <<-EOS.undent
      clang build 421 segfaults while building in superenv;
      see https://github.com/Homebrew/homebrew/issues/15061
      EOS
  end

  def install
    ENV.m32 if build.build_32_bit?
    system "./configure", "--disable-dependency-tracking", "--prefix=#{prefix}",
                          "--disable-silent-rules"
    system "make"
    system "make", "check"
    system "make", "install"
  end

  test do
    (testpath/"test.c").write <<-EOS.undent
      #include <gmp.h>
      #include <mpfr.h>

      int main()
      {
        mpfr_t x;
        mpfr_init(x);
        mpfr_clear(x);
        return 0;
      }
    EOS
    system ENV.cc, "test.c", "-lgmp", "-lmpfr", "-o", "test"
    system "./test"
  end
end
