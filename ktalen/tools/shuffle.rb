#!/usr/bin/ruby

# This is part of the Talen project
# Copyright (C) 2002 Alexander Kellett
# See the file COPYING.fdl for copying conditions.

# load
@list = []
IO.foreach(ARGV[0]) { |line|
   @list << line
}

# randomize
@randomized = []
(@list.length).downto(1) { |i|
   obj = @list.delete_at(rand(i))
   @randomized << obj
}

# output
@randomized.each { |line| 
   print line
}
