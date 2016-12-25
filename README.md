# Simple-Clipboard-Chooser-Python-

Tested in Ubuntu.

- See your last clipboards ( clpChooser.py ), choose with hotkeys 0-9
- Have all your clipboard history backed up in a SQLite file

![gui](http://i.imgur.com/PqC2kXnl.png)

Setup:

Current clipboard gets stored into DB by storeClp.py. 

As a crontab: Crontabs do not have access to the session which is needed for accessing the clipboard. Granting display access as root:

	sudo crontab -e

	* * * * * /home/?/bin/clp/storeClpCronRoot.sh
	
Stores the  current clpboard every minute. Also adjust the storeClpCronRoot.sh accordingly.

Choose from your previous 10 clipboards by calling storeClp.py, e.g. with a shortcut.
