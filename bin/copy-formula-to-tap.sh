#!/bin/bash

formula=$1
if [ -z "$1" ]; then
    echo "Usage: $0 <formula>" >&2
    exit 1
fi

tap_name=`cat ~/.ppcbrewbot/config | grep '^tap_name ' | cut -d' ' -f 2`
tap_dirname=`echo $tap_name | sed 's?/?/homebrew-?'`
tap_formula_dir="/usr/local/Library/Taps/$tap_dirname/Formula"

if [ -e "$tap_formula_dir/${formula}.rb" ]; then
    echo "Error: $tap_formula_dir/${formula}.rb already exists." >&2
    exit 1
fi

cp "/usr/local/Library/Formula/${formula}.rb" "${tap_formula_dir}/"
