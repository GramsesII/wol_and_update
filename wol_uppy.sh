#!/bin/bash

APTCHECK="/usr/lib/update-notifier/apt-check"

check_data=$($APTCHECK 2>&1)
regex="^([0-9]+);([0-9]+)$"

if [[ "$check_data" =~ $regex ]]
then
  if [[ ${BASH_REMATCH[1]} -ne 0 ]] || [[ ${BASH_REMATCH[2]} -ne 0 ]]
  then
  	echo -en "\nupdate\n" # line to be removed once done
  	uptest=yes
  	echo -en "$uptest\n" > ./wol_uppy/wol_answer
    exit 0
  fi
fi
echo -en "\nnothing\n" # line to be removed once done
uptest=no
echo -en "$uptest\n" > ./wol_uppy/wol_answer
exit 1

#EoF
