#!/bin/bash
TARGET=192.168.0.200
PORT=220
USER=gramse
RSA=~/.ssh/update_rsa

ssh -i $RSA -l $USER $TARGET -p $PORT 'sudo systemctl suspend'

exit 0
#EoF
