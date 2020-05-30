class Isl < Formula
  revision 100
  desc "Integer Set Library for the polyhedral model"
  homepage "http://freecode.com/projects/isl"
  # Note: Always use tarball instead of git tag for stable version.
  #
  # Currently isl detects its version using source code directory name
  # and update isl_version() function accordingly.  All other names will
  # result in isl_version() function returning "UNKNOWN" and hence break
  # package detection.
  url "http://isl.gforge.inria.fr/isl-0.18.tar.xz"
  mirror "https://mirrors.ocf.berkeley.edu/debian/pool/main/i/isl/isl_0.18.orig.tar.xz"
  sha256 "0f35051cc030b87c673ac1f187de40e386a1482a0cfdf2c552dd6031b307ddc4"

  bottle do
    cellar :any
    root_url "https://f002.backblazeb2.com/file/bottles"
    sha256 "add1db8b2596927050f0ef061df5c9a501a47f94b6113dc360295ac6b7838111" => :leopard_g5
    sha256 "fc716bf9078612a7211df0100dc2b0df2a6e2ce5c72fb61ebea9cc33b76c09f1" => :tiger_g4e
    sha256 "fe8a42dc3254c58f8c54f01f83a4bb785c82b5dacea336a1c1a9c9466b04bd93" => :tiger_g3
  end

  head do
    url "http://repo.or.cz/r/isl.git"

    depends_on "ppcbrew/tiger/autoconf" => :build
    depends_on "ppcbrew/tiger/automake" => :build
    depends_on "ppcbrew/tiger/libtool" => :build
  end

  depends_on "ppcbrew/tiger/gmp"

  def install
    system "./autogen.sh" if build.head?
    system "./configure", "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--prefix=#{prefix}",
                          "--with-gmp=system",
                          "--with-gmp-prefix=#{Formula["gmp"].opt_prefix}"
    system "make", "check"
    system "make", "install"
    (share/"gdb/auto-load").install Dir["#{lib}/*-gdb.py"]
  end

  test do
    (testpath/"test.c").write <<-EOS.undent
      #include <isl/ctx.h>

      int main()
      {
        isl_ctx* ctx = isl_ctx_alloc();
        isl_ctx_free(ctx);
        return 0;
      }
    EOS
    system ENV.cc, "test.c", "-L#{lib}", "-lisl", "-o", "test"
    system "./test"
  end
end
