class Lzo < Formula
  revision 100
  desc "Real-time data compression library"
  homepage "http://www.oberhumer.com/opensource/lzo/"
  url "http://www.oberhumer.com/opensource/lzo/download/lzo-2.09.tar.gz"
  sha256 "f294a7ced313063c057c504257f437c8335c41bfeed23531ee4e6a2b87bcb34c"

  bottle do
    root_url "https://f002.backblazeb2.com/file/bottles"
    cellar :any
    sha1 "487d75311ac77d0292dccce970189818af484689" => :leopard_g5
    sha1 "bf8e39f23416b654dff977434298a5ba530c3ab0" => :tiger_g4e
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
