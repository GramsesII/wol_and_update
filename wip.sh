#!/bin/bash

#  develop branch
#  License: "(MIT)", (see LICENSE.txt for more info)
#  Author: "Christian Berg <gramse@pln.nu> (https://github.com/GramsesII/wol_and_update)"
#  Contributor(s): "That there decent man over there"

#  A simple Wake on Lan and update a target machine script.
#  This script is tested on Ubuntu 20.04 lts, Ubuntu 22.04 lts (release candidate)

#  Target machine depends on: ssh (openssh-client ), systemctl (systemd), apt-get, sftp (server).
#  Depends on: etherwake, ssh (openssh-client), systemctl (systemd), tee (coreutils), sftp (client).
#  Optional depends: dialog.

# //Internal variables change at your own risk.\\
VER="v1.666-c3"
GREEN='\e[0;32m'
RED='\e[0;31m'
YELLOW='\e[0;33m'
RESET='\e[0m'
# SEC_COLOR=${RED} #This color now sets in the 'fancy_timer' function.
config="./config/wol_config.cfg"
F1rst=".1st"
WSEC="5"
DO_RUN=0 #DO we actually run all commands.
# 1= run all.
# 0= skip all ssh, sftp, etherwake commands.
# This is for testing purposes only, for the actually wol.sh script it should allways be set to 1.

# \\Internal variables end.//

main(){
	log
		echo -e "Wake on Lan and update ${YELLOW}$VER${RESET} - ${GREEN}started${RESET}: $(date)\n"
	check_dep

	# //Start of config\\
	get_config
	# \\End of config//

	# Do we need to wake the target up berfore update?"
	if [[ $WAKEUP = yes ]]; then
		# Start of the magic (magic packet, get it? ;).
		echo -e "\n${GREEN}Waking target up.${RESET}\n"
			[[ $DO_RUN -eq 1 ]] &&	sudo etherwake -i $IFNAME $MAC -b $BROADCAST
		# This next step might be unecessary, but just to be shure target is up and running before we try anything I'll leave this 5sec countdown in.
		COUNTD="$WSEC"
		fancy_counter
		ping_check
		echo -e "${GREEN}Target gone woke.${RESET}\n"
	fi
	if [[ $WAKEUP = no ]]; then
		echo -en "\n${GREEN}Target allready supposed to be woke moving along${RESET}"
	fi

	# Should we? or should we not? update, thats! is the question.
	echo -e "${GREEN}Checking for updates.${RESET}\n"
	[[ $DO_RUN -eq 1 ]] && sftp -i $RSA -b ./config/sftp.push -P$PORT $SFTPUSER@$TARGET
	[[ $DO_RUN -eq 1 ]] && ssh -i $RSA -l $USER $TARGET -p $PORT '~/wol_uppy/wol_uppy.sh'
	[[ $DO_RUN -eq 1 ]] && sftp -i $RSA -b ./config/sftp.pull -P$PORT $SFTPUSER@$TARGET
	[[ $DO_RUN -eq 1 ]] && a1=$(cat ./wol_answer)

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
	COUNTD="$SEC"
	fancy_counter
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
			echo -en "${GREEN}This will be your config file.${RESET}\n"
			review

			while true; do
				read -p "Want to keep it? [y/n/c]: " ync
				case $ync in
					[Yy]* )
						echo -en "${GREEN}Saving config.${RESET}"
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
						echo -en "\n${GREEN}OK, let's end the suffering. Canceling${RESET}\n"
						exit 0
						;;
						* )
						echo -en "Please answer ${YELLOW}yes${RESET},${YELLOW}no${RESET} or ${YELLOW}cancel${RESET}."
						;;
					esac
			done
	return 0
	}

input()(
# Auto configure inputs

check_for_dia(){
  # Checking for dialog (new or old auto config).
  echo -n "Checking for dialog... "
      for name in dialog
      do
          if ! [[ $(which $name 2>/dev/null) ]]; then
              echo -en "\n${YELLOW}$name not found. Using old 'script'${RESET}\n" && old_auto;
          else values;
          fi
      done
  unset name
return 0
          }

dia(){
    dialog \
        --backtitle "Autoconfigure Script 2.0" \
        --title "$page" \
        --shadow \
        --inputbox "$text" 17 80 "$preset" 2> ./inputbox.tmp.$$
    retval=$?
    input=`cat ./inputbox.tmp.$$`
    rm -f ./inputbox.tmp.$$
        case $retval in
            0)
            echo -en "$value$input\n" >> $config
            ;;
            1)
            echo -en "\nCancel pressed.\n"
            ;;
            255)
            echo -en "\n[ESC] key pressed.\n"
            exit 1
        esac
    return
    }

