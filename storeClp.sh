#!/bin/bash

db="$1"

if [ -z "$db" ]; then
	echo "no database given" >&2
	exit 1
fi
	
if ! [ -f "$db" ]; then
	IFS=$'\n'
	sqlite3 "$db" "CREATE TABLE clps (id integer primary key autoincrement, datetime integer, clp text);"
	echo "Created table" >&2
fi

clp="$(xclip -sel c -o)"
[ -z "$clp" ] && echo "clipboard empty / nonstring." >&2 && exit 0
truncated="${clp:0:10000}"

newline_mock="b926ac9569e69458a5c676eecf83bbf2"
IFS=$'\n'
clpsLast=($(sqlite3 "$db" "SELECT replace(clp, char(10), '$newline_mock') FROM clps order by id desc limit 26"))
clpsLast=("${clpsLast[@]//$newline_mock/$'\n'}")

for i in "${clpsLast[@]}"; do
	[[ "$i" == "${truncated//$newline_mock/$'\n'}" ]] && echo "Clipboard \"$truncated\" already in previous 26 clps contained" >&2 && exit 0
done

sqlite3 "$db" "insert into clps (datetime, clp) values (datetime('now'), '${truncated//\'/\'\'}');"
echo "Inserted clipboard \"$truncated\" successfully." >&2

exit 0