class Pcre < Formula
  revision 100
  desc "Perl compatible regular expressions library"
  homepage "https://www.pcre.org/"
  url "https://ftp.pcre.org/pub/pcre/pcre-8.44.tar.bz2"
  mirror "https://www.mirrorservice.org/sites/ftp.exim.org/pub/pcre/pcre-8.44.tar.bz2"
  sha256 "19108658b23b3ec5058edc9f66ac545ea19f9537234be1ec62b714c84399366d"

  bottle do
    cellar :any
    sha256 "e32e9ff692220a2a65ccf91e031bcc43764867eb442f0a370c6d70ef2cb79331" => :leopard_g5
    sha256 "e32d2aa256ce702c0063644c3020b96a1769ab8b183080a97f379ba2a41f868a" => :tiger_g4e
    sha256 "fcfc90609038942ef8e4df21aad09c9af2cf8c447afe0e20409a5096e78d059e" => :tiger_g3
    root_url "https://f002.backblazeb2.com/file/bottles"
  end

  head do
    url "svn://vcs.exim.org/pcre/code/trunk"

    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool" => :build
  end

  #uses_from_macos "bzip2"
  #uses_from_macos "zlib"

  def install
    args = %W[
      --disable-dependency-tracking
      --prefix=#{prefix}
      --enable-utf8
      --enable-pcre8
      --enable-pcre16
      --enable-pcre32
      --enable-unicode-properties
      --enable-pcregrep-libz
      --enable-pcregrep-libbz2
    ]
    #args << "--enable-jit" if MacOS.version >= :sierra
    # Previously, jit was broken on ppc.  It seems to pass the tests now,
    # but I'll err on the conservative side as I haven't tested thoroughly.
    args << "--disable-jit"

    system "./autogen.sh" if build.head?
    system "./configure", *args
    system "make"
    ENV.deparallelize
    system "make", "test"
    system "make", "install"
  end

  test do
    system "#{bin}/pcregrep", "regular expression", "#{prefix}/README"
  end
end
