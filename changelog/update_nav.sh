#!/usr/bin/env bash

set -ueEo pipefail

cd changelog
all_vers=($(ls *.dd | grep '^[0-9]\.[0-9][0-9][0-9]\(\.[0-9]\)\?\(_[a-z]*\)\?\.dd$' | sort))
rel_vers=(${all_vers[@]//*_*.dd})

sed -i "s|\$(CHANGELOG_NAV[^)]*)|\$(CHANGELOG_NAV_FIRST ${rel_vers[1]%.dd})|" "${rel_vers[0]}"
for idx in $(seq 1 $((${#rel_vers[@]} - 2))); do
    sed -i "s|\$(CHANGELOG_NAV[^)]*)|\$(CHANGELOG_NAV ${rel_vers[$(($idx - 1))]%.dd},${rel_vers[$(($idx + 1))]%.dd})|" "${rel_vers[$idx]}"
done
sed -i "s|\$(CHANGELOG_NAV[^)]*)|\$(CHANGELOG_NAV_LAST ${rel_vers[-2]%.dd})|" "${rel_vers[-1]}"

prec_rel=
for ver in "${all_vers[@]}"; do
    if [[ "$ver" = *_*.dd ]]; then
        # link pre-release changelogs to last preceding release
        sed -i "s|\$(CHANGELOG_NAV[^)]*)|\$(CHANGELOG_NAV_LAST ${prec_rel%.dd})|" "$ver"
    else
        prec_rel=$ver
    fi
done

# filename -> version number
vernum() {
    if [[ "$1" = *_*.dd ]]; then
        echo "${1%_*.dd}"
    else
        echo "${1%.dd}"
    fi
}

# filename -> release date
reldate() {
    local fn="$1"
    if [[ "$fn" = *_nightly.dd ]]; then
        echo 'to be released,'
    elif [[ "$fn" = *_beta.dd ]]; then
        sed -n 's|$(VERSION \(.*\), ==*,$|to be released \1|p' "$fn"
    else
        sed -n 's|$(VERSION \(.*\), ==*,$|\1|p' "$fn"
    fi
}

# update VER=2.012.3 macros
for ver in "${all_vers[@]}"; do
    sed -i "s|VER=[0-9\.][0-9\.]*|VER=$(vernum $ver)|" "$ver"
done

# reverse sort versions array, http://stackoverflow.com/a/11789688/2371032
IFS=$'\n'
rev_all_vers=($(sort --reverse <<<"${all_vers[*]}"))
unset IFS

# update index of all changlogs
sed -i '/BEGIN_GENERATED_CHANGELOG_VERSIONS/,/END_GENERATED_CHANGELOG_VERSIONS/d' changelog.ddoc
echo '_=BEGIN_GENERATED_CHANGELOG_VERSIONS' >> changelog.ddoc
echo 'CHANGELOG_VERSIONS =' >> changelog.ddoc
for ver in "${rev_all_vers[@]}"; do
    echo "    \$(CHANGELOG_VERSION $(vernum $ver), $(reldate $ver))" >> changelog.ddoc
done
echo '_=END_GENERATED_CHANGELOG_VERSIONS' >> changelog.ddoc
