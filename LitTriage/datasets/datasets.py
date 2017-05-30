#!/usr/local/bin/python

'''
#
# migration of bib_dataset/bib_dataset_assoc to bib_workflow_status, bib_workflow_tag
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

results = db.sql(cmd, 'auto')

for r in results:
    fp.write(r['item'] + CRT)

inFile.close()
reportlib.finish_nonps(fp)	# non-postscript file
db.useOneConnection(0)

