class Lzo < Formula
  revision 100
  desc "Real-time data compression library"
  homepage "http://www.oberhumer.com/opensource/lzo/"
  url "http://www.oberhumer.com/opensource/lzo/download/lzo-2.09.tar.gz"
  sha256 "f294a7ced313063c057c504257f437c8335c41bfeed23531ee4e6a2b87bcb34c"

  bottle do
    root_url "https://f002.backblazeb2.com/file/bottles"
    cellar :any
    sha1 "a0898f7d631ef265a1816ad82482240ae30f9f39" => :tiger_g4e
    sha1 "10ba16988ed42546f96fe4cfbeb4ef86cbdc451d" => :leopard_g5
  end

  def install
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--enable-shared"
    system "make"
    system "make", "check"
    system "make", "install"
  end
end
