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
    sha256 "46abd4ae29480940e3008300cbc37ce302c8ed2800427cf493ceaf1f9bcb87ed" => :leopard_g5
    sha256 "905cd12ed4b8dce39e2401c1a48d964f27f4634a53273fe859b3efd6eab33370" => :tiger_g4e
    sha256 "60764b4ff82933551614848d0df432f8fadde8e88405bbe12a50c2c74357773e" => :tiger_g3
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
