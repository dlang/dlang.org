#!/usr/bin/env bash

set -ueo pipefail

# cd and pwd to account for relative paths/symlinks. See also:
# https://stackoverflow.com/questions/59895/getting-the-source-directory-of-a-bash-script-from-within
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

VERSION=$(cat "${1:-$DIR/../../dmd/VERSION}")
# v2.076.1-b1 -> 2.076.1
VERSION=${VERSION:1:7}
# 2.076.1 -> (2 076 1)
PARTS=(${VERSION//./ })
# use 10#076 prefix to read octal as base10 int
PARTS[1]=$(printf %03d $((10#${PARTS[1]} + 1)))
PARTS[2]=0
# 2 077 0 -> 2.077.0
echo "${PARTS[0]}.${PARTS[1]}.${PARTS[2]}"
