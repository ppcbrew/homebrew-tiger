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
    sha256 "da93c14f1acef5b3360100800e525e8f2cc8f9ef598a0a370350a0223681b4b4" => :leopard_g5
    sha1 "f22c4e0c3be2cd2c115211b51c1915a61bb2e669" => :tiger_g4e
    sha1 "5b2218fdcbaf652c28360f0c3b8dd8c48e218450" => :tiger_g3
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
