#!/bin/bash
# show a gui with the last x clps from db
# requires tkbash script (github)
# 20170919 @phil294
set -e

THISDIR="$(dirname "$(readlink -f "$0")")"
db="$1"
char() { printf "\x$(printf %x $1)" ;}

# store current first
"${THISDIR}/storeClp.sh" "$db"

tkbash clpchooser -w 1300 -h 415 --title "Clipboard Chooser"

IFS=$'\n'
clpsLast=($(sqlite3 "$db" "SELECT replace(clp, char(10), 'b926ac9569e69458a5c676eecf83bbf2') FROM clps ORDER BY id DESC LIMIT 26"))

add() {
	local i=$1
	local hotkey="$(char $(($i+97)))"
	local clp="${clpsLast[$i]//b926ac9569e69458a5c676eecf83bbf2/$'\n'}"
	local truncated="$(sed -E 's/(.{180}).+/\1.../' <<<"${clp//$'\n'/\\n}")" # >180 chars: ellipsis... / line break to \n-string
	# v escape single quotes: a'b -> a'"'"'b
	tkbash clpchooser --hotkey "$hotkey" --command "
		echo -n '${clp//\'/\'\"\'\"\'}' |xclip -sel c
		tkbash clpchooser --quit"
	local extra_space="$([[ $((i%2)) == 0 ]] && echo '     ')"
	label="${label} $hotkey   $extra_space $truncated"$'\n'
}

label=""
for i in {0..4}; do add $i; done
tkbash clpchooser label l1 -x 0 -y 0 -w 1300 -h 75 -t "$label"
label=""
for i in {5..25}; do add $i; done
tkbash clpchooser label l2 -x 0 -y 78 -w 1300 -h 345 -t "$label"

tkbash clpchooser --hotkey Escape --command "tkbash clpchooser --quit"
