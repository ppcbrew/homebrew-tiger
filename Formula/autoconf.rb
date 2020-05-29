class Autoconf < Formula
  revision 100
  desc "Automatic configure script builder"
  homepage "https://www.gnu.org/software/autoconf"
  url "http://ftpmirror.gnu.org/autoconf/autoconf-2.69.tar.gz"
  mirror "https://ftp.gnu.org/gnu/autoconf/autoconf-2.69.tar.gz"
  sha256 "954bd69b391edc12d6a4a51a2dd1476543da5c6bbf05a95b59dc0dd6fd4c2969"

  bottle do
    cellar :any_skip_relocation
    root_url "https://f002.backblazeb2.com/file/bottles"
    sha1 "fc75a2a472bf482c3377e0eada0c00a33a7a018a" => :leopard_g5
    sha1 "33132bfb75fa73915ada07383e168a4d84bc41a3" => :tiger_g4e
    sha1 "df5b222b44056aca218538809d50fc8e2cc5da90" => :tiger_g3
  end

  # Tiger's m4 is too old.
  depends_on "ppcbrew/tiger/m4" if MacOS.version == :tiger

  keg_only :provided_until_xcode43

  def install
    ENV["PERL"] = "/usr/bin/perl"

    # force autoreconf to look for and use our glibtoolize
    inreplace "bin/autoreconf.in", "libtoolize", "glibtoolize"
    # also touch the man page so that it isn't rebuilt
    inreplace "man/autoreconf.1", "libtoolize", "glibtoolize"

    system "./configure", "--prefix=#{prefix}",
           "--with-lispdir=#{share}/emacs/site-lisp/autoconf"
    system "make", "install"

    rm_f info/"standards.info"
  end

  test do
    cp "#{share}/autoconf/autotest/autotest.m4", "autotest.m4"
    system "#{bin}/autoconf", "autotest.m4"
  end
end
