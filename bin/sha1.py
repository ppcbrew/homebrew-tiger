#!/usr/bin/python

# This script computes the sha1 hash of a file.

# This is useful for machines which don't ship with sha1, but do
# ship with Python.

# This script is written for the Python interpreter which shipped
# with OS X Tiger (10.4), which is Python 2.3.5.

# Copyright (c) 2020 Jason Pepas
# Released under the terms of the MIT License.
# See https://opensource.org/licenses/MIT

import sys
import sha

if __name__ == '__main__':
    if len(sys.argv) == 1:
        sys.stderr.write('Error: no file specified.\n')
        sys.exit(1)
    hash = sha.new()
    fd = open(sys.argv[1])
    while True:
        data = fd.read(256 * 1024)
        if len(data) == 0:
            break
        hash.update(data)
    fd.close()
    sys.stdout.write("%s\n" % hash.hexdigest())
