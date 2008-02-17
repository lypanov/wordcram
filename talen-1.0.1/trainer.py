#!/usr/bin/env python

# Copyright (C) 2002 Alexander Kellett (lypanov@kde.org)
# 
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public
# License as published by the Free Software Foundation; either
# version 2 of the License, or (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program; see the file COPYING.  If not, write to
# the Free Software Foundation, Inc., 59 Temple Place - Suite 330,
# Boston, MA 02111-1307, USA.

import sys,string,re,whrandom,curses

SIZE = 30
outOfElements = 'outOfElements'

class Entry:

   entry_re = re.compile(r"^(?P<_1>[^|]*)\|(?P<_2>[^|]*)(\|(?P<_3>[^|]*))?$")

   def __init__(self, one, two=None, retention=None):
      self.dir = whrandom.randint(0,1)
      self.dir = 1
      if two==None:
         match = self.entry_re.match(one)
         retention = match.group('_3')
         if retention == None: retention = whrandom.randint(0,(SIZE/2)-1)
         else: retention = string.atoi(retention)
         self.ret, self.one, self.two = retention, match.group('_1'), match.group('_2')
      else:
         self.ret, self.one, self.two = string.atoi(retention), one, two

   def __repr__(self): return self.one + '|' + self.two

   def qstr(self,n=0):
      if (n - self.dir) == 0: str = self.one 
      else: str = self.two
      return string.replace(str,'=',' ')


class Wordlist:

   def __init__(self):
      self.lists = []
      for t in range(0,SIZE): self.lists.append([])

   def load(self,filename):
      f = open(filename)
      for s in f.readlines():
         if s[0] == '#': continue
         if s[-1:] == '\012': s = s[:-1]
         if s[-1:] == '\015': s = s[:-1]
         word = Entry(s)
         self.lists[word.ret].append(word)
      f.close()

   def save(self,filename):
      f = open(filename, 'w')
      f.write(
"""# This is part of the Talen project
# Copyright (C) 2002 Alexander Kellett
# See the file COPYING.fdl for copying conditions.
""")
      for t in range(0,SIZE):
         for element in self.lists[t]: f.write(`element` + '|' + `t` + '\n')
      f.close()

   def randomize(self,n=None):
      if n==None: r = range(0,SIZE)
      else: r = [n]
      for n in r:
         list = self.lists[n]
         l = len(list)
         tmp = []
         for t in range(0,l):
            v = whrandom.randint(0,l-t-1)
            i = list[v]
            tmp.append(i)
            list.remove(i)
         self.lists[n] = tmp

   def merge(self,new):
      for y in range(0,SIZE):
         while len(new[y]) > 0:
            t = new[y][0]
            self.lists[y].append(t) 
            new[y].remove(t)


def test(win,list,tested,number,skip=None):

   x,z = 0,0

   try:
      for y in range(0,number):

         while 1:
            if z >= SIZE: raise outOfElements
            l = len(list.lists[z])
            if x >= l:
               x = 0
               z = z+1
               continue
            break

         win.clear()
         a = list.lists[z]
         win.addstr(a[x].qstr() + ' =\n: ,|.|/ ')
         win.refresh()

         v = a[x]

         while 1:
            s=win.getch()
            if skip != None:
               tested.lists[z].append(v)
            else:
               if   s == ord(','):
                  if z-1 < 1: z = 1;
                  tested.lists[z-1].append(v)
               elif s == ord('.'):
                  tested.lists[z].append(v);
               elif s == ord('/'):
                  if (z+1) >= SIZE-(1+1): z = SIZE-(1+1);
                  tested.lists[z+1].append(v)
               else:
                  win.addstr("Doh")
                  win.refresh()
                  continue
            a.remove(v)
            break

         win.addstr('\n' + v.qstr() + ' = ' + v.qstr(1))

         win.refresh()
         win.getch()
   except outOfElements: 
      pass

def main():

   list = Wordlist()
   list.load(sys.argv[1])

   win=curses.initscr()
   curses.noecho()

   if len(sys.argv) == 2: 
      tested0 = Wordlist()
      test(win,list,tested0,10)
      tested0.randomize()

      tested1 = Wordlist()
      test(win,tested0,tested1,10)
      tested1.randomize()

      tested2 = Wordlist()
      test(win,tested1,tested2,5)
      tested2.randomize()

      tested3 = Wordlist()
      test(win,tested2,tested3,3)
      tested3.randomize()

      tested2.merge(tested3.lists)
      tested1.merge(tested2.lists)
      list.merge(tested1.lists)
   else:
      print "added an fdl block :)"

   curses.endwin()

   list.save(sys.argv[1])

if (len(sys.argv) == 2) or (len(sys.argv) == 3): 
   main()
else:
   print "oops. i need a parameter - <filename>"
