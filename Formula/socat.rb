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
    sha256 "03d94e9a300bc01ae9acc25f9249f081f67ea8bf7d4cf0ff4026fd5a3b9ac00b" => :tiger_g4e
    sha256 "edede92c8412ec7931a889fcf3975a5c966138bd7a5407d403535b81b13ceb18" => :tiger_g3
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
