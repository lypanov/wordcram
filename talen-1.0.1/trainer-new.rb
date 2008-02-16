#!/usr/bin/env ruby

=begin copyright

Copyright (C) 2003 Alexander Kellett (lypanov@kde.org)

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

require "curses"
include Curses

# need an equiv of:
# import locale
# locale.setlocale( locale.LC_ALL, "" )

# configuration
class Gui
   QuitAction = -1
   SleepTime = 0.9
   SyntaxString = "syntax: trainer.rb <filename>"
   Keys = {","=>-2, "."=>0, "/"=>1, "q"=>QuitAction}
   InitialSetSize = 15
   TestLengthList = [12, 10, 6, 6]
end

module Kernel
   def println(str)
      print str, "\n"
   end
end

# TODO Entry.gsub('=',' ') ???

class Entry
   attr_reader :one, :two
   attr_accessor :ret
   def initialize(str)
      fail "umm... parse error!" if str !~ /^(.*?)\|(.*?)\|(.*?)$/
      @one, @two, @ret = $~[1], $~[2], $~[3].to_i
   end
   def to_s 
      "#{@one}|#{@two}|#{@ret}"
   end
end

def Entry.tests
   print "testing entry and stuff... well, not really"
end

class WordList
   WordListSize = 20
   attr_reader :filename, :lists
   def initialize(filename = nil)
      @lists = []
      (0..WordListSize).each { @lists << [] }
      @filename = filename
      @commentblock = ""
   end
   def load
      IO.readlines(@filename).each { |line|
         @commentblock << line && next if line =~ /#.*/
         word = Entry.new(line.chomp)
         self << word
      }
   end
   def save
      f = File.new(@filename, "w")
      f.print(@commentblock)
      (0..WordListSize).each { |i| 
         @lists[i].each { |word| 
            f.print("#{word.to_s}\n")
         }
      }
      f.close
   end
   def randomize!
      (0..WordListSize).each { |i|
         words = @lists[i]
         tmp = []
         while not words.empty?
            tmp << words.delete_at(rand(words.length))
         end
         @lists[i] = tmp
      }
   end
   def move_rel(word, diff)
      def limit(val, rng)
         [[val, rng.begin].max, rng.end].min
      end
      newpos = limit(word.ret + diff, 0..20)
      @lists[newpos] << delete(word) if diff != 0
      word.ret = newpos
   end
   def merge!(wordlist)
      (0..WordListSize).each { |i|
         @lists[i] = @lists[i] + wordlist.lists[i]
         wordlist.lists[i] = []
      }
   end
   def delete(word)
      @lists[word.ret].delete(word)
   end
   def to_s
      str = ""
      (0..WordListSize).each { |i|
         str << "for level #{i}:\n"
         @lists[i].each { |entry|
            str << "\t#{entry.to_s}\n"
         }
      }
      str
   end
   def << word
      @lists[word.ret] << word
      self
   end
   def first_n(number)
      num,item,level = 0,0,0
      while num < number
         last if level == WordListSize 
         if item >= @lists[level].length
            item = 0
            level += 1
            next
         end
         yield @lists[level][item]
         item += 1
         num += 1
      end
   end
end

def WordList.tests
   path = "/tmp/wordlist.test"
   println "creating new wordlist"
   t1 = WordList.new("#{path}.1")
   println "appending a few entries"
   t1 << Entry.new("c|d|1") << Entry.new("d|c|2")
   println "saving out"
   t1.save
   println "create new object with old filename"
   # TODO - test append of comment block to file and save + comparison
   t1a = WordList.new(t1.filename)
   println "reloading again via new object"
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
   println "testing if randomize works"
   t2oldstr = t2.to_s
   t2.randomize!
   fail "not random enough!" if t2.to_s == t2oldstr
   fail "differing length after randomize!" if t2.to_s.length != t2oldstr.length
   println "testing if move_rel works well"
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

class UI
   def initialize
      init_screen
      crmode
      noecho
      refresh
   end
   def destruct
      close_screen
   end
   def setMessage(message)
      clear
      addstr(message)
      refresh
   end
   def requestKey(message)
      setMessage(message)
      ch = getch
      return ch.chr
   end
end

class Gui
   class ExitPath < Exception ; end
   def initialize
      @ui = UI.new
      begin
         yield self
      rescue ExitPath
         ;
      ensure
         @ui.destruct
      end
   end
   def dointeraction(word)
      msg = "word: #{word.one} (#{Keys.keys.join("|")}): "
      key = @ui.requestKey(msg)
      score = Keys[key]
      raise ExitPath if score == QuitAction
      @ui.setMessage(
         msg + "\n" + (score.nil?       \
                        ? "bad key!!!"  \
                        : "should have been:#{word.two}")
      ) 
      sleep SleepTime
      score
   end
end

if ARGV[0] == "tests"
   Entry.tests
   WordList.tests
else
   fail Gui::SyntaxString if ARGV.length != 1
   wl = WordList.new(ARGV[0])
   wl.load
   tmp = WordList.new
   wl.first_n(Gui::InitialSetSize) {
      |word|
      tmp << wl.delete(word)
   }
   Gui.new {
      |gui| 
      Gui::TestLengthList.each { 
         |n| 
         diffs = {}
         tmp.first_n(n) {
            |word|
            score = gui.dointeraction(word)
            diffs[word] = 0 if !diffs.has_key?(word)
            diffs[word] += score
         }
         diffs.each_pair {
            |word, diff|
            tmp.move_rel(word, diff)
         }
         tmp.randomize!
      }
      raise Gui::ExitPath
   }
   wl.merge!(tmp)
   wl.save
end
