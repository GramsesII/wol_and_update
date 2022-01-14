#!/bin/bash
# A simple Wake on Lan and update target machine script.
# Depends on: etherwake, ssh (openssh-client), systemctl (systemd), tee (coreutils)

# Fancy variables no need to change these.
Ver=v1.66
GREEN='\e[0;32m'
RED='\e[0;31m'
YELLOW='\e[0;33m'
RESET='\e[0m'
SEC_COLOR=${RED}

# Log thingys
# Lets check if the log dir. exist if not lets create it.
	if [ ! -d "./log" ]; then
		mkdir -v ./log;
	fi
log=./log/"$(date +"%F-%T").log"
touch $log
exec 3>&1 4>&2
trap 'exec 2>&4 1>&3' 0 1 2 3 15
exec 1> >(tee -a "$log") 2>&1

echo -e "Wake on Lan and update ${YELLOW}$Ver${RESET} - ${GREEN}started${RESET}: $(date)\n"

echo -n "Checking dependencies... "
	for name in etherwake tee ssh systemctl
	do
		[[ $(which $name 2>/dev/null) ]] || { echo -en "\n$name needs to be installed. Use 'sudo apt-get install $name'";deps=1; }
	done
		[[ $deps -ne 1 ]] && echo -e "${GREEN}OK${RESET}\n" || { echo -en "\nInstall the above and rerun this script\n";exit 1; }

# //Start of config\\
set -v
# Target Broadcast IP (i.e 192.168.0.255, get by running "ifconfig" on the target machine).
BROADCAST=192.168.0.255

# Target IP4 Macadress (looks like aa:bb:cc:dd:ee:ff, get by running "ifconfig" on the target machine).
MAC=b0:83:fe:ae:d1:db

# Target machines IP4 number.
TARGET=192.168.0.200

# Target machines SSH port (default 22)
PORT=220

# The name of your local machines network interface (i.e eth0 or enp3s0)
IFNAME=enp3s0

# Your SSH username on the target machine. It will help if this user have
# "YOUR_USER_NAME_HERE ALL=(ALL) NOPASSWD: /usr/bin/apt-get, /bin/systemctl" without the ""
# set in /etc/sudoers file on the target machine, this so you dont need to type in passwords "all" the time.
# NOTE! the order in this file matters, try putting it before the last line, (edit with sudo visudo).
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
	echo -e "${GREEN}Waking target up.${RESET}\n"
		sudo etherwake -i $IFNAME $MAC -b $BROADCAST
		sleep 5
	echo -e "${GREEN}Target gone woke, lets update it.${RESET}\n"
		ssh -i $RSA -l $USER $TARGET -p $PORT 'sudo apt-get update; sudo apt-get -y upgrade'
	echo -e "${GREEN}Update done! Rebooting target.${RESET}\n"
		ssh -i $RSA -l $USER $TARGET -p $PORT 'sudo systemctl reboot --now'
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
		ssh -i $RSA -l $USER $TARGET -p $PORT 'sudo systemctl suspend'
	echo -e "${GREEN}Target put to sleep! Ending script.${RESET}\n"

	echo -e "Wake on Lan ${YELLOW}$Ver${RESET} - ${RED}stop${RESET}: $(date)\n"

exit 0
#EoF
