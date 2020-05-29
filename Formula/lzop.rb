class Lzop < Formula
  revision 100
  desc "File compressor"
  homepage "http://www.lzop.org/"
  url "http://www.lzop.org/download/lzop-1.03.tar.gz"
  sha256 "c1425b8c77d49f5a679d5a126c90ea6ad99585a55e335a613cae59e909dbb2c9"

  bottle do
    cellar :any
    root_url "https://f002.backblazeb2.com/file/bottles"
    sha1 "94f89f47047a1a1b3ba7f26d6b973f22596e6ca6" => :leopard_g5
    sha1 "8c6e99632e4edf599d9e7564a2a5806c504dcba6" => :tiger_g4e
    sha1 "ff427a1ef5e442bf34a2da0ff0bd66daec7751e5" => :tiger_g3
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
