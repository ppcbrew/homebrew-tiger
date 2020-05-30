#!/usr/bin/python

# update-bottle-sha.py: update (or insert) the bottle sha in a formula.

# Copyright (c) 2020 Jason Pepas
# Released under the terms of the MIT License.
# See https://opensource.org/licenses/MIT

# This script is written for the Python interpreter which shipped
# with OS X Tiger (10.4), which is Python 2.3.5.

# Example usage:
# 
#   update-bottle-sha.py coreutils abc123...
#
# This would load ~/.ppcbrewbot/config to determine the tap and os_arch,
# then update the hash entry in /usr/local/Library/Taps/.../coreutils.rb.

# Given this bottle clause in a formula:
#
#  bottle do
#    cellar :any
#    root_url "https://f002.backblazeb2.com/file/bottles"
#    sha1 "2fe808acfbac4ac3bd16b17efa54f39ca3a8fc64" => :leopard_g5
#    sha1 "fe3e85e0f46f05adf9728c1905380be59cfe15b3" => :tiger_g4e
#    sha1 "02eda88a6d15e67eeafb2e2f43bdfaaa4ce88eb3" => :tiger_g3
#  end
#
# If our os_arch is tiger_g3, this script replaces the sha hash
# with the one given on the command-line.
#
# If there is no existing tiger_g3 entry, this script inserts one.

import sys
import os

def usage(fd):
    exe = os.path.basename(sys.argv[0])
    fd.write("Usage: %s <formula name> <sha hash>\n" % exe)

def load_lines(fpath):
    """Load the file from disk (as lines)."""
    fd = open(fpath, 'r')
    formula_lines = fd.readlines()
    fd.close()
    return formula_lines

def write_lines(fpath, lines):
    fd = open(fpath, 'w')
    for line in lines:
        fd.write(line)
    fd.close()

def load_config():
    """Pull tap_name and os_arch from ~/.ppcbrewbot/config."""
    fpath = "%s/.ppcbrewbot/config" % os.environ['HOME']
    if not os.path.exists(fpath):
        sys.stderr.write('Error: ~/.ppcbrewbot/config doesn\'t exist.\n')
        sys.stderr.write('\n')
        sys.stderr.write(
            'Example config for tap github.com/foo/homebrew-bar running OS X Tiger on a G3:\n'
        )
        sys.stderr.write('tap_name foo/bar\n')
        sys.stderr.write('os_arch tiger_g3\n')
        sys.exit(1)
    lines = load_lines(fpath)
    config = {}
    for line in lines:
        key, value = line.split(' ', 1)
        if key in ['tap_name', 'os_arch']:
            config[key] = value
        continue
    return config

def split_formula(lines):
    """Split a formula around the 'bottle do' section."""
    preamble = []
    bottle_clause = []
    postamble = []
    i = 0
    while i < len(lines):
        line = lines[i]
        words = line.split()
        if len(words) >= 2 and words[:2] == ['bottle', 'do']:
            break
        else:
            preamble.append(line)
            i += 1
            continue
    while i < len(lines):
        line = lines[i]
        words = line.split()
        if len(words) >= 1 and words[0] == 'end':
            break
        else:
            bottle_clause.append(line)
            i += 1
            continue
    while i < len(lines):
        line = lines[i]
        postable.append(line)
        i += 1
        continue
    if len(bottle_clause) == 0:
        sys.stderr.write('Error: missing \'bottle do\' clause?.\n')
        sys.exit(1)
    if len(preamble) < 1 or len(bottle_clause) < 2 or len(postamble) < 1:
        sys.stderr.write('Error: don\'t know how to parse this formula.\n')
        sys.exit(1)
    return (preamble, bottle_clause, postamble)

def determine_parameters():
    """Determine our parameters using config and cmd-line args."""
    if len(sys.argv) == 2 and sys.argv[1] in ['-h', '--help']:
        usage(sys.stdout)
        sys.exit(0)
    if len(sys.argv) < 3:
        usage(sys.stderr)
        sys.exit(1)
    formula_name = sys.argv[1]
    hash = sys.argv[2]
    config = load_config()
    tap_name = config['tap_name']
    os_arch = config['os_arch']
    tap_fpath = "/usr/local/Library/Taps/%s/homebrew-%s" \
        % (tap_name.split('/')[0], tap_name.split('/')[1])
    formula_fpath = "%s/%s.rb" % (tap_fpath, formula_name)
    return (formula_fpath, hash, os_arch)

def update_sha_line(bottle_clause, hash, os_arch):
    """Find and edit (or add) the appropriate line using the new hash."""

    def get_indent(line):
        """Return the leading whitespace portion of this line."""
        i = 0
        while i < len(line):
            if not ch.isspace():
                break
            else:
                continue
        return line[:i]

    def create_sha_line(bottle_clause, hash, os_arch):
        """Generate a bottle sha entry using 'hash' and 'os_arch'."""
        indent = get_indent(bottle_clause[1])
        if len(hash) == 64:
            sha_type = 'sha256'
        elif len(hash) == 40:
            sha_type = 'sha1'
        else:
            sys.stderr.write('Error: don\'t understand this type of hash.\n')
            sys.exit(1)
        sha_line = '%s%s "%s" => :%s\n' % (indent, sha_type, hash, os_arch)
        return sha_line

    def insert_sha_line(bottle_clause, sha_line):
        """Add the sha line to the end of the bottle clause (just before 'end')."""
        bottle_clause2 = bottle_clause[:-1] + [sha_line] + bottle_clause[-1]
        return bottle_clause2

    def replace_sha_line(bottle_clause, sha_line, os_arch):
        """Find the sha line for this os_arch and replace it."""
        bottle_clause2 = []
        for line in bottle_clause:
            if ":%s" % os_arch in line:
                bottle_clause2.append(sha_line)
                continue
            else:
                bottle_clause2.append(line)
                continue
        return bottle_clause2

    def already_contains_entry(bottle_clause, os_arch):
        """Return True if bottle_clause contains an entry for os_arch."""
        for line in bottle_clause:
            if ":%s" % os_arch in line:
                return True
            else:
                continue
        return False

    """Find and edit (or add) the appropriate line using the new hash."""
    sha_line = create_sha_line(bottle_clause, hash, os_arch)
    if already_contains_entry(bottle_clause, os_arch):
        return replace_sha_line(bottle_clause, sha_line, os_arch)
    else:
        return insert_sha_line(bottle_clause, sha_line)

def main():
    (formula_fpath, hash, os_arch) = determine_parameters()
    formula_lines = load_lines(formula_fpath)
    (preamble, bottle_clause, post_amble) = split_formula(formula_lines)
    bottle_clause2 = update_sha_line(bottle_clause)
    write_lines(formula_fpath, preamble + bottle_clause2 + postamble)

if __name__ == '__main__':
    main()
