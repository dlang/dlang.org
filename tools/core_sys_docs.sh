#!/bin/sh
# list all modules in $1 which have more than one doc-comment
find $1 -name '*.d' \
    | xargs grep -Ec '/\*\*|/\+\+|///' \
    | grep -vE ':[01]$' \
    | awk -F '/src/' '{ print $2 }' \
    | awk -F '.d:' '{ print $1 }' \
    | tr '/' '.'
