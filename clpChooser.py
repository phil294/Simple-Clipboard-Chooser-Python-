#!/usr/bin/env python

# called by shortcut or manually. shows a gui with the last 10 clps from db

import sqlite3
from Tkinter import *
import os.path
from functools import partial
import storeClp

__location__ = os.path.realpath(
    os.path.join(os.getcwd(), os.path.dirname(__file__)))

storeClp.store()

con = sqlite3.connect( os.path.join(__location__,'clps') )
con.text_factory = str
c = con.cursor()
c.execute('select clp from clps order by id desc limit 10')
clpsLast = [row[0] for row in c.fetchall()]
con.close()

root = Tk()
frame = Frame(root)
frame.pack()
root.minsize(width=700, height=30)

def selectedClp(which=-1, event=None):
	frame.quit()
	if(0 <= which < 10):
		root.clipboard_clear()
		root.clipboard_append(clpsLast[which])
		root.after(100, root.destroy)
		root.mainloop()
	
oddColor = False
for i,clpLast in enumerate(clpsLast):
	cmd = partial(selectedClp, i)
	clpLastTrunc = (clpLast[:65] + '[...]') if len(clpLast) > 65 else clpLast
	clpLastTrunc = clpLastTrunc.replace("\n", "\\n")
	oddColor = not oddColor
	if oddColor:
		color = "#0e2c5b"
	else:
		color = "#1c5b0e"
	line = Label(frame,
		text=str(i)+": "+clpLastTrunc,
		fg = color, width=88)
	line.pack()
	root.bind(i, cmd)

root.bind("<Escape>", selectedClp)

root.mainloop()

print("Substituted current clipboard successfully.")













