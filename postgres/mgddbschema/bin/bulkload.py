#!/usr/local/bin/python

'''
#
# table    can be run thru automatic conversion
# 
# key       
#     needs manual add ON DELETE CASCADE
#
# index
#     needs manual removal of CREATE UNIQUE
# 
# trigger
#     all need manual conversion
#     except for those used in _Object_key/_MGIType_key list
# 
# procedure
#     all need manualy conversion
#
#
'''
 
import sys 
import db
import string
import re
import reportlib

# 12345&=&
acc1_re = re.compile("(^[0-9]+&=&)")

# -1&=&
acc2_re = re.compile("(^-[0-9]+&=&)")

# 12345&=&1000&=&
acc3_re = re.compile("(^[0-9]+&=&1000&=&)")

fp = sys.stdin
line = fp.readline()

previousS = ""

while line:

  s = ""

  for c in line:
    if c in string.digits or c in string.letters \
	or c in ('-','&','=','#',',',':','.','',' ','?','+','<','>','(',')','"','/','[',']'):
      s = s + c

  acc1_result = acc1_re.search(line)
  acc2_result = acc2_re.search(line)
  #acc3_result = acc3_re.search(line)

  #
  # if the first field of the current line is equal to digit + "&=&"
  # then
  #    print out the previous line
  # else
  #    attach the current line to the previous line
  #
  #print acc1_result.group(1)
  #

  #if acc3_result is not None:
  #  previousS = previousS + ' ' + s

  if acc1_result is not None or acc2_result is not None:
    if len(previousS) > 0:
      print previousS
    previousS = s

  else:
    previousS = previousS + ' ' + s

  line = fp.readline()

# don't forget to print out the last previous line
print previousS

