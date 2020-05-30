class PkgConfig < Formula
  revision 100
  desc "Manage compile and link flags for libraries"
  homepage "https://freedesktop.org/wiki/Software/pkg-config/"
  url "https://pkgconfig.freedesktop.org/releases/pkg-config-0.29.1.tar.gz"
  mirror "https://fossies.org/linux/misc/pkg-config-0.29.1.tar.gz"
  sha256 "beb43c9e064555469bd4390dcfd8030b1536e0aa103f08d7abf7ae8cac0cb001"

  bottle do
    root_url "https://f002.backblazeb2.com/file/bottles"
    sha256 "b977271fb6dc00bdcbdb9130040c47bf65c3291da453313c1027caebfd52c452" => :leopard_g5
    sha256 "2ac7c880f64d54c238c3bd3f84981883a0536e7e3df842102cfa49d58ba14705" => :tiger_g4e
    sha256 "8b0640de392b661a8efd16675f68f6d06430209ffd308783418616681fc738dd" => :tiger_g3
  end

  def install
    pc_path = %W[
      #{HOMEBREW_PREFIX}/lib/pkgconfig
      #{HOMEBREW_PREFIX}/share/pkgconfig
      /usr/local/lib/pkgconfig
      /usr/lib/pkgconfig
      #{HOMEBREW_LIBRARY}/ENV/pkgconfig/#{MacOS.version}
    ].uniq.join(File::PATH_SEPARATOR)

    ENV.append "LDFLAGS", "-framework Foundation -framework Cocoa"
    system "./configure", "--disable-debug",
                          "--prefix=#{prefix}",
                          "--disable-host-tool",
                          "--with-internal-glib",
                          "--with-pc-path=#{pc_path}"
    system "make"
    system "make", "check"
    system "make", "install"
  end

  test do
    system "#{bin}/pkg-config", "--libs", "openssl"
  end
end
