#!/usr/local/bin/python

'''
#
# tr3516.py
#
# Create bcp file of MRK_Notes from Phenotype Sentences
#
# Usage:
#       tr3516.py DBSERVER DBNAME InputFile
#
# History:
#
# lec	10/02/2002
#	- created
#
'''
 
import sys 
import string
import db
import mgi_utils

#
# Main
#

cdate = mgi_utils.date('%m/%d/%Y')

db.set_sqlServer(sys.argv[1])
db.set_sqlDatabase(sys.argv[2])

inFile = open(sys.argv[3], 'r')
outFile = open('MRK_Notes.bcp', 'w')

for line in inFile.readlines():

	tokens = string.split(line[:-1], '\t')
	accID = tokens[0]
	notes = tokens[2]

	markerKey = 0
	results = db.sql('select _Object_key from MRK_Acc_View where accID = "%s"' % (accID), 'auto')
	for r in results:
		markerKey = r['_Object_key']

	if markerKey > 0:

		# Write notes in chunks of 255
		seqNum = 1
		while len(notes) > 255:
			outFile.write('%d|%d|%s|%s|%s\n' % (markerKey, seqNum, notes[:255], cdate, cdate))
			notes = notes[255:]
			seqNum = seqNum + 1
		if len(notes) > 0:
			outFile.write('%d|%d|%s|%s|%s\n' % (markerKey, seqNum, notes, cdate, cdate))
      
inFile.close()
outFile.close()

