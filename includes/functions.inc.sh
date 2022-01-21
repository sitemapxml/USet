fn_output_coloring_off () {
  RED=''
  GREEN=''
  YELLOW=''
  BLACK=''
  WHITE=''
  NC=''
  BGREEN=''
  BGRAY=''
  BNC=''
}

fn_output_coloring_on () {
  # Text colors
  RED='\033[0;31m'
  GREEN='\033[0;32m'
  YELLOW='\033[1;33m'
  BLACK='\e[30m'
  WHITE='\e[97m'

  # Text color reset
  NC='\033[0m'

  # Background color
  BGREEN='\e[42m'
  BGRAY='\e[47m'

  # Background color reset
  BNC='\e[49m'
}

fn_insert_line () {
  printf '=%.0s' {1..70} && printf '\n'
}
