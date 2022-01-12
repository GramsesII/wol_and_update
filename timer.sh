#!/bin/bash
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
RESET='\033[0m'
sec=33
tput civis
echo -e "non-sense-text" 

echo -ne "${RED}"
      while [ $sec -ge 0 ]; do
            if [ "$sec" -le "30" ]; then
                echo -ne "${YELLOW}"
            fi
                if [ "$sec" -le "15" ]; then
                    echo -ne "${GREEN}"
                fi
	            echo -ne "$(printf "%02d" $sec)\e[0K\r"
                let "sec=sec-1"
            sleep 1
      done
echo -e "${RESET}"
tput cnorm
