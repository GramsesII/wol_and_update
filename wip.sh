#!/bin/bash

#  License: "(MIT)", (see LICENSE.txt for more info)
#  Author: "Christian Berg <gramse@pln.nu> (https://pln.nu/)"
#  Contributor(s): "That there decent man over there"

# A simple Wake on Lan and update a target machine script.
# This script is tested on Ubuntu 20.04 lts.
# Depends on: etherwake, ssh (openssh-client), systemctl (systemd), tee (coreutils)

# Fancy variables no need to change these.
Ver=v1.666
GREEN='\e[0;32m'
RED='\e[0;31m'
YELLOW='\e[0;33m'
RESET='\e[0m'
SEC_COLOR=${RED}

case "$choice" in
	r)
# Log thingys
# Lets check if the log dir. exist if not lets create it.
	if [ ! -d "./log" ]; then
		mkdir -v ./log;
	fi
# Continuing on with the log code.
log=./log/"$(date +"%F-%T").log"
touch $log
exec 3>&1 4>&2
trap 'exec 2>&4 1>&3' 0 1 2 3 15
exec 1> >(tee -a "$log") 2>&1


echo -e "Wake on Lan and update ${YELLOW}$Ver${RESET} - ${GREEN}started${RESET}: $(date)\n"

# Checking for some needed programs.
failed=0
echo -n "Checking dependencies... "
        for name in etherwake tee ssh systemctl
        do
                if ! [[ $(which $name 2>/dev/null) ]]; then
                        [[ $failed -eq 0 ]] && echo -en "${RED}FAIL${RESET}\n"
                        failed=1
                        echo -en "\n$name needs to be installed. Use 'sudo apt-get install $name'"
                fi
        done
        [[ $failed -eq 1 ]] && echo -en "\n\nInstall the above and rerun this script\n" && exit 1;

        echo -e "${GREEN}OK${RESET}\n"

unset failed
unset name

# //Start of config\\
DIR="${BASH_SOURCE%/*}"
cd $DIR
# Checking if user config file are present.
echo -n "Checking for user config... "
	for name in wol_config.cfg
	do
		[ -f $name ] || { echo -en "${RED}FAIL${RESET}\n";deps=1; }
	done
		[[ $deps -ne 1 ]] && echo -e "${GREEN}OK${RESET}\n" || { echo -en "\nCreate a new wol_config.cfg from the wol_config_example.cfg\n";exit 1; }
unset name
unset deps

set -v
. "wol_config.cfg"

# Please ignore the following one(1) row in the logfile.
set +v
# \\End of config//

# Start of the magic (magic packet, get it? ;).
echo -e "${GREEN}Waking target up.${RESET}\n"
#	sudo etherwake -i $IFNAME $MAC -b $BROADCAST
#	sleep 5
	echo -e "${GREEN}Target gone woke, lets update it.${RESET}\n"
#		ssh -i $RSA -l $USER $TARGET -p $PORT 'sudo apt-get update; sudo apt-get -y upgrade'
	echo -e "${GREEN}Update done! Rebooting target.${RESET}\n"
#		ssh -i $RSA -l $USER $TARGET -p $PORT 'sudo systemctl reboot --now'
	echo -e "${GREEN}Waiting for the reboot to be done.${RESET}\n"
		tput civis
			echo -ne $SEC="$SEC_COLOR"
				while [ $SEC -ge 0 ]; do
					if [ "$SEC" -le "30" ]; then
					SEC_COLOR="${YELLOW}"
				fi
					if [ "$SEC" -le "15" ]; then
					SEC_COLOR="${GREEN}"
				fi
					printf "\r${RESET}seconds to finnished reboot: $SEC_COLOR%02d$RESET" "$SEC"
					let "SEC=SEC-1"
					sleep 1
				done
			echo -e "${RESET}\n"
		tput cnorm
	echo -e "${GREEN}Target rebooted, lets suspend it until next update.${RESET}\n"
#		ssh -i $RSA -l $USER $TARGET -p $PORT 'sudo systemctl suspend'
	echo -e "${GREEN}Target put to sleep! Ending script.${RESET}\n"

echo -e "Wake on Lan ${YELLOW}$Ver${RESET} - ${RED}stop${RESET}: $(date)\n"

		;;
        h)
        cat README.txt
                ;;
        v)
        echo -e "$Ver"
                ;;
        l)
        cat LICENSE.txt
                ;;
        c)
        cat wol_config.cfg
                ;;
        e)
        nano -AKGwp wol_config.cfg
                ;;
        *)
                echo -en "Usage: ./WoL.sh {c|e|h|l|r|v}\n"
                echo -en " c, Current config.\n e, Edit current config.\n h, Help.\n l, License.\n r, Run main script.\n v, Version.\n"
                exit 1
                ;;
esac

exit 0
#EoF
