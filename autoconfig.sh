#!/bin/bash
GREEN='\e[0;32m'
RED='\e[0;31m'
RESET='\e[0m'
config="config_file.cfg"
F1=".1st"
F2="config_file.cfg"

main(){
	echo -en "\n${GREEN}placeholder for wip.sh${RESET}\n"
	exit 0
	}

check(){
	if ! [[ -f $F1 ]]; then echo -en "\n${RED}First start 'auto-config creator'${RESET}\n";
		else
			if [[ -s $F2 ]]; then {echo -en "config present"; mv "$F2" "$F2-old"; }
			else
				echo -en "no config insight move along, move along...\n";
			fi
	fi
	}

input(){
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
		read -p ": " SEC; # }
	}

review(){
	echo -en "
# Start of auto configured '$config'\n
# More info about this config in 'wol_config_example.cfg'\n
\n
BROADCAST=$BROADCAST\n
MAC=$MAC\n
TARGET=$TARGET\n
PORT=$PORT\n
IFNAME=$IFNAME\n
USER=$USER\n
RSA=$RSA\n
SEC=$SEC\n
# End of auto configured '$config'\n"
	}

[[ -f $F1 ]] && main || check; input

#check
#input
	clear
	echo -en "This will be your config file.\n"
review
	echo -en "this file only lets the script (WoL.sh) know if it is the first start or not, please ignore" > .1st

while true; do
	read -p "Wanna keep it ^_^ [y/n]? " yn
	case $yn in
	[Yy]* ) review > $config; break;;
	[Nn]* ) input;;
	    * ) echo "Please answer yes or no.";;
	esac
 done
main

#EoF
