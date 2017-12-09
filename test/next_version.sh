#!/usr/bin/env bash
# Test changelog/next_version.sh

set -ueo pipefail

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

NV="$DIR/../changelog/next_version.sh"

TMPFILE=$(mktemp deleteme.XXXXXXXX)
cleanup() {
    rm -rf "$TMPFILE";
}
trap cleanup EXIT

versions=( \
    "2.077.0|2.078.0"
    "2.077.1|2.078.0"
    "2.077.1-beta|2.078.0"
    "2.077.1-master.abcdefg|2.078.0"
    "3.81.1|3.082.0"
)

for version in "${versions[@]}" ; do
    version_latest="$(echo "$version" | cut -d'|' -f 1)"
    version_next="$(echo "$version" | cut -d'|' -f 2)"
    echo "v$version_latest" > "$TMPFILE"
    echo "Testing: $version_latest (expecting: $version_next)"
    version_real=$("$NV" "$TMPFILE")
    if [ "$version_real" != "$version_next" ] ; then
        echo "Comparison failed. Received $version_real (expected $version_next)"
        exit 1
    fi
done
