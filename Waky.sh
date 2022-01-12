#!/bin/bash
BROADCAST=192.168.0.255
MAC=b0:83:fe:ae:d1:db
IFNAME=enp3s0

sudo etherwake -i $IFNAME $MAC -b $BROADCAST

exit 0
#EoF
