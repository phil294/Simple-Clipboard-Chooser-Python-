#!/bin/bash

THISDIR="$(dirname "$(readlink -f "$0")")"
db="${THISDIR}/clps"
	
if ! [ -f "$db" ]; then
	IFS=$'\n'
	sqlite3 "$db" "CREATE TABLE clps (id integer primary key autoincrement, datetime integer, clp text);"
	echo "Created table"
fi

clp="$(xclip -sel c -o)"
[ -z "$clp" ] && echo "clipboard empty / nonstring." && exit 0
truncated="${clp:0:10000}"

IFS=$'\n'
clpsLast=($(sqlite3 "$db" "SELECT replace(clp, char(10), 'b926ac9569e69458a5c676eecf83bbf2') FROM clps order by id desc limit 26"))
clpsLast=("${clpsLast[@]//b926ac9569e69458a5c676eecf83bbf2/$'\n'}")

for i in "${clpsLast[@]}"; do
	[[ "$i" == "${truncated//b926ac9569e69458a5c676eecf83bbf2/$'\n'}" ]] && echo "Clipboard \"$truncated\" already in previous 26 clps contained" && exit 0
done

sqlite3 "$db" "insert into clps (datetime, clp) values (datetime('now'), '${truncated//\'/\'\'}');"
echo "Inserted clipboard \"$truncated\" successfully."
