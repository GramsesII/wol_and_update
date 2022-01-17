#!/bin/bash
GREEN='\e[0;32m'
RED='\e[0;31m'
RESET='\e[0m'
start:
        for name in .1st wol_config.cfg
        do
                [ -f $name ] || { echo -en "${RED}First start 'auto-config creator'${RESET}\n";deps=1; }
        done
                [[ $deps -ne 1 ]] && echo -ne "opa opa!" || {
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
			read -p ": " SEC; }

config="config_file.cfg"
#echo -ne "
# Start of auto configured '$config'
# More info about this config in 'wol_config_example.cfg'

#BROADCAST=$BROADCAST\n
#MAC=$MAC\n
#TARGET=$TARGET\n
#PORT=$PORT\n
#IFNAME=$IFNAME\n
#USER=$USER\n
#RSA=$RSA\n
#SEC=$SEC\n
# End of auto configured '$config'
#" >> $config

echo -en "this file only lets the script (WoL.sh) know if it is the first start or not, please ignore" > .1st
#clear
#echo -en "your $config looks like this"
#cat $config
while true; do
            echo -en "This will be your config file want to keep it.\n" && 
		{ cat "
# Start of auto configured '$config'
# More info about this config in 'wol_config_example.cfg'

BROADCAST=$BROADCAST\n
MAC=$MAC\n
TARGET=$TARGET\n
PORT=$PORT\n
IFNAME=$IFNAME\n
USER=$USER\n
RSA=$RSA\n
SEC=$SEC\n
# End of auto configured '$config'
" }
            read -p "[y/n]? " yn
            case $yn in
            [Yy]* ) { echo -en "
# Start of auto configured '$config'
# More info about this config in 'wol_config_example.cfg'

BROADCAST=$BROADCAST\n
MAC=$MAC\n
TARGET=$TARGET\n
PORT=$PORT\n
IFNAME=$IFNAME\n
USER=$USER\n
RSA=$RSA\n
SEC=$SEC\n
# End of auto configured '$config'
" >> $config; break;; }
            [Nn]* ) jumpto $start;;
            * ) echo "Please answer yes or no.";;
            esac
        done

exit 0
#EoF
