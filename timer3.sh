#!/bin/bash
GREEN='\e[0;32m'
RED='\e[0;31m'
YELLOW='\e[0;33m'
RESET='\e[0m'
SEC_COLOR=${RED}
SEC=33
tput civis

echo -ne $SEC="$SEC_COLOR"
  while [ $SEC -ge 0 ]; do
    if [ "$SEC" -le "30" ]; then
      SEC_COLOR="${YELLOW}"
    fi
    if [ "$SEC" -le "15" ]; then
      SEC_COLOR="${GREEN}"
    fi

    printf "\r${RESET}non-sense-text $SEC_COLOR%02d$RESET" "$SEC"
    let "SEC=SEC-1"
    sleep 1
  done
echo -e "${RESET}"
tput cnorm
