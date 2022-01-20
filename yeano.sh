#!/bin/bash
echo -ne "' ̿'\̵͇̿̿\з=(O_o)=ε/̵͇̿̿/'̿'̿ ̿"
yeano(){
  		read -p "$text y/n " yn
			case $yn in
				[Yy]* ) eval $1;;
				[Nn]* ) eval $2;;
					* ) echo "You didn't do anything...";;
			esac
		unset text y1 n1
	return 0
		}
text='come on, do it!'
y1='echo Hi there && ls -l'
n1='echo Bye there && ls'

yeano "$y1" "$n1"

exit 0
#EoF
