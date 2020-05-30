class Libmpc < Formula
  revision 100
  desc "C library for the arithmetic of high precision complex numbers"
  homepage "http://multiprecision.org"
  url "http://ftpmirror.gnu.org/mpc/mpc-1.0.3.tar.gz"
  mirror "http://multiprecision.org/mpc/download/mpc-1.0.3.tar.gz"
  sha256 "617decc6ea09889fb08ede330917a00b16809b8db88c29c31bfbb49cbf88ecc3"

  bottle do
    cellar :any
    root_url "https://f002.backblazeb2.com/file/bottles"
    sha256 "0cc4757372357ac5de72ca2ab5be6a90341d49b75583dd64b07f4323134603e9" => :leopard_g5
    sha1 "d9f8b7391584e5391860700f7b8e64bf540ff544" => :tiger_g4e
    sha1 "2743e39c0f33d52aa2c7d98a0297481d1d2744a4" => :tiger_g3
  end

  depends_on "ppcbrew/tiger/gmp"
  depends_on "ppcbrew/tiger/mpfr"

  def install
    args = [
      "--prefix=#{prefix}",
      "--disable-dependency-tracking",
      "--with-gmp=#{Formula["gmp"].opt_prefix}",
      "--with-mpfr=#{Formula["mpfr"].opt_prefix}"
    ]

    system "./configure", *args
    system "make"
    system "make", "check"
    system "make", "install"
  end

  test do
    (testpath/"test.c").write <<-EOS.undent
      #include <mpc.h>

      int main()
      {
        mpc_t x;
        mpc_init2 (x, 256);
        mpc_clear (x);
        return 0;
      }
    EOS
    system ENV.cc, "test.c", "-lgmp", "-lmpfr", "-lmpc", "-o", "test"
    system "./test"
  end
end
