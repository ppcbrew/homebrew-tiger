#!/usr/local/Library/Homebrew/vendor/portable-ruby/current/bin/ruby

# This script computes the sha1 hash of a file.

# This script is written for the Ruby interpreter which shipped
# with tigerbrew, see https://github.com/mistydemeo/tigerbrew.

require "digest"
sha256 = Digest::SHA256.file ARGV[0]
puts "#{sha256.hexdigest}"
