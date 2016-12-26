#!/usr/bin/env python

# this is called by storeClip.sh or by the user manually

import sqlite3
import Tkinter as tk
import os.path

def store():

	__location__ = os.path.realpath(
		os.path.join(os.getcwd(), os.path.dirname(__file__)))
	db = os.path.join( __location__,'clps' )
	
	createTable = False
	if not os.path.isfile(db):
		createTable = True
		
	con = sqlite3.connect( db )
	con.text_factory = str
	c = con.cursor()
	
	if createTable:
		c.execute('CREATE TABLE clps (id integer primary key autoincrement, datetime integer, clp text);')
		con.commit()
		print("Created table")

	root = tk.Tk()
	root.withdraw()
	try:
		clp = root.clipboard_get()
	except:
		print("Could not get clipboard: Probably bitmap, blob etc.")
		return
	if not isinstance(clp, str):
		print("Clipboard is no string")
		return

	#is only 1-x files? #disabled
	"""
	only_files = True
	for line in clp.split("\n"):
		if not os.path.isfile(line):
			only_files = False
			break
	if only_files:
		print("Clipboard is list of files")
		return
	"""
		
	#truncate
	clp = clp[:2000]

	c.execute('select clp from clps order by id desc limit 10')
	clpsLast = [row[0] for row in c.fetchall()]

	#used previously?
	for clpLast in clpsLast:
		if clpLast == clp:
			print("Clipboard '"+clp+"' already in previous 10 clps contained")
			return

	tupel_wtf = (clp,)
	c.execute("insert into clps (datetime, clp) values (datetime('now'), ? );", tupel_wtf)
	con.commit()

	con.close()

	print("Inserted clipboard successfully.")

if __name__ == "__main__":
	store()











