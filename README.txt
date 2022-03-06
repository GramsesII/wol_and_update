Short explanation of files and dir(s). used by 'Wake on Lan and upgrade' script.
--------------------------------------------------------------------------------

This project is the result of me not wanting to type 4 lines every time I need
to update a backup machine running a html/team speak server. And I needed a
project to take my mind of things. This script is what it is, it was/is a fun
project no more no less :) I am by no means a pro when we talk about making code.

But it was fun to do. Ideas for future updates are more then welcome either it's
code or just ideas to improve functionality.


						Start script by running wol.sh x were x is:

						c	-	Shows current config.
						e	-	Edit current cinfig file.
						h	-	"Help" shows the README file.
						l	-	Shows the LICENSE file.
						r	-	Run the main script
						v	-	Shows script version.


						Main branch contains these files.
						---------------------------------

wol.sh					- Main script file. It's sole purpose is to wake up
						the target machine and run an package update/reboot
						and suspend the target.

wol_config.cfg			- User configureable settings used by WoL.sh
						Gets created eihter from running the script for the
						first time or by manually edit the example config file.

wol_config_example.cfg	- Use this file to create your config file.
						Short explanation of each config option inside.

LICENSE.txt				- Short explanation of the MIT license under which
						this script are released.

README.txt				- This file.

log (DIR.)				- Where the log files are saved, if not present at
						the scripts first start it will be created for you.
						in the dir that you are running from.

.1st					- This file lets the scipt know if it is the first start
						or not. If this file exist the script skips alot of
						code regarding to setup. 

						NOTE. the script will still check if a cofig file
							  is present before running.


config (DIR.)			- Configs directory.

wol_uppy (DIR.)			- Directory for remote files.

wol_uppy.sh				- Runs a test on the target machine to see if there are
						any new updates that needs to be installed.
						
wol_uppy.txt			- This file only explains what the dir. (wol_uppy),
						wol_uppy.sh/txt and wol_answer are and why they are there
						incase my script fails to remove them from the target machine.
						
sftp.push				- Directs sftp to were to push "wol_uppy.sh and wol_uppy.txt"

sftp.pull				- Tells sftp to pull "wol_answer" from the target maschine,
						and cleans up what was dun in sftp.push.

TODO.txt				- My reminder  of what to do. Will problably be moved
						to develop branch in the future.
						
						In develop branch there is also this file.
						------------------------------------------

wip.sh					- Work in progress, used for testing things do not
						use this file, use the main 'wol.sh' instead.
						Moved to develop branch only.

