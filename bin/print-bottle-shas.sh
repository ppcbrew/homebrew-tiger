#!/bin/bash

set -e

ls ~/bottles/*.tar.* | xargs -n1 -I % sh -c 'echo %; sha256.rb %; echo'
