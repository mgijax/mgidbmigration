#!/usr/local/bin/python

'''
#
# tr204b.py 10/07/99
#
# Usage:
#       tr204b.py
#
# TR 204
#
#
'''
 
import sys 
import string
import os
import accessionlib
import mgdlib

#
# Main
#

mgdlib.set_sqlUser('mgd_dbo')
mgdlib.set_sqlPassword(string.strip(open('/opt/sybase/admin/.mgd_dbo_password', 'r').readline()))

fd = open('master.mgi.out', 'r')
line = fd.readline()	# first line contains header
line = string.strip(fd.readline())

while line:
	tokens = string.split(line, '\t')
	mgiID = tokens[0]
	strain = tokens[1]

	cmd = 'select _Strain_key, strain from PRB_Strain where strain = "%s"' % (strain)
	results = mgdlib.sql(cmd, 'auto')
	for r in results:
		if mgiID != str(r['_Strain_key']):
			print '%s...%s...%d' % (strain, mgiID, r['_Strain_key'])

	line = string.strip(fd.readline())

fd.close()

