class Pv < Formula
  revision 100
  desc "Monitor data's progress through a pipe"
  homepage "https://www.ivarch.com/programs/pv.shtml"
  url "https://www.ivarch.com/programs/sources/pv-1.6.0.tar.bz2"
  sha256 "0ece824e0da27b384d11d1de371f20cafac465e038041adab57fcf4b5036ef8d"

  bottle do
    cellar :any_skip_relocation
    root_url "https://f002.backblazeb2.com/file/bottles"
    sha256 "aae5bb02b17ca3865ffeedd5069dfc235703dd5dd85ce2c0bf5db6b086a80936" => :leopard_g5
    sha256 "b6308c8f7208e259b2d7af7b4aa301c25833e84552d26d95421b990623ace02a" => :tiger_g4e
    sha256 "8cea9a7ba750ffea7a9322ab0c6bd3ed4e3e4de7c34a5c20511923f825ec152f" => :tiger_g3
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
