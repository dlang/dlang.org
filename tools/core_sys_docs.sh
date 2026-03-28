#!/bin/sh
# Usage: ./core_sys_docs.sh DIR
#
# List all modules in DIR which have more than one doc-comment.
# The first doc-comment is just the module and is probably uninteresting.

find $1 -name '*.d' \
    | xargs grep -Ec '/\*\*|/\+\+|///' \
    | grep -vE ':[01]$' \
    | awk -F '/src/' '{ print $2 }' \
    | awk -F '.d:' '{ print $1 }' \
    | tr '/' '.'
