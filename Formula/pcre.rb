class Pcre < Formula
  revision 100
  desc "Perl compatible regular expressions library"
  homepage "http://www.pcre.org/"
  url "https://ftp.csx.cam.ac.uk/pub/software/programming/pcre/pcre-8.39.tar.bz2"
  mirror "https://www.mirrorservice.org/sites/downloads.sourceforge.net/p/pc/pcre/pcre/8.39/pcre-8.39.tar.bz2"
  sha256 "b858099f82483031ee02092711689e7245586ada49e534a06e678b8ea9549e8b"

  bottle do
    cellar :any
    root_url "https://f002.backblazeb2.com/file/bottles"
    sha1 "f822356418f90587b059f72f7be430aa6016f300" => :tiger_g4e
  end

  head do
    url "svn://vcs.exim.org/pcre/code/trunk"

    depends_on "automake" => :build
    depends_on "autoconf" => :build
    depends_on "libtool" => :build
  end

  option :universal

  # See https://github.com/mistydemeo/tigerbrew/issues/93
  fails_with :gcc do
    build 5553
    cause "One test failure on G4"
  end

  fails_with :llvm do
    build 2326
    cause "Bus error in ld on SL 10.6.4"
  end

  def install
    ENV.universal_binary if build.universal?

    args = [ "--disable-dependency-tracking",
              "--prefix=#{prefix}",
              "--enable-utf8",
              "--enable-pcre8",
              "--enable-pcre16",
              "--enable-pcre32",
              "--enable-unicode-properties",
              "--enable-pcregrep-libz",
              "--enable-pcregrep-libbz2" ]

    # JIT fails tests very badly on PPC right now
    args << "--enable-jit" unless Hardware::CPU.type == :ppc

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
