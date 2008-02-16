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

# configuration
module AppConfig # rename?
   QuitAction = "q"
   SleepFactors = {","=>2.5, "."=>1.5, "/"=>0.9 } # secs per sleep_quantum
   SyntaxString = "syntax: trainer.rb <filename>"
   Keys = {","=>-2, "."=>1, "/"=>3, "q"=>QuitAction}
   InitialSetSize = 20
   TestLengthList = [12, 4, 3]
   TopRandValue = 8
end

def error s
   puts s
   exit 1
end

# TODO Entry.gsub('=',' ') ??? - AK '04 - what??/

class Entry
   attr_reader :one, :two
   attr_accessor :ret
   def initialize(str)
      case str 
      when /^(.*?)\|(.*?)\|(.*?)$/
         @one, @two, @ret = $~[1], $~[2], $~[3].to_i
      when /^(.*?)\|(.*?)$/
         @one, @two, @ret = $~[1], $~[2], rand(AppConfig::TopRandValue)
      else
         error "umm... parse error!" 
      end
   end
   def to_s 
      "#{@one}|#{@two}|#{@ret}"
   end
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
         break if level == WordListSize 
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

class UiCallbacks
   # implement initialize, destruct, setMessage, and requestKey
end

class App
   include AppConfig
   class ExitPath < Exception ; end
   def initialize ui_class
      @cbs = ui_class.new
      begin
         yield self
      rescue ExitPath
         puts "exit path"
         ;
      ensure
         @cbs.destruct
      end
   end
   def dointeraction(word, level)
      msg = "current level: #{level}\nword: #{word.one} (#{Keys.keys.join("|")}): "
      key = @cbs.requestKey(msg)
      score = Keys[key]
      raise ExitPath if key == QuitAction
      @cbs.setMessage(
         msg + "\n" + (score.nil?       \
                        ? "bad key!!!"  \
                        : "should have been: #{word.two}")
      ) 
      time_to_sleep = [(word.two.to_f / 10).to_i, 1].max
      @cbs.do_sleep(time_to_sleep * SleepFactors[key])
      score
   end
end

class Core
   attr_accessor :tmp
   def initialize filename
      @wl = WordList.new filename
      @wl.load
      @tmp = WordList.new
      @wl.first_n(App::InitialSetSize) {
         |word|
         @tmp << @wl.delete(word)
      }
   end
   def run_app
      App.new(UICallbacks) {
         |app| 
         App::TestLengthList.each_with_index { 
            |n, idx| 
            diffs = {}
            done_words_in_level = 0
            @tmp.first_n(n) {
               |word|
               levels = []
               App::TestLengthList.each_with_index {
                  |s_n, s_idx|
                  str = (s_idx == idx) \
                       ? "#{done_words_in_level}/#{n}" \
                       : "#{s_n}"
                  levels << str
               }
               score = app.dointeraction(word, (levels.join ", "))
               diffs[word] = 0 if !diffs.has_key?(word)
               diffs[word] += score unless score.nil?
               done_words_in_level += 1
            }
            diffs.each_pair {
               |word, diff|
               @tmp.move_rel(word, diff)
            }
            @tmp.randomize!
         }
         raise App::ExitPath
      }
   end
   def finished
      puts "saving!"
      @wl.merge!(@tmp)
      @wl.save
   end
end
