#!/usr/bin/env bash

set -euxo pipefail

apt-get install gcc latex kindlegen

make -f posix.mak html
