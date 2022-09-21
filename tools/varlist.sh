#!/bin/bash

# The USET project - https://github.com/sitemapxml/uset
# This script is used to generate list available configuration variables

filepath=$(realpath $0)
dirpath=$(dirname $filepath)
basepath=$(echo ${dirpath%/*})
me=$(basename "$0")

arglist="$basepath/includes/arglist.inc.sh"
config="$basepath/default.conf"

usage() {
cat << EOT
  Generate list of available configuration variables.
  usage $me [-adch]
  OPTIONS
    -a  [all]     list all available variables
    -d  [dollar]  list variables with dollar sign
    -c  [config]  list variables with values inside config file
    -h  [help]    show this message
EOT
}

list_all () {
  cat "$arglist" | sed '/^[[:space:]]*$/d;s/=.*//'
}

list_config () {
  cat "$config" | sed '/^[[:space:]]*$/d;/^#/d'
}

while getopts "adch" option; do
    case $option in
        a) list_all ; exit 0 ;;
        d) list_all | sed 's/^/$/' ; exit 0 ;;
        c) list_config ; exit 0 ;;
        \?)
          printf "wrong option.\n"
          usage; exit 1
          ;;
        h) usage; exit 0 ;;
    esac
done
shift $(($OPTIND - 1))

usage
