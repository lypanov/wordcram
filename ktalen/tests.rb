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

require "talen-lib"

def Entry.tests
   # TODO
   print "testing entry and stuff... well, not really"
end

def WordList.tests
   path = "/tmp/wordlist.test"
   puts "creating new wordlist"
   t1 = WordList.new("#{path}.1")
   puts "appending a few entries"
   t1 << Entry.new("c|d|1") << Entry.new("d|c|2")
   puts "saving out"
   t1.save
   puts "create new object with old filename"
   # TODO - test append of comment block to file and save + comparison
   t1a = WordList.new(t1.filename)
   puts "reloading again via new object"
   t1a.load
   fail "new opened object was different!!!" if t1.to_s != t1a.to_s
   myentry2 = Entry.new("b|c|3")
   entries = [] << Entry.new("a|b|2") << myentry2 <<
                   Entry.new("d|e|3") << Entry.new("f|o|3") <<
                   Entry.new("l|i|3") << Entry.new("z|l|4") <<
                   Entry.new("c|d|4") << Entry.new("b|g|4") 
   t2 = WordList.new("#{path}.2")
   entries.each { |entry| t2 << entry }
   print "testing iterator"
   (0..entries.length).each {
      |count|
      n=0
      t2.first_n(count) {
         |item|
         fail "iterator doesn't work!" if item != entries[n]
         print "."
         n+=1
      }
      fail "iterator stopped too early|late!" if n != [entries.length, n].min
   }
   puts "testing if randomize works"
   t2oldstr = t2.to_s
   t2.randomize!
   fail "not random enough!" if t2.to_s == t2oldstr
   fail "differing length after randomize!" if t2.to_s.length != t2oldstr.length
   puts "testing if move_rel works well"
   # can't really think of a good post test, this is just a stress test therefore
   [1, -1, 2, -2].each {
      |diff| 40.times { t2.move_rel(myentry2, diff) }
   }
   fail "move_rel is moving stuff out of limits!" if not (myentry2.ret === 0..20)
   t2.move_rel(myentry2, 100)
   fail "umm.. isn't in expected pos (20)" if myentry2.ret != 20
   t2.move_rel(myentry2, -100)
   fail "umm.. isn't in expected pos (0)" if myentry2.ret != 0
   t2.move_rel(myentry2, 10)
   fail "umm.. isn't in expected pos (10)" if myentry2.ret != 10
end

Entry.tests
WordList.tests
