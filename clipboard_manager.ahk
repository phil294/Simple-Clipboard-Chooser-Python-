; Tested on and developed for Linux with AHK_X11. Almost compatible wiht Windows too, but in that case sqlite invocation does not work and should rather use a proper library instead of `RunWait, sqlite3` stuff

; To use, #Include this script an call GoSub, init_clipboard_manager

Return

init_clipboard_manager:
	if clps_db =
	{
		msgbox variable clps_db needs to be set
		exitapp 1
	}
	clps_entry_show_length = 50

	Hotkey, ~^x up, clipboard_manager_store
	Hotkey, ~^c up, clipboard_manager_store
	Hotkey, ~^!c up, clipboard_manager_store
	Hotkey, ~^+c up, clipboard_manager_store

	Hotkey, ^!+c, clipboard_manager_select
Return

clipboard_manager_store:
	settimer, clipboard_manager_new_clipboard, 1000 ; debounce
	return
	clipboard_manager_new_clipboard:
	settimer, clipboard_manager_new_clipboard, off
	clp = %clipboard%
	if clp = ; picture, file, ..
		return

	stringmid, clp, clp, 1, 3500
	
	newline_mock = b926ac9569e69458a5c676eecf83bbf21
	runwait sqlite3 -init /dev/null "%clps_db%" "SELECT replace(clp`, char(10)`, '%newline_mock%') FROM clps order by id desc limit %clps_entry_show_length%",,,, clps_last
	already_contained = 0
	loop, parse, clps_last, `n
	{
		stringreplace, clp_last, a_loopfield, %newline_mock%, `n, all
		if clp = %clp_last%
		{
			already_contained = 1
			break
		}
	}
	clps_last =

	stringreplace, clp, clp, ', '', all
	if already_contained = 1
		echo clipboard %clp% already in previous %clps_entry_show_length% clps contained
	else
	{
		run notify-send u_%clp%_u
		runwait sqlite3 -init /dev/null "%clps_db%" "insert into clps(datetime`, clp) values (datetime('now')`, '%clp%');"
	}
	clp =
return

clipboard_manager_select:
	newline_mock = b926ac9569e69458a5c676eecf83bbf21
	runwait sqlite3 -init /dev/null "%clps_db%" "SELECT replace(clp`, char(10)`, '%newline_mock%') FROM clps order by id desc limit %clps_entry_show_length%",,,, clps_last
	txt = Type a number + SPACE or ESCAPE to cancel.`n`n
	loop, parse, clps_last, `n
	{
		stringreplace, clp_last, a_loopfield, %newline_mock%, `n, all
		clps_%a_index% = %clp_last%
		stringmid, clp_last, clp_last, 1, 180
		stringreplace, clp_last, clp_last, `n, \n, all
		txt = %txt% %a_index%	%clp_last%`n
	}
	clps_last =
	gui, add, text,, %txt%
	txt =
	gui, show, x0 y0, ahk clipboard manager
	winget, gui_win_id, id, ahk clipboard manager
	winset, alwaysontop, on, ahk_id %gui_win_id%
	gui_win_id =
	selection =
	Loop
	{
		Input, key, L1 V T500, {Escape}{Space}
		If ErrorLevel = EndKey:escape
			selection =
		If ErrorLevel <> Max
			Break
		selection = %selection%%key%
	}
	key =
	clp =
	StringLeft, clp, clps_%selection%, 100000
	selection =
	If clp <>
		clipboard = %clp%
	gui destroy
	clp =
	loop, %clps_entry_show_length%
		clps%a_index% =
return