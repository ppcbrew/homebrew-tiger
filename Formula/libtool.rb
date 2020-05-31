# Xcode 4.3 provides the Apple libtool.
# This is not the same so as a result we must install this as glibtool.

class Libtool < Formula
  revision 100
  desc "Generic library support script"
  homepage "https://www.gnu.org/software/libtool/"
  url "http://ftpmirror.gnu.org/libtool/libtool-2.4.6.tar.xz"
  mirror "https://ftp.gnu.org/gnu/libtool/libtool-2.4.6.tar.xz"
  sha256 "7c87a8c2c8c0fc9cd5019e402bed4292462d00a718a7cd5f11218153bf28b26f"

  bottle do
    cellar :any
    root_url "https://f002.backblazeb2.com/file/bottles"
    sha256 "72db135cfc5d6b01fc800d7ead57627cc449f9f902a5a6a33c424ee4de623567" => :leopard_g5
    sha256 "3ef3dc19be0cabbf61e6d7ea5128b01f5556720b119e9ebb4ad98edf3e6233b9" => :tiger_g3
    sha256 "288b98d2879792fdac085cdde081e6c6fb230196a9fc7836b33f856e091dfe7f" => :tiger_g4e
  end

  depends_on "ppcbrew/tiger/m4" if MacOS.version < :leopard

  keg_only :provided_until_xcode43

  option :universal

  def install
    ENV.universal_binary if build.universal?
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--program-prefix=g",
                          "--enable-ltdl-install"
    system "make", "install"
  end

  def caveats; <<-EOS.undent
    In order to prevent conflicts with Apple's own libtool we have prepended a "g"
    so, you have instead: glibtool and glibtoolize.
    EOS
  end

  test do
    system "#{bin}/glibtool", "execute", "/usr/bin/true"
  end
end
