#!/usr/local/bin/python

'''
#
# tr204d.py
#
# Usage:
#       tr204d.py
#
# TR 204
#
# Add Gene records for strains w/ symbol "A" using symbol "a"
#
'''
 
import sys 
import string
import os
import accessionlib
import mgdlib

STRAINSDB = os.environ['STRAINS']

INS_GENE = 'insert %s..PRB_Strain_Marker (_Strain_key, _Marker_key)' % os.environ['MGD']

#
# Main
#

mgdlib.set_sqlUser('mgd_dbo')
mgdlib.set_sqlPassword(string.strip(open('/opt/sybase/admin/.mgd_dbo_password', 'r').readline()))
mgdlib.set_sqlDatabase(STRAINSDB)

fd = open('master.mgi.out', 'r')
line = fd.readline()	# first line contains header
line = string.strip(fd.readline())

while line:
	tokens = string.split(line, '\t')
	numFields = len(tokens)
	genes = []

	if numFields == 2:
		mgiID = tokens[0]
		background = tokens[1]
		genes = []
	
	elif numFields >= 3 and numFields <= 4:
		mgiID = tokens[0]
		background = tokens[1]
		genes = string.split(tokens[2], ', ')

	elif numFields >= 6:
		mgiID = tokens[0]
		background = tokens[1]
		genes = string.split(tokens[2], ', ')

	try:
		i = genes.index('A');
	except:
		line = string.strip(fd.readline())
		continue
		
	print background
	markerKey = 3
	cmd = INS_GENE + ' values(%s,%d)' % (mgiID, markerKey)
	mgdlib.sql(cmd, None, execute = 0)

	line = string.strip(fd.readline())

fd.close()
