#!/usr/local/bin/python

'''
#
# tr204c.py 10/25/99
#
# Usage:
#       tr204c.py
#
# TR 204
#
# Import nonstd.july98.lori into Strains.
# Quick & dirty.
#
#
'''
 
import sys 
import string
import os
import regsub
import accessionlib
import mgdlib

STRAINSDB = os.environ['STRAINS']

INS_NOTE = 'insert MLP_Notes(_Strain_key, andor, reference, dataset, note1, note2, note3)'

#
# Main
#

mgdlib.set_sqlUser('mgd_dbo')
mgdlib.set_sqlPassword(string.strip(open('/opt/sybase/admin/.mgd_dbo_password', 'r').readline()))
mgdlib.set_sqlDatabase(STRAINSDB)

cmd = 'truncate table MLP_Notes'
mgdlib.sql(cmd, None, execute = 1)

fd = open('nonstd.july98.lori', 'r')
line = string.strip(fd.readline())

while line:
	tokens = string.split(line, '\t')
	numFields = len(tokens)

	if numFields == 1:
		strain = tokens[0]
		andor = ""
		reference = ""
		dataset = ""
		note1 = ""
		note2 = ""
		note3 = ""

	elif numFields == 4:
		strain = tokens[0]
		andor = tokens[1]
		reference = tokens[2]
		dataset = tokens[3]
		note1 = ""
		note2 = ""
		note3 = ""

	elif numFields == 5:
		strain = tokens[0]
		andor = tokens[1]
		reference = tokens[2]
		dataset = tokens[3]
		note1 = tokens[4]
		note2 = ""
		note3 = ""

	elif numFields == 6:
		strain = tokens[0]
		andor = tokens[1]
		reference = tokens[2]
		dataset = tokens[3]
		note1 = tokens[4]
		note2 = tokens[5]
		note3 = ""

	elif numFields == 7:
		strain = tokens[0]
		andor = tokens[1]
		reference = tokens[2]
		dataset = tokens[3]
		note1 = tokens[4]
		note2 = tokens[5]
		note3 = tokens[6]

	else:
		print tokens
		print str(numFields)

	strain = regsub.gsub('"', '', strain)
	note1 = regsub.gsub('"', '', note1)
	note2 = regsub.gsub('"', '', note2)
	note3 = regsub.gsub('"', '', note3)
	reference = regsub.gsub(' etc', '', reference)

	if len(andor) > 0:
		andor = '"' + andor + '"'
	else:
		andor = "NULL"

	if len(reference) == 0 or reference == 'master':
		reference = "NULL"

	if len(dataset) > 0:
		dataset = '"' + dataset + '"'
	else:
		dataset = "NULL"

	if len(note1) > 0:
		note1 = '"' + note1 + '"'
	else:
		note1 = "NULL"

	if len(note2) > 0:
		note2 = '"' + note2 + '"'
	else:
		note2 = "NULL"

	if len(note3) > 0:
		note3 = '"' + note3 + '"'
	else:
		note3 = "NULL"

	strainKey = None
	cmd = 'select _Strain_key, strain from %s..PRB_Strain s where strain = "%s"' % (os.environ['MGD'], strain) + \
		' and not exists (select n.* from MLP_Notes n where s._Strain_key = n._Strain_key)'
	results = mgdlib.sql(cmd, 'auto')
	for r in results:
		if r['strain'] == strain:
			strainKey = r['_Strain_key']

	if strainKey is not None:
		cmd = INS_NOTE + \
		' values(%d,%s,%s,%s,%s,%s,%s)' % (strainKey, andor, reference, dataset, note1, note2, note3)
		mgdlib.sql(cmd, None, execute = 1)
	else:
		print 'Invalid or Duplicate Strain:  %s' % (strain)

	line = string.strip(fd.readline())

fd.close()

# all strains will have a note record

cmd = 'select s._Strain_key from MLP_Strain s where not exists (select n.* from MLP_Notes n where s._Strain_key = n._Strain_key)'
results = mgdlib.sql(cmd, 'auto')
for r in results:
	cmd = INS_NOTE + \
		' values(%d,NULL,NULL,NULL,NULL,NULL,NULL)' % (r['_Strain_key'])
	mgdlib.sql(cmd, None, execute = 1)

cmd = "dump tran %s with no_log" % (STRAINSDB)
mgdlib.sql(cmd, None, execute = 1)
