#!/bin/bash

#  develop branch
#  License: "(MIT)", (see LICENSE.txt for more info)
#  Author: "Christian Berg <gramse@pln.nu> (https://pln.nu/)"
#  Contributor(s): "That there decent man over there"

# A simple Wake on Lan and update a target machine script.
# This script is tested on Ubuntu 20.04 lts.
# Depends on: etherwake, ssh (openssh-client), systemctl (systemd), tee (coreutils)

# Internal variables do not change these.
Ver=v1.666
GREEN='\e[0;32m'
RED='\e[0;31m'
YELLOW='\e[0;33m'
RESET='\e[0m'
SEC_COLOR=${RED}
config="config_file.cfg"
F1=".1st"
#F2=${config}
F2="config_file.cfg"
# Internal variables end.

main(){
	log
		echo -e "Wake on Lan and update ${YELLOW}$Ver${RESET} - ${GREEN}started${RESET}: $(date)\n"
	check_dep

# //Start of config\\
	get_config
# \\End of config//

# Start of the magic (magic packet, get it? ;).
	echo -e "${GREEN}Waking target up.${RESET}\n"
#		sudo etherwake -i $IFNAME $MAC -b $BROADCAST
#		sleep 5
		echo -e "${GREEN}Target gone woke, lets update it.${RESET}\n"
#			ssh -i $RSA -l $USER $TARGET -p $PORT 'sudo apt-get update; sudo apt-get -y upgrade'
		echo -e "${GREEN}Update done! Rebooting target.${RESET}\n"
#			ssh -i $RSA -l $USER $TARGET -p $PORT 'sudo systemctl reboot --now'
		echo -e "${GREEN}Waiting for the reboot to be done.${RESET}\n"
# Start of reboot counter
			tput civis
				echo -ne $SEC="$SEC_COLOR"
					while [ $SEC -ge 0 ]; do
						if [ "$SEC" -le "30" ]; then
							SEC_COLOR="${YELLOW}"
						fi
						if [ "$SEC" -le "15" ]; then
							SEC_COLOR="${GREEN}"
						fi
							printf "\r${RESET}seconds to finished reboot: $SEC_COLOR%02d$RESET" "$SEC"
							let "SEC=SEC-1"
						sleep 1
					done
				echo -e "${RESET}\n"
			tput cnorm
# End of reboot counter
		echo -e "${GREEN}Target rebooted, lets suspend it until next update.${RESET}\n"
#			ssh -i $RSA -l $USER $TARGET -p $PORT 'sudo systemctl suspend'
		echo -e "${GREEN}Target put to sleep! Ending script.${RESET}\n"

echo -e "Wake on Lan ${YELLOW}$Ver${RESET} - ${RED}stop${RESET}: $(date)\n"
exit 0
	}

1stcheck(){
# Check if this is the first start and if there are an old config file.
    if ! [[ -f $F1 ]]; then echo -en "\n${RED}First start 'auto-config creator'${RESET}\n";
        else main;
    fi
        if [[ -s $F2 ]]; then while true; do
			read -p "Want to keep your old config? [Y/n]: " yn
            	case $yn in
                        [Yy]* ) return 0; break;;
                        [Nn]* ) break;;
                            * ) echo "Please answer yes or no.";;
                    esac
				done
		fi
			input
			clear
                echo -en "This will be your config file.\n"
            review

            while true; do
                    read -p "Want to keep it? [y/n/c]: " ync
                    case $ync in
                        [Yy]* ) mv -f ./$F2 ./$F2-old; review > $config; break;;
                        [Nn]* ) clear; echo -en "OK, let's start over";input;;
						[Cc]* ) echo -en "OK, let's continue.\n"; return 0; break;;
                            * ) echo "Please answer yes,no or cancel.";;
                esac
            done
    return 0
    }

