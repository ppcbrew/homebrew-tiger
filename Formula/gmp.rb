class Gmp < Formula
  revision 100
  desc "GNU multiple precision arithmetic library"
  homepage "https://gmplib.org/"
  url "https://gmplib.org/download/gmp/gmp-6.2.0.tar.xz"
  mirror "https://ftp.gnu.org/gnu/gmp/gmp-6.2.0.tar.xz"
  sha256 "258e6cd51b3fbdfc185c716d55f82c08aff57df0c6fbd143cf6ed561267a1526"

  bottle do
    cellar :any
    sha256 "315533367273e762e3195c49f7ae1f1354555518df590593770f8caf80d02067" => :leopard_g5
    sha256 "f735f66c516a077541e245a96e7b9ee66fe753c97daf5eed58785f6a7f5d2850" => :tiger_g4e
    sha256 "e32fc93b51affa2122859ed38b60384b9bd4fa31cc794ba6256fdf0424ea521e" => :tiger_g3
    root_url "https://f002.backblazeb2.com/file/bottles"
  end

  option "32-bit"
  option :cxx11

  def arch_to_string_map
    @arch_map ||= {
      :g3  => "powerpc750",
      :g4  => "powerpc7400",
      :g4e => "powerpc7450",
      :g5  => "powerpc970"
    }
  end

  # https://github.com/mistydemeo/tigerbrew/issues/212
  env :std

  def install
    ENV.cxx11 if build.cxx11?
    args = ["--prefix=#{prefix}", "--enable-cxx"]
    if build.bottle?
      bottle_sym = ARGV.bottle_arch || Hardware.oldest_cpu
      arch = arch_to_string_map.fetch(bottle_sym, "core2")
      args << "--build=#{arch}-apple-darwin#{`uname -r`.to_i}"
    end

    if build.build_32_bit? || !MacOS.prefer_64_bit?
      ENV.m32
      args << "ABI=32"
    end

    ENV.append_to_cflags "-force_cpusubtype_ALL" if Hardware.cpu_type == :ppc
    # https://github.com/Homebrew/homebrew/issues/20693
    args << "--disable-assembly" if build.build_32_bit? || build.bottle?

    system "./configure", "--disable-static", *args
    system "make"
    system "make", "check"
    system "make", "install"
    system "make", "clean"
    system "./configure", "--disable-shared", "--disable-assembly", *args
    system "make"
    lib.install Dir[".libs/*.a"]
  end

  test do
    (testpath/"test.c").write <<-EOS.undent
      #include <gmp.h>
      #include <stdlib.h>

      int main() {
        mpz_t i, j, k;
        mpz_init_set_str (i, "1a", 16);
        mpz_init (j);
        mpz_init (k);
        mpz_sqrtrem (j, k, i);
        if (mpz_get_si (j) != 5 || mpz_get_si (k) != 1) abort();
        return 0;
      }
    EOS
    system ENV.cc, "test.c", "-L#{lib}", "-lgmp", "-o", "test"
    system "./test"
  end
end
