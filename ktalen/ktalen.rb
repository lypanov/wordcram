#!/usr/bin/env ruby

=begin copyright

Copyright (C) 2003-2004 Alexander Kellett (lypanov@kde.org)

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public
License as published by the Free Software Foundation; either
version 2 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; see the file COPYING.  If not, write to
the Free Software Foundation, Inc., 59 Temple Place - Suite 330,
Boston, MA 02111-1307, USA.

=end

require "Korundum"
require "talen-lib"
require "slotstates"

# Qt.debug_level = Qt::DebugLevel::High
# Qt.debug_level = Qt::DebugLevel::Extensive

# wierd shit affect of continuation usage for cosntructors, calling the super later on in the 
# initialize of a qt subclass will mean that all lines after that point are called *twice*????

class UICallbacks < UiCallbacks
   EVTYPE_SCORE   = 0
   EVTYPE_TIMEOUT = 1
   def initialize
      about = KDE::AboutData.new "one", "two", "three"
      KDE::CmdLineArgs.init 1, ["RubberDoc"], about
      app = KDE::Application.new
      m = KDE::MainWindow.new
      @vbox = Qt::VBox.new m
      @label = Qt::Label.new @vbox
      fname = "xmlgui.rc"
      guixmlfname = Dir.pwd + "/#{fname}"
      guixmlfname = File.dirname(((File.readlink $0) rescue $0)) + "/#{fname}" unless File.exists? guixmlfname
      m.createGUI guixmlfname
      m.setCentralWidget @vbox
      app.setMainWidget m
      m.show

      @r = StatefulSlotController.new
      @r.init_app app

      @sc1  = @r.def_event_handler("score1")  { @r.continue EVTYPE_SCORE, "," }
      KDE::Action.new "Score", "score", KDE::Shortcut.new(Qt::Key_Comma),  @r, @sc1.slot,  m.actionCollection, "score1"

      @sc2  = @r.def_event_handler("score2")  { @r.continue EVTYPE_SCORE, "." }
      KDE::Action.new "Score", "score", KDE::Shortcut.new(Qt::Key_Period), @r, @sc2.slot,  m.actionCollection, "score2"

      @sc3  = @r.def_event_handler("score3")  { @r.continue EVTYPE_SCORE, "/" }
      KDE::Action.new "Score", "score", KDE::Shortcut.new(Qt::Key_Slash),  @r, @sc3.slot,  m.actionCollection, "score3"

      @quit = @r.def_event_handler("quit")    { @r.continue EVTYPE_SCORE, "q" }
      KDE::Action.new "Quit",  "quit",  KDE::Shortcut.new(Qt::Key_Q),      @r, @quit.slot, m.actionCollection, "quit"

      @tmo  = @r.def_event_handler("timeout") { @r.continue EVTYPE_TIMEOUT }
   end
   def destruct
      ;
   end
   def setMessage message
      @label.setText message
   end
   def requestKey message
      setMessage message
      key = @r.wait_on_event EVTYPE_SCORE
      return key
   end
   def do_sleep time
      Qt::Timer::singleShot time * 1000, @r, @tmo.slot
      @r.wait_on_event EVTYPE_TIMEOUT
   end
end

error App::SyntaxString if ARGV.length != 1
bl = Core.new ARGV[0]
bl.run_app
bl.finished
