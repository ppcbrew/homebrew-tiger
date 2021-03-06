class Bash < Formula
  revision 100
  desc "Bourne-Again SHell, a UNIX command interpreter"
  homepage "https://www.gnu.org/software/bash/"
  url "https://ftpmirror.gnu.org/bash/bash-4.4.tar.gz"
  mirror "https://mirrors.ocf.berkeley.edu/gnu/bash/bash-4.4.tar.gz"
  mirror "https://mirrors.kernel.org/gnu/bash/bash-4.4.tar.gz"
  mirror "https://ftp.gnu.org/gnu/bash/bash-4.4.tar.gz"
  mirror "https://gnu.cu.be/bash/bash-4.4.tar.gz"
  mirror "https://mirror.unicorncloud.org/gnu/bash/bash-4.4.tar.gz"
  sha256 "d86b3392c1202e8ff5a423b302e6284db7f8f435ea9f39b5b1b20fd3ac36dfcb"

  head "http://git.savannah.gnu.org/r/bash.git"

  bottle do
    root_url "https://f002.backblazeb2.com/file/bottles"
    sha256 "b89656d5d52272e180a0771fb0305721799aaebedadc827c1419e3e6aa763054" => :leopard_g5
    sha256 "5b0666eae6b2d351ac5e61ba26bbb34f1c16c98f84ff1d763e8097ea4b37551d" => :tiger_g3
    sha256 "c746155fa55f40ecff6b39fc20b9e162b57224ba6151e3eadc617c54f0c16a8d" => :tiger_g4e
  end

  depends_on "ppcbrew/tiger/readline"

  def install
    # When built with SSH_SOURCE_BASHRC, bash will source ~/.bashrc when
    # it's non-interactively from sshd.  This allows the user to set
    # environment variables prior to running the command (e.g. PATH).  The
    # /bin/bash that ships with Mac OS X defines this, and without it, some
    # things (e.g. git+ssh) will break if the user sets their default shell to
    # Homebrew's bash instead of /bin/bash.
    ENV.append_to_cflags "-DSSH_SOURCE_BASHRC"

    system "./configure", "--prefix=#{prefix}"
    system "make", "install"
  end

  def caveats; <<-EOS.undent
    In order to use this build of bash as your login shell,
    it must be added to /etc/shells.
    EOS
  end

  test do
    assert_equal "hello", shell_output("#{bin}/bash -c \"echo hello\"").strip
  end
end
