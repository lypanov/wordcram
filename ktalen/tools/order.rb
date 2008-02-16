#!/usr/bin/ruby

# read in from file specified on command line
def usage
   puts "Usage: order.rb <input_filename> [<output_filename_prefix>]"
   exit
end

usage unless [1,2].include? ARGV.length 
fname, fname_out = *ARGV
input = File.open(fname, "r") { |file| file.gets(nil).split "\n" }

# beautify format and seperate with |
# anything that won't fit needed format is printed out seperately to main groupings
okays, leftovers = [], []
input.each_with_index {
   |line, line_num|
   line.sub! /^(.*?)\s*$/, "\\1" # remove spaces at end
   line.sub! /[ ]{2,}/, "|"      # convert more than one space in a group to a pipe (|)
   if line !~ /\|/
      space_count = 0
      line.scan(/[ ]/) { space_count += 1}
      if space_count == 1
         line.sub! /[ ]/, "|"    # convert the space into a pipe
      else
         leftovers << [line_num, line]
         next
      end
   end
   okays << line
}

# show the leftovers group
if not leftovers.empty?
   puts leftovers.map { |a| a.join ":" }.join "\n"
   puts "so, like, fix 'em and stuff, cheers"
   exit
end

def langstring_complexity line
   line = $1 if line =~ /(.*?),/
   line.gsub!(/\(.*?\)/, "")
   complexity = line.scan(/[^aeiouyr]/).length
   line.length * complexity 
end

# sort based on original word complexity
okays = okays.sort_by {
   |line|
   line =~ /^(.*?)\|(.*)$/
   langstring_complexity($1) \
 + langstring_complexity($2)
}

# split into well sized groups - so we don't have a small group left at the end
GROUP_SIZE = 50
num_groups = (okays.length / GROUP_SIZE.to_f).ceil
per_group  =  okays.length / num_groups 

# do this just in case the group size calc is wrong
puts "GROUP SIZE: #{per_group}" 

# group up
groups = [[]]
okays.each {
   |line| 
   groups.unshift [] if groups.first.length > per_group
   groups.first << line
}

# print out groups
num = 0 
groups.reverse.each {
   |group|
   if !fname_out.nil?
      actual_fname = "#{fname_out}.#{"%02d" % (num += 1)}"
      if File.exists? actual_fname 
         puts "WARNING: Nothing written. Please delete the old files..."
         exit
      end
      File.open(actual_fname , "w") {
         |file| file.puts group.join "\n"
      }
   else
   puts "GROUP: "
   puts group.join "\n"
   end
}
