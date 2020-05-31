class Isl < Formula
  revision 100
  desc "Integer Set Library for the polyhedral model"
  homepage "https://isl.gforge.inria.fr/"
  # Note: Always use tarball instead of git tag for stable version.
  #
  # Currently isl detects its version using source code directory name
  # and update isl_version() function accordingly.  All other names will
  # result in isl_version() function returning "UNKNOWN" and hence break
  # package detection.
  url "http://isl.gforge.inria.fr/isl-0.22.1.tar.xz"
  mirror "https://deb.debian.org/debian/pool/main/i/isl/isl_0.22.1.orig.tar.xz"
  sha256 "28658ce0f0bdb95b51fd2eb15df24211c53284f6ca2ac5e897acc3169e55b60f"

  bottle do
    cellar :any
    sha256 "083ad48b8160497de656d935212c5672de64c72b839208a4003ed2c93d52f8c3" => :leopard_g5
    root_url "https://f002.backblazeb2.com/file/bottles"
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
