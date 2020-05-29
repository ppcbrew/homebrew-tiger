class M4 < Formula
  revision 100
  desc "Macro processing language"
  homepage "https://www.gnu.org/software/m4"
  url "https://ftpmirror.gnu.org/m4/m4-1.4.18.tar.xz"
  mirror "https://ftp.gnu.org/gnu/m4/m4-1.4.18.tar.xz"
  sha256 "f2c1e86ca0a404ff281631bdc8377638992744b175afb806e25871a24a934e07"

  bottle do
    cellar :any_skip_relocation
    root_url "https://f002.backblazeb2.com/file/bottles"
    sha1 "f8a423bfae68282891db8fd4fca7eba5b9c398a8" => :leopard_g5
    sha1 "d1196ac3f0481f0b38ac592ab0a534263840f8df" => :tiger_g4e
    sha1 "a694728ed73d613e386d4fd031cdcb699925dd13" => :tiger_g3
  end

  keg_only :provided_by_osx

  def install
    system "./configure", "--disable-dependency-tracking", "--prefix=#{prefix}"
    system "make"
    system "make", "install"
  end

  test do
    assert_match "Homebrew",
      pipe_output("#{bin}/m4", "define(TEST, Homebrew)\nTEST\n")
  end
end
