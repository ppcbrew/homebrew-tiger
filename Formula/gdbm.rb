class Gdbm < Formula
  revision 100
  desc "GNU database manager"
  homepage "https://www.gnu.org/software/gdbm/"
  url "https://ftp.gnu.org/gnu/gdbm/gdbm-1.18.1.tar.gz"
  mirror "https://ftpmirror.gnu.org/gdbm/gdbm-1.18.1.tar.gz"
  sha256 "86e613527e5dba544e73208f42b78b7c022d4fa5a6d5498bf18c8d6f745b91dc"

  bottle do
    cellar :any
    sha256 "993b8b854cd32b471af9fd7deb89770067b299d918cbee681a5bc5a07b5a7599" => :leopard_g5
    sha256 "b8922d9fe603a5e421a72ecf5177095622968fbe4e2b6905f15e8af01bde9fb4" => :tiger_g4e
    sha256 "47fae80bc0752a2cce09251090ff5eb7c72e5d6e210dc6a6b93573c2d7e1e58c" => :tiger_g3
    root_url "https://f002.backblazeb2.com/file/bottles"
  end

  option "with-libgdbm-compat", "Build libgdbm_compat, a compatibility layer which provides UNIX-like dbm and ndbm interfaces."

  # Use --without-readline because readline detection is broken in 1.13
  # https://github.com/Homebrew/homebrew-core/pull/10903
  #
  # Undefined symbols:
  #   "_rl_completion_matches", referenced from:
  #       _shell_completion in input-rl.o
  #   "_history_list", referenced from:
  #       _input_history_handler in input-rl.o
  # ld: symbol(s) not found

  def install
    ENV.universal_binary if build.universal?

    args = %W[
      --disable-dependency-tracking
      --disable-silent-rules
      --without-readline
      --prefix=#{prefix}
    ]

    args << "--enable-libgdbm-compat" if build.with? "libgdbm-compat"

    system "./configure", *args
    system "make", "install"
  end

  test do
    pipe_output("#{bin}/gdbmtool --norc --newdb test", "store 1 2\nquit\n")
    assert File.exist?("test")
    assert_match /2/, pipe_output("#{bin}/gdbmtool --norc test", "fetch 1\nquit\n")
  end
end
