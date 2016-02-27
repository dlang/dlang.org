#!/usr/bin/env bash

cd changelog
versions=($(ls *.dd | grep '^[0-9]\.[0-9][0-9][0-9]\(\.[0-9]\)\?\.dd$' | sort))

sed -i "s|\$(CHANGELOG_NAV[^)]*)|\$(CHANGELOG_NAV_FIRST ${versions[1]%.dd})|" "${versions[0]}"
for idx in $(seq 1 $((${#versions[@]} - 2))); do
    sed -i "s|\$(CHANGELOG_NAV[^)]*)|\$(CHANGELOG_NAV ${versions[$(($idx - 1))]%.dd},${versions[$(($idx + 1))]%.dd})|" "${versions[$idx]}"
done
sed -i "s|\$(CHANGELOG_NAV[^)]*)|\$(CHANGELOG_NAV_LAST ${versions[-2]%.dd})|" "${versions[-1]}"
