#!/usr/bin/env python
import sys
if sys.version[:3] == '1.4':
	import ni

from gtk import *
from gnome.ui import *

def message_dlg_clicked(widget, button):
	if button == 0:
		mainquit()

def message_dlg(widget, event=None):
	box = GnomeMessageBox("Reallly quit?", "question",
			      STOCK_BUTTON_YES, STOCK_BUTTON_NO)
	box.connect("clicked", message_dlg_clicked)
	box.set_modal(TRUE)
	box.show()
	return TRUE

def about_dlg(button):
	GnomeAbout('gVocabTrainer', '0.0a', '(C) 2000 Alexander Kellett', 
				['Alexander Kellett'], 'very basic non working gui').show()

def create_menu():
	file_menu = [
		UIINFO_ITEM_STOCK('New...', None, None, STOCK_MENU_NEW),
		UIINFO_ITEM_STOCK('Open...', None, None, STOCK_MENU_OPEN),
		UIINFO_ITEM_STOCK('Save', None, None, STOCK_MENU_SAVE),
		UIINFO_ITEM_STOCK('Save as...', None, None, STOCK_MENU_SAVE_AS),
		UIINFO_SEPARATOR,
		UIINFO_ITEM_STOCK('Quit', None, message_dlg, STOCK_MENU_QUIT)
	]
	edit_menu = [
		UIINFO_ITEM_STOCK('Preferences...', None, None, STOCK_MENU_PREF),
		UIINFO_ITEM_STOCK('Scores...', None, None, STOCK_MENU_SCORES)
	]
	help_menu = [
		UIINFO_ITEM_STOCK('About', None, about_dlg, STOCK_MENU_ABOUT)
	]
	menu_info = [
		UIINFO_SUBTREE('File', file_menu),
		UIINFO_SUBTREE('Edit', edit_menu),
		UIINFO_SUBTREE('Help', help_menu)
	]
	return menu_info

def create_toolbar():
	toolbar_info = [
		UIINFO_ITEM_STOCK('New', None, None, STOCK_PIXMAP_NEW),
		UIINFO_SEPARATOR,
		UIINFO_ITEM_STOCK('Open', None, None, STOCK_PIXMAP_OPEN),
		UIINFO_ITEM_STOCK('Save', None, None, STOCK_PIXMAP_SAVE),
		UIINFO_ITEM_STOCK('Save as', None, None, STOCK_PIXMAP_SAVE_AS),
		UIINFO_SEPARATOR,
		UIINFO_ITEM_STOCK('Cut', None, None, STOCK_PIXMAP_CUT),
		UIINFO_ITEM_STOCK('Copy', None, None, STOCK_PIXMAP_COPY),
		UIINFO_ITEM_STOCK('Paste', None, None, STOCK_PIXMAP_PASTE),
	]
	return toolbar_info

def main():
	win = GnomeApp('stock_demo', 'gVocabTrainer')
	win.set_wmclass('stock_test', 'gVocabTrainer')
	win.connect('delete_event', message_dlg)
	win.connect('destroy', mainquit)

	win.create_menus(create_menu())
	win.create_toolbar(create_toolbar())

	vbox = GtkVBox(spacing=3)
	vbox.show()

	w = GtkText()
	w.show()
	vbox.pack_start(w, fill=FALSE)

	#w = GtkText()
	#w.show()
	#vbox.pack_start(w, fill=FALSE)

	win.set_contents(vbox)
	win.show()
	mainloop()

if __name__ == '__main__': main()
