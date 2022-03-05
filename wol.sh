#!/bin/bash

#  develop branch
#  License: "(MIT)", (see LICENSE.txt for more info)
#  Author: "Christian Berg <gramse@pln.nu> (https://github.com/GramsesII/wol_and_update)"
#  Contributor(s): "That there decent man over there"

#  A simple Wake on Lan and update a target machine script.
#  This script is tested on Ubuntu 20.04 lts.
#  Target machine depends on: ssh (openssh-client ), systemctl (systemd), apt-get, sftp (server).
#  Depends on: etherwake, ssh (openssh-client), systemctl (systemd), tee (coreutils), sftp (client).

# //Internal variables change at your own risk.\\
VER="v1.666-a"
GREEN='\e[0;32m'
RED='\e[0;31m'
YELLOW='\e[0;33m'
RESET='\e[0m'
SEC_COLOR=${RED}
config="./config/wol_config.cfg"
F1rst=".1st"
DO_RUN=1	#DO we actually run all commands.
# 1= run all.
# 0= skip all ssh, sftp, etherwake commands.
# This is for testing purposes only, not for the actually wol.sh script.

# \\Internal variables end.//

main(){
	log
		echo -e "Wake on Lan and update ${YELLOW}$VER${RESET} - ${GREEN}started${RESET}: $(date)\n"
	check_dep

# //Start of config\\
	get_config
# \\End of config//

# Start of the magic (magic packet, get it? ;).
echo -e "${GREEN}Waking target up.${RESET}\n"
	[[ $DO_RUN -eq 1 ]] &&	sudo etherwake -i $IFNAME $MAC -b $BROADCAST
	[[ $DO_RUN -eq 1 ]] &&	sleep 5s
echo -e "${GREEN}Target gone woke.${RESET}\n"

# Should we? or should we not! update, thats! the question.
echo -e "${GREEN}Checking for updates.${RESET}\n"
	[[ $DO_RUN -eq 1 ]] && sftp -i $RSA -b ./config/sftp.push -P$PORT $SFTPUSER@$TARGET
	[[ $DO_RUN -eq 1 ]] && ssh -i $RSA -l $USER $TARGET -p $PORT '~/wol_uppy/wol_uppy.sh'
	[[ $DO_RUN -eq 1 ]] && sftp -i $RSA -b ./config/sftp.pull -P$PORT $SFTPUSER@$TARGET
		a1=$(cat ./wol_answer)
#  echo $a1
	if [[ $a1 = yes ]]; then
		echo -en "\n${GREEN}party let's update.${RESET}\n"
	update
	fi
     	if [[ $a1 = no ]]; then
     		echo -en "\n${RED}sorry no updates this time, no party for you.${RESET}\n"
     	fi
# cleaning up
rm -f ./wol_answer

# Check if we are interested in suspending the target or not.
			if [[ $SUS = yes ]]; then
				echo -e "${GREEN}Lets suspend target machine until next update.${RESET}\n";
				[[ $DO_RUN -eq 1 ]] && ssh -i $RSA -l $USER $TARGET -p $PORT 'sudo systemctl suspend';
				echo -e "${GREEN}Target put to sleep! Ending script.${RESET}\n";
			fi
			if [[ $SUS = no ]]; then
				echo -e "${GREEN}Skipping the suspend step.${RESET}\n";
			fi

echo -en "Wake on Lan ${YELLOW}$VER${RESET} - ${RED}stop${RESET}: $(date)\n"
echo -en "This file only lets the script 'wol.sh' know if it is the first start or not, please ignore." > .1st
exit 0
	}

update(){
		[[ $DO_RUN -eq 1 ]] && ssh -i $RSA -l $USER $TARGET -p $PORT 'sudo apt-get update'
		[[ $DO_RUN -eq 1 ]] && ssh -i $RSA -l $USER $TARGET -p $PORT 'sudo apt-get -y upgrade'
			echo -e "${GREEN}Update done! Rebooting target.${RESET}\n"
		[[ $DO_RUN -eq 1 ]] && ssh -i $RSA -l $USER $TARGET -p $PORT 'sudo systemctl reboot --now'
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
						sleep 1s
					done
				echo -e "${RESET}\n"
			tput cnorm
# End of reboot counter
		echo -e "${GREEN}Target rebooted${RESET}\n"
	return
		}

1stcheck(){
# Check if this is the first start and if there are an old config file.
	if ! [[ -f $F1rst ]]; then echo -en "\n${RED}First start 'auto-config creator'${RESET}\n";
		else main;
	fi
		text='Do you want to keep your old config. '
		y1='main'
		n1='break 2>/dev/null'
		if [[ -s $config ]]; then { yeano "$y1" "$n1"; }
		fi
			input
			clear
				echo -en "This will be your config file.\n"
			review

			while true; do
					read -p "Want to keep it? [y/n/c]: " ync
					case $ync in
						[Yy]* )
							mv -f ./$config ./$config-old
							review > $config
							break
						;;
						[Nn]* )
							clear
							echo -en "${GREEN}OK, let's start over${RESET}"
							input
							clear
							echo -en "${GREEN}This will be your config file.${RESET}\n"
							review
						;;
						[Cc]* )
							echo -en "\n${GREEN}OK, let's end the suffering.${RESET}\n"
							exit 0
						;;
							* )
							echo -en "Please answer ${YELLOW}yes${RESET},${YELLOW}no${RESET} or ${YELLOW}cancel${RESET}."
						;;
					esac
			done
	return 0
	}

