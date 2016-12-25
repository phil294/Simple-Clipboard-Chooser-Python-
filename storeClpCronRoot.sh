#!/bin/bash

# call this using "sudo crontab -e" (root crontab)

#tweak for crontab to work - http://askubuntu.com/questions/634473/how-do-you-copy-something-to-the-clipboard-when-running-a-script-triggered-by-in

export XAUTHORITY='/home/?/.Xauthority';
export DISPLAY=:0.0;
cd /home/?/bin/clp
./storeClp.py