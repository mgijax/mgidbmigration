#!/usr/local/bin/python

'''
#
# Report:
#       load Meiyee's spreadsheet
#
'''
 
import sys 
import os
import db
import reportlib

db.setTrace()

CRT = reportlib.CRT
SPACE = reportlib.SPACE
TAB = reportlib.TAB
PAGE = reportlib.PAGE

#
# Main
#

db.useOneConnection(1)

inFile = open('', 'r')
lineNum = 0
for line in inFile.readlines():
	lineNum = lineNum + 1

	tokens = line[:-1].split('\t')

fp = reportlib.init(sys.argv[0], printHeading = None)

#
# cmd = sys.argv[1]
#
# or
#
# cmd = 'select * from MRK_Marker where _Species_key = 1 and chromosome = "1"'
#

results = db.sql(cmd, 'auto')

for r in results:
    fp.write(r['item'] + CRT)

inFile.close()
reportlib.finish_nonps(fp)	# non-postscript file
db.useOneConnection(0)

