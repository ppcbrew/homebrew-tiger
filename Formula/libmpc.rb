class Libmpc < Formula
  revision 100
  desc "C library for the arithmetic of high precision complex numbers"
  homepage "http://multiprecision.org"
  url "https://ftp.gnu.org/gnu/mpc/mpc-1.1.0.tar.gz"
  sha256 "6985c538143c1208dcb1ac42cedad6ff52e267b47e5f970183a3e75125b43c2e"

  bottle do
    cellar :any
    sha256 "1fb4f675e2af85e2a982a4c8a9616efd7e0648dce61c57d5b3b02d6102f1625e" => :leopard_g5
    sha256 "fc03bd41274dda152c5e8ab79d3716d740821c7874493bb28b1400a192ce18f2" => :tiger_g4e
    sha256 "a3fe27788dcf358b368d5e1ca704697978d72be7d3275ec96057579837b8e563" => :tiger_g3
    root_url "https://f002.backblazeb2.com/file/bottles"
  end

  depends_on "ppcbrew/tiger/gmp"
  depends_on "ppcbrew/tiger/mpfr"

  def install
    args = %W[
      --prefix=#{prefix}
      --disable-dependency-tracking
      --with-gmp=#{Formula["gmp"].opt_prefix}
      --with-mpfr=#{Formula["mpfr"].opt_prefix}
    ]
  
    system "./configure", *args
    system "make"
    system "make", "check"
    system "make", "install"
  end

  test do
    (testpath/"test.c").write <<-EOS.undent
      #include <mpc.h>
      #include <assert.h>
      #include <math.h>

      int main() {
        mpc_t x;
        mpc_init2 (x, 256);
        mpc_set_d_d (x, 1., INFINITY, MPC_RNDNN);
        mpc_tanh (x, x, MPC_RNDNN);
        assert (mpfr_nan_p (mpc_realref (x)) && mpfr_nan_p (mpc_imagref (x)));
        mpc_clear (x);
        return 0;
      }
    EOS
    system ENV.cc, "test.c", "-L#{lib}", "-L#{Formula["mpfr"].opt_lib}",
                   "-L#{Formula["gmp"].opt_lib}", "-lmpc", "-lmpfr",
                   "-lgmp", "-o", "test"
    system "./test"
  end
end
