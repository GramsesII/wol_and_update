#!/bin/bash
. wol_config.cfg
sftp_user='gramse'
sftp -i $RSA -b ./sftp.push -P$PORT $sftp_user@$TARGET
ssh -i $RSA -l $USER $TARGET -p $PORT '/home/gramse/wol_uppy/wol_uppy.sh'
sftp -i $RSA -b ./sftp.pull -P$PORT $sftp_user@$TARGET

a1=`cat wol_answer`
echo $a1
if [[ $a1 = yes ]]; then
echo -en "\nparty\n"
fi
	if [[ $a1 = no ]]; then
	echo -en "\nsorry better luck next time\n"
	fi
rm -f ./wol_answer
exit
#EoF
