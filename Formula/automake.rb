class Automake < Formula
  revision 100
  desc "Tool for generating GNU Standards-compliant Makefiles"
  homepage "https://www.gnu.org/software/automake/"
  url "http://ftpmirror.gnu.org/automake/automake-1.15.tar.xz"
  mirror "https://ftp.gnu.org/gnu/automake/automake-1.15.tar.xz"
  sha256 "9908c75aabd49d13661d6dcb1bc382252d22cc77bf733a2d55e87f2aa2db8636"

  bottle do
    cellar :any
    root_url "https://f002.backblazeb2.com/file/bottles"
    sha1 "465d5d391aaac29f48c6ace503b06723d3269536" => :leopard_g5
    sha1 "f22c4e0c3be2cd2c115211b51c1915a61bb2e669" => :tiger_g4e
  end

  depends_on "ppcbrew/tiger/autoconf" => :run

  keg_only :provided_until_xcode43

  def install
    ENV["PERL"] = "/usr/bin/perl"

    system "./configure", "--prefix=#{prefix}"
    system "make", "install"

    # Our aclocal must go first. See:
    # https://github.com/Homebrew/homebrew/issues/10618
    (share/"aclocal/dirlist").write <<-EOS.undent
      #{HOMEBREW_PREFIX}/share/aclocal
      /usr/share/aclocal
    EOS
  end

  test do
    system "#{bin}/automake", "--version"
  end
end
