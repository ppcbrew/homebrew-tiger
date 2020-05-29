class Lzo < Formula
  revision 100
  desc "Real-time data compression library"
  homepage "http://www.oberhumer.com/opensource/lzo/"
  url "http://www.oberhumer.com/opensource/lzo/download/lzo-2.10.tar.gz"
  sha1 "4924676a9bae5db58ef129dc1cebce3baa3c4b5d"

  bottle do
    root_url "https://f002.backblazeb2.com/file/bottles"
    cellar :any
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
