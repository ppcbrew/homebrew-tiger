class Lzop < Formula
  revision 100
  desc "File compressor"
  homepage "http://www.lzop.org/"
  url "http://www.lzop.org/download/lzop-1.04.tar.gz"
  sha1 "3540761ce8fc6dc42c326a9fcb1471e190a4db62"

  bottle do
    cellar :any
    root_url "https://f002.backblazeb2.com/file/bottles"
    sha1 "9c61b313a2776908db2111cbbf8605a741cf5c46/" => :leopard_g5
    sha1 "0e4f2108ecc5a19638442ac8b3bc18781e297e42" => :tiger_g4e
  end

  depends_on "ppcbrew/tiger/lzo"

  def install
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    path = testpath/"test"
    text = "This is Homebrew"
    path.write text

    system "#{bin}/lzop", "test"
    assert File.exist?("test.lzo")
    rm path

    system "#{bin}/lzop", "-d", "test.lzo"
    assert_equal text, path.read
  end
end
