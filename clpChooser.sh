#!/bin/bash
# show a gui with the last x clps from db
# requires tkbash script (github)
# 20170919 @phil294
set -e

THISDIR="$(dirname "$(readlink -f "$0")")"
db="${THISDIR}/clps"
char() { printf "\x$(printf %x $1)" ;}

# store current first
"${THISDIR}/storeClp.sh"

tkbash clpchooser window -w 1300 -h 370 --title "Clipboard Chooser"

IFS=$'\n'
clpsLast=($(sqlite3 "$db" "SELECT replace(clp, char(10), 'b926ac9569e69458a5c676eecf83bbf2') FROM clps ORDER BY id DESC LIMIT 26"))

add() {
	local i=$1
	local hotkey="$(char $(($i+97)))"
	local clp="${clpsLast[$i]//b926ac9569e69458a5c676eecf83bbf2/$'\n'}"
	local truncated="$(sed -E 's/(.{180}).+/\1.../' <<<"${clp//$'\n'/\\n}")" # >180 chars: ellipsis... / line break to \n-string
	# v escape single quotes: a'b -> a'"'"'b
	tkbash clpchooser window --hotkey "$hotkey" --command "
		echo -n '${clp//\'/\'\"\'\"\'}' |xsel -ib
		tkbash clpchooser window --quit"
	local extra_space="$([[ $((i%2)) == 0 ]] && echo '   ')"
	label="${label} $hotkey   $extra_space $truncated"$'\n'
}

label=""
for i in {0..4}; do add $i; done
tkbash clpchooser label l1 -x 0 -y 0 -w 1300 -h 75 -t "$label"
label=""
for i in {5..25}; do add $i; done
tkbash clpchooser label l2 -x 0 -y 71 -w 1300 -h 295 -t "$label"

tkbash clpchooser window --hotkey Escape --command "tkbash clpchooser window --quit"