#!/bin/bash

set -e
set -x

time nice ppcbrew install --verbose --build-bottle $1
cd ~/bottles
ppcbrew bottle $1
