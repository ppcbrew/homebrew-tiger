class Readline < Formula
  revision 100
  desc "Library for command-line editing"
  homepage "https://tiswww.case.edu/php/chet/readline/rltop.html"
  url "https://ftp.gnu.org/gnu/readline/readline-8.0.tar.gz"
  mirror "https://ftpmirror.gnu.org/readline/readline-8.0.tar.gz"
  version "8.0.4"
  sha256 "e339f51971478d369f8a053a330a190781acb9864cf4c541060f12078948e461"

  %w[
    001 d8e5e98933cf5756f862243c0601cb69d3667bb33f2c7b751fe4e40b2c3fd069
    002 36b0febff1e560091ae7476026921f31b6d1dd4c918dcb7b741aa2dad1aec8f7
    003 94ddb2210b71eb5389c7756865d60e343666dfb722c85892f8226b26bb3eeaef
    004 b1aa3d2a40eee2dea9708229740742e649c32bb8db13535ea78f8ac15377394c
  ].each_slice(2) do |p, checksum|
    patch :p0 do
      url "https://ftp.gnu.org/gnu/readline/readline-8.0-patches/readline80-#{p}"
      mirror "https://ftpmirror.gnu.org/readline/readline-8.0-patches/readline80-#{p}"
      sha256 checksum
    end
  end

  bottle do
    cellar :any
    sha256 "bf4926a7da97e41e87eafed4c89793b2ba3d5d02fd66e9eea58c7240b629f7c9" => :tiger_g3
    sha256 "95b9ba6e9b8325b3002a246c0bf236a69f0a97fa8e913ffdb584b9376795f3b2" => :tiger_g4e
    root_url "https://f002.backblazeb2.com/file/bottles"
  end

  keg_only :shadowed_by_osx, <<-EOS.undent
    OS X provides the BSD libedit library, which shadows libreadline.
    In order to prevent conflicts when programs look for libreadline we are
    defaulting this GNU Readline installation to keg-only.
  EOS

  def install
    system "./configure", "--prefix=#{prefix}", "--enable-multibyte"
    # There is no termcap.pc in the base system, so we have to comment out
    # the corresponding Requires.private line.
    # Otherwise, pkg-config will consider the readline module unusable.
    inreplace "readline.pc", /^(Requires.private: .*)$/, "# \\1"
    system "make", "install"
  end

  test do
    (testpath/"test.c").write <<-EOS.undent
      #include <stdio.h>
      #include <stdlib.h>
      #include <readline/readline.h>

      int main()
      {
        printf("%s\\n", readline("test> "));
        return 0;
      }
    EOS
    system ENV.cc, "test.c", "-lreadline", "-o", "test"
    assert_equal "Hello, World!", pipe_output("./test", "Hello, World!\n").strip
  end
end
