#!/bin/bash

# The USET project - https://github.com/sitemapxml/uset
# This script is used to generate list available arguments

source '../includes/functions.inc.sh' && fn_locate
arglist='../includes/arglist.inc.sh'

usage() {
cat << EOT
  Generate list of available arguments.
  usage $me [-hlb]
  OPTIONS
    -l    [list] make a list of arguments
    -b    [bare] remove minus sign before argument names
    -h    show this message
EOT
}

list () {
  cat "$arglist" | awk '{print $2}' | sed 's/"//g;/^[[:space:]]*$/d;s/^/--/'
}

while getopts "hlb" option; do
    case $option in
        l) list && exit 0 ;;
        b) list | sed 's/--//g' && exit 0 ;;
        \?)
          printf "wrong option.\n"
          usage; exit 1
          ;;
        h)
          usage; exit 0
          ;;
    esac
done
shift $(($OPTIND - 1))

usage
