#!/bin/bash

# Quick-n-dirty script to:
# - Build a bottle
# - Upload the bottle to backblaze b2
# - Add the bottle to the formula
# - Commit and push the updated formula

# Copyright (c) 2020 Jason Pepas
# Released under the terms of the MIT license
# See https://opensource.org/licenses/MIT

# This script is written for the /bin/bash which shipped with OS X Tiger,
# which is Bash 2.05b.

if test -z "$1"; then
    echo "Error: no formula specified." >&2
    echo "" >&2
    echo "Usage: $( basename $0 ) <formula>" >&2
    echo "Example: $( basename $0 ) gcc" >&2
    exit 1
fi

if test $1 = "-h" -o $1 = "--help"; then
    echo "Usage: $( basename $0 ) <formula>"
    echo "Example: $( basename $0 ) gcc"
    exit 0
fi

if ! test -e $HOME/.ppcbrewbot/config; then
    echo "Error: $HOME/.ppcbrewbot/config doesn't exist." >&2
    echo "" >&2
    echo "At minimum, this script needs tap_name and bottles_dir from that config." >&2
    echo "Example config:" >&2
    echo "tap_name ppcbrew/tiger" >&2
    echo "bottles_dir /Users/macuser/bottles" >&2
    exit 1
fi

formula=$1
if echo $formula | grep -q '/'; then
    echo "Error: don't use the tap-qualified formula name." >&2
    echo "" >&2
    echo "This script automatically qualifies the formula name," >&2
    echo "using tap_name from ~/.ppcbrew/config." >&2
    echo "E.g. '$( basename $0 ) gcc', not '$( basename $0 ) foo/bar/gcc'." >&2
    exit 1
fi

set -e
set -x
# unfortunately, '-o pipefail' is available on Tiger's /bin/bash (2.05). 

# pull values from our config
tap_name=$( cat ~/.ppcbrewbot/config | grep tap_name | awk '{ print $2 }' )
bottles_path=$( cat ~/.ppcbrewbot/config | grep bottles_dir | awk '{ print $2 }' )

# add the tap scripts to our $PATH
tap_path=/usr/local/Library/Taps/$( echo $tap_name | sed 's?/?/homebrew-?' )
export PATH="${tap_path}/bin:$PATH"

# update the tap before building
cd ${tap_path}/Formula
git pull

# build the formula
time nice ppcbrew install --verbose --build-bottle $formula

# bottle the formula
cd $bottles_path
ppcbrew bottle $formula

# upload the bottle
bottle=$( ls -1tr | tail -n1 )
upload-bottle-to-b2.py $bottle

# add a bottle sha to the formula
sha=$( sha256.rb $bottle )
cd ${tap_path}/Formula
update-bottle-sha.py $formula $sha

# commit and push the updated formula
git add ${formula}.rb
version=$( ppcbrew info $formula | grep stable | grep '(bottled)' | head -n1 | cut -d' ' -f3 )
git commit -m "adding $os_arch bottle of $formula $version"
git push origin