values(){
#1/11
    text="\nTarget Broadcast IP.\n\n(i.e 192.168.0.255, get by running 'ifconfig' on the target machine)"
    preset=""
    value="BROADCAST="
    page="01/11"
    dia
#2/11
    text="\nTarget IP4 Macadress.\n\n(i.e aa:bb:cc:dd:ee:ff, get by running 'ifconfig' on the target machine)"
    preset=""
    value="MAC="
    page="02/11"
    dia
#3/11
    text="\nTarget machines IP.\n\n(i.e 192.168.0.254, get by running 'ifconfig' on the target machine)"
    preset=""
    value="TARGET="
    page="03/11"
    dia
#4/11
    text="\nTarget machines SSH port.\n\n(default for SSH is 22)"
    preset="22"
    value="PORT="
    page="04/11"
    dia
#5/11
    text="\nThe name of your local machines network interface.\n\n(i.e eth0 or enp3s0)"
    preset=""
    value="IFNAME="
    page="05/11"
#6/11
	text="\nYour SSH username on the target machine.\n\nIt will help if this user have\nYOUR_USER_NAME_HERE ALL=(ALL) NOPASSWD: /usr/bin/apt-get, /bin/systemctl\nset in /etc/sudoers file on the target machine,\nthis so you dont need to type in passwords 'all' the time.\n\nNOTE! the order in this file matters, try putting it before the last line.\n(edit with sudo visudo)."
    preset=""
    value="USER="
    page="06/11"
    dia
#7/11
    text="\nYour username for SFTP."
    preset=""
    value="SFTPUSER="
    page="07/11"
    dia
#8/11
    text="\nWere your SSH RSA key file are located on the local machine."
    preset=""
    value="RSA="
    page="08/11"
    dia
#9/11
	text="\nHow many seconds do we wait for the target machine to reboot\nRaise/lower this as needed.\n\n(SEC=60 will proplably do in most cases)"
    preset="60"
    value="SEC="
    page="09/11"
    dia
#10/11
    text="\nDo you want to suspend the target machine after reboot?\n\n(yes/no, if unsure set 'no')."
    preset="no"
    value="SUS="
    page="10/11"
    dia
#11/11
	text="\nAre the target machine already woke?\n\n(yes/no, problably 'no' if you set 'no' in the previous question)."
    preset="no"
    value="WAKEUP="
    page="11/11"
    dia

unset text value page
trap "rm -f ./inputbox.tmp.$$; exit" SIGHUP SIGINT SIGTERM
return
 }

old_auto(){
# Old Auto configure inputs
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
     echo -en "\nDo you want to suspend the target machine after the reboot? (yes/no, if unsure set SUS=no).\n";
         read -p ": " SUS;
     echo -en "Are the target machine allready woke? (yes/no).\n";
         read -p ": " WAKEUP;
return
}

check_for_dia
 )

review(){
# Config file part..
. "./config/wol_config.cfg" 
    echo -e "
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
SUS=$SUS
WAKEUP=$WAKEUP\n
# End of auto configured '$config'\n"
return 0
         }

log(){
# Log code
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
	for name in etherwake tee ssh systemctl sftp dialog
    do
    	if ! [[ $(which $name 2>/dev/null) ]]; then
        	[[ $failed -eq 0 ]] && echo -en "${RED}FAIL${RESET}\n"
            failed=1
            echo -en "\n${YELLOW}name needs to be installed. Use 'sudo apt-get install $name'${RESET}"
        fi
    done
    [[ $failed -eq 1 ]] && echo -en "\n\n${YELLOW}Install the above and rerun this script${RESET}\n" && exit 1;
	echo -e "${GREEN}OK${RESET}\n"
unset failed name
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

fancy_counter(){
	SEC_COLOR=${RED}
    if [[ $COUNTD -le 5 ]]; then
        Y1="4"
        G1="2"
    fi
    if [[ $COUNTD -ge 6 ]]; then
        Y1="30"
        G1="15"
    fi
    tput civis
	    echo -ne $COUNTD="${SEC_COLOR}"
        while [ $COUNTD -ge 0 ]; do
            if [ "$COUNTD" -le "$Y1" ]; then
                SEC_COLOR="${YELLOW}"
            fi
            if [ "$COUNTD" -le "$G1" ]; then
                SEC_COLOR="${GREEN}"
            fi
            printf "\r${RESET}continues in: ${SEC_COLOR}%02d${RESET} seconds." "$COUNTD"
            let "COUNTD=COUNTD-1"
            sleep 1s
#            sleep 0.2s #shortens time during testing, 1s (in config)=.2s (in reality)
        done
     echo -en "${RESET}\n"
    tput cnorm
    unset TEST Y1 G1 SEC_COLOR COUNTD
			   }
ping_check(){
# checks if target really are woke, exits if not.
	echo -en "\n${YELLOW}Pinging target to check if it's truly up.${RESET}\n\n"
	ping -n -q -c1 $TARGET
#	ping -n -q -c1 localhost #positive test
	check=$?
		if [[ $check -eq 0 ]]; then
			return
		fi
		if [[ $check -eq 1 ]]; then
			echo -en "${RED}Seems that target ain't woke after all, exiting script.${RESET}\n\n"
			exit 1
		fi
	unset check
			}
# Program starts here.
	case "$1" in
		r)
        	for name in README.txt
        	do
        	    [ -f $name ] || { echo -en "${RED}Readme file missing${RESET}\n";deps=1; }
        	done
        	[[ $deps -ne 1 ]] && cat README.txt || { exit 1; }
   		;;
        h)
            echo -en "Usage: ./wol.sh {c|e|h|l|r|v}\n"
            echo -en " c, Current config.\n e, Edit current config.\n h, Help.\n l, License.\n r, Readme.\n v, Version.\n"
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
			1stcheck
			main
       ;;
	esac
exit 0
#EoF
