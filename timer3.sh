#!/bin/bash
GREEN='\e[0;32m'
RED='\e[0;31m'
YELLOW='\e[0;33m'
RESET='\e[0m'
SEC_COLOR='\e[0m'
sec=33
tput civis

echo -ne SEC_COLOR="${RED}$sec"
  while [ $sec -ge 0 ]; do
    if [ "$sec" -le "30" ]; then
      SEC_COLOR="${YELLOW}"
    fi
    if [ "$sec" -le "15" ]; then
      SEC_COLOR="${GREEN}"
    fi

    printf "\r${RESET}non-sense-text $SEC_COLOR%02d$RESET" "$sec"
    let "sec=sec-1"
    sleep 1
  done
echo -e "${RESET}"
tput cnorm
