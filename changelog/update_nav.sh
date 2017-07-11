#!/usr/bin/env bash

cd changelog
all_vers=($(ls *.dd | grep '^[0-9]\.[0-9][0-9][0-9]\(\.[0-9]\)\?\(_pre\)\?\.dd$' | sort))
# filter-out all pre-release changelogs
rel_vers=(${all_vers[@]//*_pre.dd/})

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
    elif [[ "$ver" = *_pending.dd ]]; then
        sed -i "s|VER=[0-9\.][0-9\.]*|VER=${ver%_pending.dd}|" "$ver"
    else
        sed -i "s|VER=[0-9\.][0-9\.]*|VER=${ver%.dd}|" "$ver"
    fi
done

# reverse sort versions array, http://stackoverflow.com/a/11789688/2371032
IFS=$'\n'
rev_all_vers=($(sort --reverse <<<"${all_vers[*]}"))
rev_rel_vers=($(sort --reverse <<<"${rel_vers[*]}"))
rev_pre_vers=($(ls -- *_pre.dd | sort --reverse))
rev_pending_vers=($(ls -- *_pending.dd | sort --reverse))
unset IFS

# update index of all changlogs
sed -i '/BEGIN_GENERATED_CHANGELOG_VERSIONS/,/END_GENERATED_CHANGELOG_VERSIONS/d' changelog.ddoc
echo '_=BEGIN_GENERATED_CHANGELOG_VERSIONS' >> changelog.ddoc
echo 'CHANGELOG_VERSIONS =' >> changelog.ddoc
for ver in "${rev_pending_vers[@]}"; do
    echo "    \$(CHANGELOG_VERSION_PENDING ${ver%_pending.dd}, not yet released)" >> changelog.ddoc
done
for ver in "${rev_pre_vers[@]}"; do
    echo "    \$(CHANGELOG_VERSION_PRE ${ver%_pre.dd}, to be released)" >> changelog.ddoc
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