input(){
# Auto configure inputs
        echo -en "\nTarget Broadcast IP (i.e 192.168.0.255, get by running 'ifconfig' on the target machine).\n";
        read -p ": " BROADCAST;
        echo -en "\nTarget IP4 Macadress (looks like aa:bb:cc:dd:ee:ff, get by running 'ifconfig' on the target machine).\n";
        read -p ": " MAC;
        echo -en "\nTarget machines IP4 number.\n";
        read -p ": " TARGET;
        echo -en "\nTarget machines SSH port (default for SSH is 22).\n";
        read -p ": " PORT;
        echo -en "\nThe name of your local machines network interface (i.e eth0 or enp3s0).\n";
        read -p ": " IFNAME;
        echo -en "\nYour SSH username on the target machine. It will help if this user have\n";
        echo -en "'YOUR_USER_NAME_HERE ALL=(ALL) NOPASSWD: /usr/bin/apt-get, /bin/systemctl' without the ''\n";
        echo -en "set in /etc/sudoers file on the target machine, this so you dont need to type in passwords 'all' the time.\n";
        echo -en "NOTE! the order in this file matters, try putting it before the last line, (edit with sudo visudo).\n";
        read -p ": " USER;
		echo -en "\nYour username for SFTP\n";
		read -p ": " SFTPUSER;
        echo -en "\nWere your SSH RSA key file are located on the local machine.\n";
        read -p ": " RSA;
        echo -en "\nHow many seconds do we wait for the target machine to reboot\n";
        echo -en "Raise or lower this if needed (SEC=60 will proplably do in most cases).\n";
        read -p ": " SEC;
        echo -en "Do you want to suspend the target machine after the reboot? yes/no (default SUS=no).\n";
		read -p ": " SUS;
    return 0
    }

review(){
# Config file part..
    echo -en "
# Start of auto configured '$config'
# More info about this config in 'wol_config_example.cfg'\n
BROADCAST=$BROADCAST
MAC=$MAC
TARGET=$TARGET
PORT=$PORT
IFNAME=$IFNAME
USER=$USER
SFTPUSER=$SFTPUSER
RSA=$RSA
SEC=$SEC
SUS=$SUS\n
# End of auto configured '$config'\n"
return 0
    }

log(){
# Log thingys
# Lets check if the log dir. exist if not lets create it.
    	if [ ! -d "./log" ]; then
        	mkdir -v ./log;
    	fi
# Some more logfile witchcraftery.
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
        for name in etherwake tee ssh systemctl sftp
        do
                if ! [[ $(which $name 2>/dev/null) ]]; then
                        [[ $failed -eq 0 ]] && echo -en "${RED}FAIL${RESET}\n"
                        failed=1
                        echo -en "\n${YELLOW}name needs to be installed. Use 'sudo apt-get install $name'${RESET}"
                fi
        done
        [[ $failed -eq 1 ]] && echo -en "\n\n${YELLOW}Install the above and rerun this script${RESET}\n" && exit 1;
	echo -e "${GREEN}OK${RESET}\n"
unset failed  name
return 0
		}

get_config(){
	DIR="${BASH_SOURCE%/*}"
	cd $DIR
# Checking if user config file are present.
	echo -n "Checking for user config... "
    	for name in $config
    	do
        	[ -f $name ] || { echo -en "${RED}FAIL${RESET}\n";deps=1; }
    	done
        	[[ $deps -ne 1 ]] && echo -e "${GREEN}OK${RESET}\n" || { echo -en "\nCreate a new wol_config.cfg from the wol_config_example.cfg\n";exit 1; }
	unset name deps
	set -v
		. "$config"
	set +v # Please ignore this row in the logfile.
return 0
		}

yeano(){
        read -p "$text [y/n]? " yn
            case $yn in
                [Yy]* ) eval $1;;
                [Nn]* ) eval $2;;
                    * ) echo "Yes or no please.";;
            esac
        unset text y1 n1
    return 0
        }

# Program starts here.
	case "$1" in
		r)
			1stcheck
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
        	echo -e "$VER"
        ;;
        l)
        	for name in LICENSE.txt
        	do
                	[ -f $name ] || { echo -en "${RED}License file missing${RESET}\n";deps=1; }
        	done
            	    [[ $deps -ne 1 ]] && cat LICENSE.txt || { exit 1; }
        ;;
        c)
			text="Do you Want to manualy create one from 'wol_config_example.cfg' "
			y1="cp ./config/wol_config_example.cfg ./config/wol_config.cfg && nano -T 4 ./config/wol_config.cfg"
			n1="exit 1"
        	echo -en "Checking for user config... \n\n"
        	for name in $config
        	do
            	    [ -f $name ] || { echo -en "${RED}Config file missing${RESET}\n";deps=1; }
        	done
            	    [[ $deps -ne 1 ]] && cat $config || { yeano "$y1" "$n1"; }
        ;;
        e)
    		for name in $config
        	do
              	  [ -f $name ] || { echo -en "${RED}Config file missing${RESET}\n";deps=1; }
        	done
            	  [[ $deps -ne 1 ]] && nano -T 4 ./$config || { exit 1; }
        ;;
        *)
                echo -en "Usage: ./wol.sh {c|e|h|l|r|v}\n"
                echo -en " c, Current config.\n e, Edit current config.\n h, Help.\n l, License.\n r, Run main script.\n v, Version.\n"
		exit 1
                ;;
	esac
		unset name deps
exit 0
#EoF
