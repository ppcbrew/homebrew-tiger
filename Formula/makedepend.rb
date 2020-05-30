class Makedepend < Formula
  revision 100
  desc "Creates dependencies in makefiles"
  homepage "http://x.org"
  url "http://xorg.freedesktop.org/releases/individual/util/makedepend-1.0.5.tar.bz2"
  sha256 "f7a80575f3724ac3d9b19eaeab802892ece7e4b0061dd6425b4b789353e25425"

  bottle do
    cellar :any
    root_url "https://f002.backblazeb2.com/file/bottles"
    sha256 "0759ba0e7cd86f108d775789611ec20c9fa115167cfd202f2650bd307a935f69" => :leopard_g5
    sha256 "d8eb1e9f79964b169848070e151217dc85f7c6224c6de2da59c48a573a964b61" => :tiger_g4e
    sha1 "d0686c523946d1abb2e39e44b41f98ceb2a5e7dd" => :tiger_g3
  end

  depends_on "ppcbrew/tiger/pkg-config" => :build

  resource "xproto" do
    url "http://xorg.freedesktop.org/releases/individual/proto/xproto-7.0.25.tar.bz2"
    sha256 "92247485dc4ffc3611384ba84136591923da857212a7dc29f4ad7797e13909fe"
  end

  resource "xorg-macros" do
    url "http://xorg.freedesktop.org/releases/individual/util/util-macros-1.18.0.tar.bz2"
    sha256 "e5e3d132a852f0576ea2cf831a9813c54a58810a59cdb198f56b884c5a78945b"
  end

  def install
    resource("xproto").stage do
      system "./configure", "--disable-dependency-tracking",
                            "--disable-silent-rules",
                            "--prefix=#{buildpath}/xproto"
      system "make", "install"
    end

    resource("xorg-macros").stage do
      system "./configure", "--prefix=#{buildpath}/xorg-macros"
      system "make", "install"
    end

    ENV.append_path "PKG_CONFIG_PATH", "#{buildpath}/xproto/lib/pkgconfig"
    ENV.append_path "PKG_CONFIG_PATH", "#{buildpath}/xorg-macros/share/pkgconfig"

    system "./configure", "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    touch "Makefile"
    system "#{bin}/makedepend"
  end
end
