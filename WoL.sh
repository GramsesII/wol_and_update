#!/bin/bash

# Fancy variables no need to change these.
Ver=v1.66
GREEN='\e[0;32m'
RED='\e[0;31m'
YELLOW='\e[0;33m'
RESET='\e[0m'
SEC_COLOR=${RED}

# Log thingys
log=./log/"$(date +"%F-%T").log"
touch $log
exec 3>&1 4>&2
trap 'exec 2>&4 1>&3' 0 1 2 3 15
exec 1> >(tee -a "$log") 2>&1

echo -e "Wake on Lan ${YELLOW}$Ver${RESET} - ${GREEN}start${RESET}: $(date)"

# //Start of config\\
set -v
# Target Broadcast IP (i.e 192.168.0.255, get by running "ifconfig" on the target machine).
BROADCAST=192.168.0.255

# Target IP4 Macadress (looks like aa:bb:cc:dd:ee:ff, get by running "ifconfig" on the target machine).
MAC=b0:83:fe:ae:d1:db

# The name of your local machines network interface (i.e eth0 or enp3s0)
IFNAME=enp3s0

# Target machines IP4 number.
TARGET=192.168.0.200

# Target machines SSH port (default 22)
PORT=220

# Your username on the target machine. It will help if this user have 
# "YOUR_USERNAME_HERE ALL=(ALL) NOPASSWD: ALL" without the ""
# set in /etc/sudoers file. NOTE! the order in this file matters.
USER=gramse

# Were your SSH RSA key file are located on the local machine.
RSA=~/.ssh/update_rsa

# How many seconds do we wait for the target machine to reboot.
# Raise or lower this if needed.
SEC=60

# Please ignore the following one(1) row in the logfile.
set +v
# \\End of config//

# Start of the magic (magic packet, get it? ;).
	echo ""
		echo -e "${GREEN}Waking target up.${RESET}"
			sudo etherwake -i $IFNAME $MAC -b $BROADCAST
			sleep 5
	echo ""
		echo -e "${GREEN}Target gone woke, lets update it.${RESET}"
			ssh -i $RSA -l $USER $TARGET -p $PORT 'sudo apt-get update; sudo apt-get -y upgrade'
	echo ""
		echo -e "${GREEN}Update done! Rebooting target.${RESET}"
			ssh -i $RSA -l $USER $TARGET -p $PORT 'sudo shutdown -r now'
	echo ""
		echo -e "${GREEN}Waiting for the reboot to be done.${RESET}"
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
echo -e "${RESET}"
tput cnorm
	echo ""
		echo -e "${GREEN}Target rebooted, lets suspend it until next update.${RESET}"
			ssh -i $RSA -l $USER $TARGET -p $PORT 'sudo systemctl suspend'
	echo ""
		echo -e "${GREEN}Target put to sleep! Ending script.${RESET}"

	echo ""
		echo -e "Wake on Lan ${YELLOW}$Ver${RESET} - ${RED}stop${RESET}: $(date)"

exit 0
#EoF
