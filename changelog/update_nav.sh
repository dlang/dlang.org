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

# update VER=2.012.3 macros
for ver in "${all_vers[@]}"; do
    if [[ "$ver" = *_pre.dd ]]; then
        sed -i "s|VER=[0-9\.][0-9\.]*|VER=${ver%_pre.dd}|" "$ver"
    else
        sed -i "s|VER=[0-9\.][0-9\.]*|VER=${ver%.dd}|" "$ver"
    fi
done

# reverse sort versions array, http://stackoverflow.com/a/11789688/2371032
IFS=$'\n'
rev_all_vers=($(sort --reverse <<<"${all_vers[*]}"))
rev_rel_vers=($(sort --reverse <<<"${rel_vers[*]}"))
rev_pre_vers=($(sort --reverse <<<"${pre_vers[*]}"))
unset IFS

# update index of all changlogs
sed -i '/BEGIN_GENERATED_CHANGELOG_VERSIONS/,/END_GENERATED_CHANGELOG_VERSIONS/d' changelog.ddoc
echo '_=BEGIN_GENERATED_CHANGELOG_VERSIONS' >> changelog.ddoc
echo 'CHANGELOG_VERSIONS =' >> changelog.ddoc
echo '    $(CHANGELOG_VERSION_NIGHTLY)' >> changelog.ddoc
for ver in "${rev_pre_vers[@]}"; do
    echo "    \$(CHANGELOG_VERSION_PRE ${ver%_pre.dd}, not yet released)" >> changelog.ddoc
done
for ver in "${rev_rel_vers[@]}"; do
    echo "    \$(CHANGELOG_VERSION ${ver%.dd})" >> changelog.ddoc
done
echo '_=END_GENERATED_CHANGELOG_VERSIONS' >> changelog.ddoc

# add release dates
(
    IFS=$'\n'
    sed -i changelog.ddoc $(grep '(VERSION' -- *.dd | sed -E 's/^(.*)\.dd:\$\(VERSION (.*), ==.*/-e\ns#CHANGELOG_VERSION \1)#CHANGELOG_VERSION \1, \2)#/')
)
