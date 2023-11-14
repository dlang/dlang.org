#!/bin/bash

set -uexo pipefail

HOST_DMD_VER=2.078.1
CURL_USER_AGENT="CirleCI $(curl --version | head -n 1)"
DUB=${DUB:-$HOME/dlang/dub/dub}
N=2
CIRCLE_NODE_INDEX=${CIRCLE_NODE_INDEX:-0}

case $CIRCLE_NODE_INDEX in
    0) MODEL=64 ;;
    1) MODEL=32 ;;
esac

install_deps() {
    if [ $MODEL -eq 32 ]; then
        sudo apt-get update
        sudo apt-get install g++-multilib
    fi

    for i in {0..4}; do
        if curl -fsS -A "$CURL_USER_AGENT" --max-time 5 https://dlang.org/install.sh -O ||
           curl -fsS -A "$CURL_USER_AGENT" --max-time 5 https://nightlies.dlang.org/install.sh -O ||
           curl -fsS -A "$CURL_USER_AGENT" --max-time 5 https://raw.githubusercontent.com/dlang/installer/master/script/install.sh -O ; then
            break
        elif [ $i -ge 4 ]; then
            sleep $((1 << $i))
        else
            echo 'Failed to download install script' 1>&2
            exit 1
        fi
    done

    source "$(CURL_USER_AGENT=\"$CURL_USER_AGENT\" bash install.sh dmd-$HOST_DMD_VER --activate)"
    $DC --version
    env
}

# clone dmd and druntime
clone() {
    local url="$1"
    local path="$2"
    local branch="$3"
    for i in {0..4}; do
        if git clone --branch "$branch" "$url" "$path" "${@:4}"; then
            break
        elif [ $i -lt 4 ]; then
            sleep $((1 << $i))
        else
            echo "Failed to clone: ${url}"
            exit 1
        fi
    done
}

install_make()
{
    mkdir -p make
    cd make
    curl -L http://ftp.gnu.org/gnu/make/make-4.1.tar.gz  | tar -zxf - --strip-components=1 && ./configure && make && ./make -v
    export PATH="$(pwd):${PATH}"
    cd ..
}

setup_repos()
{
    # Set a default in case we run into rate limit restrictions
    local base_branch=""
    if [ -n "${CIRCLE_PR_NUMBER:-}" ]; then
        base_branch=$((curl -fsSL https://api.github.com/repos/dlang/dlang.org/pulls/$CIRCLE_PR_NUMBER || echo) | jq -r '.base.ref')
    else
        base_branch=$CIRCLE_BRANCH
    fi
    base_branch=${base_branch:-"master"}

    # Merge upstream branch with changes, s.t. we check with the latest changes
    if [ -n "${CIRCLE_PR_NUMBER:-}" ]; then
        local current_branch=$(git rev-parse --abbrev-ref HEAD)
        # work around weird CircleCi bug, see https://github.com/dlang/dlang.org/pull/1952
        git remote remove upstream || true
        git config user.name dummyuser
        git config user.email dummyuser@dummyserver.com
        git remote add upstream https://github.com/dlang/dlang.org.git
        git fetch upstream
        git checkout -f upstream/$base_branch
        git merge -m "Automatic merge" $current_branch
    fi

    for proj in dmd phobos ; do
        if [ $base_branch != master ] && [ $base_branch != stable ] &&
            ! git ls-remote --exit-code --heads https://github.com/dlang/$proj.git $base_branch > /dev/null; then
            # use master as fallback for other repos to test feature branches
            clone https://github.com/dlang/$proj.git ../$proj master --depth 1
        else
            clone https://github.com/dlang/$proj.git ../$proj $base_branch --depth 1
        fi
    done

    # Install the bootstrap compiler
    CURL_USER_AGENT=\"$CURL_USER_AGENT\" bash ~/dlang/install.sh dmd-$HOST_DMD_VER --activate
}

run_make()
{
    # Load environment for bootstrap compiler
    source "$(CURL_USER_AGENT=\"$CURL_USER_AGENT\" bash ~/dlang/install.sh dmd-$HOST_DMD_VER --activate)"
    export PATH="$(pwd)/make:$PATH"
    make -v

    # -j1 is used for a better error log
    make -f posix.mak -j1 DIFFABLE=1 BUILD_JOBS=3 release
}

case $1 in
    install-deps) install_deps ;;
    install-make) install_make ;;
    setup-repos) setup_repos ;;
    run-make) run_make;;
    *) echo "Unknown command"; exit 1;;
esac
