#!/bin/bash
Ver=v1.66

log=./log/"$(date +"%F-%T").log"
touch $log


exec 3>&1 4>&2
trap 'exec 2>&4 1>&3' 0 1 2 3 15
echo "Wake on Lan $Ver - start:$(date)" >&3
exec 1> >(tee -a "$log") 2>&1

set -v
BROADCAST=192.168.0.255
MAC=b0:83:fe:ae:d1:db
IFNAME=enp3s0
TARGET=192.168.0.200
PORT=220
USER=gramse
RSA=~/.ssh/update_rsa
WAIT=60
set +v

echo "placeholder 1 start"
#sudo etherwake -i $IFNAME $MAC -b $BROADCAST
#sleep 5
echo "placeholder 2 start"
#ssh -i $RSA -l $USER $TARGET -p $PORT 'sudo apt-get update; sudo apt-get -y upgrade'
echo "placeholder 3 start"
#ssh -i $RSA -l $USER $TARGET -p $PORT 'sudo shutdown -r now'
echo "placeholder 4 start"

sleep $WAIT
echo "placeholder 5 start"
#ssh -i $RSA -l $USER $TARGET -p $PORT 'sudo systemctl suspend'
echo "placeholder 1 ending"

echo "Wake on Lan $Ver - stop:$(date)" >&3

exit 0
#EoF
