class Pcre < Formula
  revision 100
  desc "Perl compatible regular expressions library"
  homepage "https://www.pcre.org/"
  url "https://ftp.pcre.org/pub/pcre/pcre-8.44.tar.bz2"
  mirror "https://www.mirrorservice.org/sites/ftp.exim.org/pub/pcre/pcre-8.44.tar.bz2"
  sha256 "19108658b23b3ec5058edc9f66ac545ea19f9537234be1ec62b714c84399366d"

  bottle do
    cellar :any
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
