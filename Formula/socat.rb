class Socat < Formula
  revision 100
  desc "netcat on steroids"
  homepage "http://www.dest-unreach.org/socat/"
  url "http://www.dest-unreach.org/socat/download/socat-1.7.3.0.tar.gz"
  sha256 "f8de4a2aaadb406a2e475d18cf3b9f29e322d4e5803d8106716a01fd4e64b186"

  bottle do
    cellar :any
    root_url "https://f002.backblazeb2.com/file/bottles"
    sha256 "3abc1c0a7db0fad00dc5d62db267dcb8e31b520c2bca9669ec9e2416b740028d" => :leopard_g5
    sha1 "ac04da217085f012bb695aac49e00ee7fcf5fd5d" => :tiger_g4e
    sha1 "28b7ad650d05284b7cbfb3c92d58acec0dc555c1" => :tiger_g3
  end

  devel do
    url "http://www.dest-unreach.org/socat/download/socat-2.0.0-b8.tar.bz2"
    sha256 "c804579db998fb697431c82829ae03e6a50f342bd41b8810332a5d0661d893ea"
    version "2.0.0-b8"
  end

  depends_on "ppcbrew/tiger/readline"
  depends_on "ppcbrew/tiger/openssl"

  def install
    ENV.enable_warnings # -w causes build to fail
    system "./configure", "--prefix=#{prefix}", "--mandir=#{man}"
    system "make", "install"
  end

  test do
    assert_match "HTTP/1.0", pipe_output("#{bin}/socat - tcp:www.google.com:80", "GET / HTTP/1.0\r\n\r\n")
  end
end
