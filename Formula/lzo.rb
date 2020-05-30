class Lzo < Formula
  revision 100
  desc "Real-time data compression library"
  homepage "http://www.oberhumer.com/opensource/lzo/"
  url "http://www.oberhumer.com/opensource/lzo/download/lzo-2.10.tar.gz"
  sha1 "4924676a9bae5db58ef129dc1cebce3baa3c4b5d"

  bottle do
    root_url "https://f002.backblazeb2.com/file/bottles"
    cellar :any
    sha256 "971830f43654a3d83952bf137acd8114b2db2edd7cc6d77e7718bafb0c2285df" => :leopard_g5
    sha256 "6405713494d647ebe3baa900f8da5067f3b36855d23cc5229023a9df0ad98536" => :tiger_g4e
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
