class Perl < Formula
  revision 100
  desc "Highly capable, feature-rich programming language"
  homepage "https://www.perl.org/"
  url "http://www.cpan.org/src/5.0/perl-5.22.0.tar.xz"
  mirror "https://mirrors.kernel.org/debian/pool/main/p/perl/perl_5.22.0.orig.tar.xz"
  sha256 "be83ead0c5c26cbbe626fa4bac1a4beabe23a9eebc15d35ba49ccde11878e196"

  head "https://perl5.git.perl.org/perl.git", :branch => "blead"

  bottle do
    root_url "https://f002.backblazeb2.com/file/bottles"
  end

  keg_only :provided_by_osx,
    "OS X ships Perl and overriding that can cause unintended issues"

  option "with-dtrace", "Build with DTrace probes"
  option "with-tests", "Build and run the test suite"

  def install
    args = [
      "-des",
      "-Dprefix=#{prefix}",
      "-Dman1dir=#{man1}",
      "-Dman3dir=#{man3}",
      "-Duseshrplib",
      "-Duselargefiles",
      "-Dusethreads",
      "-Dcc='#{ENV.cc}'",
      "-Doptimize='-Os'"
    ]

    args << "-Dusedtrace" if build.with? "dtrace"
    args << "-Dusedevel" if build.head?

    system "./Configure", *args
    system "make"
    system "make", "test" if build.with?("tests") || build.bottle?
    system "make", "install"
  end

  def caveats; <<-EOS.undent
    By default Perl installs modules in your HOME dir. If this is an issue run:
      `#{bin}/cpan o conf init`
    EOS
  end

  test do
    (testpath/"test.pl").write "print 'Perl is not an acronym, but JAPH is a Perl acronym!';"
    system "#{bin}/perl", "test.pl"
  end
end
