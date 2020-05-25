#!/usr/bin/env python

# add-bottle-to-formula.py: insert a bottle sha1 line into a formula.

# Copyright (c) 2020 Jason Pepas
# Released under the terms of the MIT license.
# See https://opensource.org/licenses/MIT

# This script was written to work with the version of Python which shipped
# with OS X Tiger (10.4), which is Python 2.3.5.

# This script is idempotent.

import sys
import os
import re

def usage(fd):
    """Print the usage message to the file descriptor."""
    fd.write('Usage:\n')
    exe = os.path.basename(sys.argv[0])
    fd.write("  %s <formula file> <sha1> <os/arch> <root url>\n" % exe)
    fd.write('\n')
    fd.write('For example:\n')
    fd.write(
        "  %s /some/dir/gcc.rb 123... tiger_g3 https://some.server/bottles\n" \
        % exe
    )

def split_formula(fpath):
    """Reads a formula and splits it around the 'bottle do' clause.
    Returns three arrays of lines."""
    fd = open(fpath)
    lines = fd.readlines()
    fd.close()

    bottle_do_regex = re.compile('\s*bottle\s+do')
    end_regex = re.compile('\s*end')
    bottle_do_lineno = None
    end_lineno = None
    i = 0
    while i < len(lines):
        m = bottle_do_regex.match(lines[i])
        if m:
            bottle_do_lineno = i
            break
        else:
            i += 1
    while i < len(lines):
        m = end_regex.match(lines[i])
        if m:
            end_lineno = i
            break
        else:
            i += 1
    before_lines = lines[:bottle_do_lineno]
    bottle_do_lines = lines[bottle_do_lineno:end_lineno+1]
    after_lines = lines[end_lineno+1:]
    return (before_lines, bottle_do_lines, after_lines)

def insert_bottle(bottle_do_lines, sha1, os_arch, root_url):
    """Inserts an entry into a 'bottle do' clause."""
    content_lines = bottle_do_lines[1:-1]
    # figure out the indentation level
    indent_regex = re.compile('(\s*)')
    if len(content_lines) == 0:
        indent = indent_regex.match(bottle_do_lines[0]).groups(1)[0] * 2
    else:
        indent = indent_regex.match(content_lines[0]).groups(1)[0]
    new_content_lines = []
    new_content_lines.append(indent + 'root_url "%s"\n' % root_url)
    for line in content_lines:
        words = line.split()

        # filter out any existing bottle entry for matching our os_arch.
        if len(words) >= 3 \
        and words[2] == '=>' \
        and words[3].startswith(':') \
        and words[3] == ":%s" % os_arch:
            # this is an older entry for this os_arch, so drop it.
            continue

        # filter out any root_url lines.
        if len(words) >= 1 and words[0] == 'root_url':
            continue

        new_content_lines.append(line)
    new_bottle_line = indent + 'sha1 "%s" => :%s\n' % (sha1, os_arch)
    new_content_lines.append(new_bottle_line)
    return [bottle_do_lines[0]] + new_content_lines + [bottle_do_lines[-1]]

if __name__ == '__main__':
    if len(sys.argv) != 5:
        usage(sys.stderr)
        sys.exit(1)
    formula_fpath = sys.argv[1]
    sha1 = sys.argv[2]
    os_arch = sys.argv[3]
    root_url = sys.argv[4]

    before_lines, bottle_do_lines, after_lines = split_formula(formula_fpath)
    bottle_do_lines = insert_bottle(bottle_do_lines, sha1, os_arch, root_url)

    fd = open(formula_fpath, 'w')
    for line in before_lines + bottle_do_lines + after_lines:
        fd.write(line)
    fd.close()
