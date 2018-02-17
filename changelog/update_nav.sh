#!/usr/bin/env bash

set -ueEo pipefail

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $DIR

all_vers=($(ls *.dd | grep '^[0-9]\.[0-9][0-9][0-9]\(\.[0-9]\)\?\(_pre\)\?\.dd$' | sort))
# also see http://wiki.bash-hackers.org/syntax/pe#search_and_replace
# filter-out all pre-release changelogs
rel_vers=(${all_vers[@]//*_pre.dd})
# filter-out all release changelogs
pre_vers=(${all_vers[@]//*[^_][^p][^r][^e].dd})

sed -i "s|\$(CHANGELOG_NAV[^)]*)|\$(CHANGELOG_NAV_FIRST ${rel_vers[1]%.dd})|" "${rel_vers[0]}"
for idx in $(seq 1 $((${#rel_vers[@]} - 2))); do
    sed -i "s|\$(CHANGELOG_NAV[^)]*)|\$(CHANGELOG_NAV ${rel_vers[$(($idx - 1))]%.dd},${rel_vers[$(($idx + 1))]%.dd})|" "${rel_vers[$idx]}"
done
sed -i "s|\$(CHANGELOG_NAV[^)]*)|\$(CHANGELOG_NAV_LAST ${rel_vers[-2]%.dd})|" "${rel_vers[-1]}"

prec_rel=
for ver in "${all_vers[@]}"; do
    if [[ "$ver" = *_pre.dd ]]; then
        # link pre-release changelogs to last preceding release
        sed -i "s|\$(CHANGELOG_NAV[^)]*)|\$(CHANGELOG_NAV_LAST ${prec_rel%.dd})|" "$ver"
    else
        prec_rel=$ver
    fi
done
