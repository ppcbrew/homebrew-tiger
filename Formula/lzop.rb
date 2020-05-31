class Lzop < Formula
  revision 100
  desc "File compressor"
  homepage "http://www.lzop.org/"
  url "http://www.lzop.org/download/lzop-1.04.tar.gz"
  sha1 "3540761ce8fc6dc42c326a9fcb1471e190a4db62"

  bottle do
    cellar :any
    root_url "https://f002.backblazeb2.com/file/bottles"
    sha256 "393df3029b79f1ea67d8451568923fdc125224e1642dc57d6e3c9ef677dd2679" => :leopard_g5
    sha256 "a77ea6ff9b8e80c1b932a0bb5697b0f234733df7cd78dc20ff93f35e88bc31c2" => :tiger_g3
    sha256 "cb9a2b8daa757420e11090c7ea8457dc098c722b7af50a665784f25fd2cd6e28" => :tiger_g4e
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