input(){
# Auto configure inputs
        echo -en "\nTarget Broadcast IP (i.e 192.168.0.255, get by running 'fconfig' on the target machine).\n";
        read -p ": " BROADCAST;
        echo -en "\nTarget IP4 Macadress (looks like aa:bb:cc:dd:ee:ff, get by running 'ifconfig' on the target machine).\n";
        read -p ": " MAC;
        echo -en "\nTarget machines IP4 number.\n";
        read -p ": " TARGET;
        echo -en "\nTarget machines SSH port (default 22).\n";
        read -p ": " PORT;
        echo -en "\nThe name of your local machines network interface (i.e eth0 or enp3s0).\n";
        read -p ": " IFNAME;
        echo -en "\nYour SSH username on the target machine. It will help if this user have\n";
        echo -en "'YOUR_USER_NAME_HERE ALL=(ALL) NOPASSWD: /usr/bin/apt-get, /bin/systemctl' without the ''\n";
        echo -en "set in /etc/sudoers file on the target machine, this so you dont need to type in passwords 'all' the time.\n";
        echo -en "NOTE! the order in this file matters, try putting it before the last line, (edit with sudo visudo).\n";
        read -p ": " USER;
        echo -en "\nWere your SSH RSA key file are located on the local machine.\n";
        read -p ": " RSA;
        echo -en "\nHow many seconds do we wait for the target machine to reboot\n";
        echo -en "Raise or lower this if needed (default SEC=60).\n";
        read -p ": " SEC;
    return 0
    }

review(){
# Config file part..
    echo -en "
# Start of auto configured '$config'\n
# More info about this config in 'wol_config_example.cfg'\n
BROADCAST=$BROADCAST\n
MAC=$MAC\n
TARGET=$TARGET\n
PORT=$PORT\n
IFNAME=$IFNAME\n
USER=$USER\n
RSA=$RSA\n
SEC=$SEC\n
# End of auto configured '$config'\n"
return 0
    }

log(){
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
return 0
	}

check_dep(){
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

		unset failed  name
return 0
		}

get_config(){
	DIR="${BASH_SOURCE%/*}"
	cd $DIR
# Checking if user config file are present.
	echo -n "Checking for user config... "
    	for name in wol_config.cfg
    	do
        	[ -f $name ] || { echo -en "${RED}FAIL${RESET}\n";deps=1; }
    	done
        	[[ $deps -ne 1 ]] && echo -e "${GREEN}OK${RESET}\n" || { echo -en "\nCreate a new wol_config.cfg from the wol_config_example.cfg\n";exit 1; }
	unset name deps

	set -v
		. "wol_config.cfg"
	set +v # Please ignore this row in the logfile.
return 0
		}

# Program starts here.
	case "$1" in
		r)
			1stcheck
               	echo -en "This file only lets the script 'WoL.sh' know if it is the first start or not, please ignore." > .1st
			main
   		;;
# "Help" section
        h)
        	for name in README.txt
        	do
        	        [ -f $name ] || { echo -en "${RED}Readme file missing${RESET}\n";deps=1; }
        	done
        	        [[ $deps -ne 1 ]] && cat README.txt || { exit 1; }
        ;;
        v)
        	echo -e "$Ver"
        ;;
        l)
        	for name in LICENSE.txt
        	do
                	[ -f $name ] || { echo -en "${RED}License file missing${RESET}\n";deps=1; }
        	done
            	    [[ $deps -ne 1 ]] && cat LICENSE.txt || { exit 1; }
        ;;
        c)
        	echo -n "Checking for user config... "
        	for name in wol_config.cfg
        	do
            	    [ -f $name ] || { echo -en "${RED}Config file missing${RESET}\n";deps=1; }
        	done
            	    [[ $deps -ne 1 ]] && cat wol_config.cfg || { while true; do
                	read -p "Do you Want to create one from 'wol_config_example.cfg' [y/n]? " yn
                	case $yn in
                    	[Yy]* ) cp ./wol_config_example.cfg ./wol_config.cfg; nano -AKGPgmwpT 4 ./wol_config.cfg; break;;
                    	[Nn]* ) exit 1;;
                    		* ) echo "Please answer yes or no.";;
                	esac
    		done ;}
        ;;
        e)
    		for name in wol_config.cfg
        	do
              	  [ -f $name ] || { echo -en "${RED}Config file missing${RESET}\n";deps=1; }
        	done
            	  [[ $deps -ne 1 ]] && nano -AKGPgmwpT 4 ./wol_config.cfg || { exit 1; }
        ;;
        *)
                echo -en "Usage: ./WoL.sh {c|e|h|l|r|v}\n"
                echo -en " c, Current config.\n e, Edit current config.\n h, Help.\n l, License.\n r, Run main script.\n v, Version.\n"
		exit 1
                ;;
	esac
exit 0
#EoF
