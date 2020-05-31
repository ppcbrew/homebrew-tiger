class Sqlite < Formula
  revision 100
  desc "Command-line interface for SQLite"
  homepage "https://sqlite.org/"
  url "https://sqlite.org/2020/sqlite-autoconf-3310100.tar.gz"
  version "3.31.1"
  sha256 "62284efebc05a76f909c580ffa5c008a7d22a1287285d68b7825a2b6b51949ae"

  bottle do
    cellar :any
    root_url "https://f002.backblazeb2.com/file/bottles"
    sha256 "16ccdad06ab52cddf6ff2b8fc6d2d43788322821edaff256d2ade0eef366d36d" => :tiger_g4e
    sha256 "bd7abef3cac0479e7a1ae44a9d43c34ddca1cb9b4f65b6348dee5da5fee1d477" => :tiger_g3
    sha256 "7c81c569c0d044d5a938fa3c034e7512e4bec628c577a6a598391f6eeb686a9d" => :leopard_g5
  end

  #keg_only :provided_by_macos
  keg_only :provided_by_osx

  depends_on "ppcbrew/tiger/readline"

  #uses_from_macos "zlib"

  def install
    ENV.append "CPPFLAGS", "-DSQLITE_ENABLE_COLUMN_METADATA=1"
    # Default value of MAX_VARIABLE_NUMBER is 999 which is too low for many
    # applications. Set to 250000 (Same value used in Debian and Ubuntu).
    ENV.append "CPPFLAGS", "-DSQLITE_MAX_VARIABLE_NUMBER=250000"
    ENV.append "CPPFLAGS", "-DSQLITE_ENABLE_RTREE=1"
    ENV.append "CPPFLAGS", "-DSQLITE_ENABLE_FTS3=1 -DSQLITE_ENABLE_FTS3_PARENTHESIS=1"
    ENV.append "CPPFLAGS", "-DSQLITE_ENABLE_JSON1=1"

    args = %W[
      --prefix=#{prefix}
      --disable-dependency-tracking
      --enable-dynamic-extensions
      --enable-readline
      --disable-editline
      --enable-session
    ]

    system "./configure", *args
    system "make", "install"
  end

  test do
    path = testpath/"school.sql"
    path.write <<~EOS
      create table students (name text, age integer);
      insert into students (name, age) values ('Bob', 14);
      insert into students (name, age) values ('Sue', 12);
      insert into students (name, age) values ('Tim', 13);
      select name from students order by age asc;
    EOS

    names = shell_output("#{bin}/sqlite3 < #{path}").strip.split("\n")
    assert_equal %w[Sue Tim Bob], names
  end
end
