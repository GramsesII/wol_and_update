#!/bin/bash
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
RESET='\033[0m'
SEC_COLOR='\033[0m'
sec=33
tput civis
echo -e "non-sense-text"

echo -ne SEC_COLOR="${RED}$sec"
      while [ $sec -ge 0 ]; do
            if [ "$sec" -le "30" ]; then
                SEC_COLOR="${YELLOW}$sec"
            fi
                if [ "$sec" -le "15" ]; then
                    SEC_COLOR="${GREEN}$sec"
                fi
	            echo -ne "$(printf "%02s" $SEC_COLOR)\r\e[0K"
                let "sec=sec-1"
            sleep 1
      done
echo -e "${RESET}"
tput cnorm
