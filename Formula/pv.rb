class Pv < Formula
  revision 100
  desc "Monitor data's progress through a pipe"
  homepage "https://www.ivarch.com/programs/pv.shtml"
  url "https://www.ivarch.com/programs/sources/pv-1.6.0.tar.bz2"
  sha256 "0ece824e0da27b384d11d1de371f20cafac465e038041adab57fcf4b5036ef8d"

  bottle do
    cellar :any_skip_relocation
    root_url "https://f002.backblazeb2.com/file/bottles"
    sha1 "808916d1f2ceb0adb6001d0033fe8a6b3adcca24" => :leopard_g5
    sha1 "b0f41a36478f6a8ca948cd312f54a9a1a7d2c898" => :tiger_g4e
  end

  option "with-gettext", "Build with Native Language Support"

  depends_on "gettext" => :optional

  fails_with :llvm do
    build 2334
  end

  def install
    args = %W[
      --disable-debug
      --prefix=#{prefix}
      --mandir=#{man}
    ]

    args << "--disable-nls" if build.without? "gettext"

    system "./configure", *args
    system "make", "install"
  end

  test do
    progress = pipe_output("#{bin}/pv -ns 4 2>&1 >/dev/null", "beer")
    assert_equal "100", progress.strip
  end
end
