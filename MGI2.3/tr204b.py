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
# Import master.mgi.out into MGD.
# Quick & dirty.
#
#
'''
 
import sys 
import string
import os
import accessionlib
import mgdlib

STRAINSDB = os.environ['STRAINS']

INS_STRAIN = 'insert MLP_Strain(_Strain_key, _Species_key)'
INS_TYPE = 'insert MLP_StrainTypes(_Strain_key, _StrainType_key)'
INS_GENE = 'insert %s..PRB_Strain_Marker (_Strain_key, _Marker_key)' % os.environ['MGD']

#
# Main
#

mgdlib.set_sqlUser('mgd_dbo')
mgdlib.set_sqlPassword(string.strip(open('/opt/sybase/admin/.mgd_dbo_password', 'r').readline()))
mgdlib.set_sqlDatabase(STRAINSDB)
#mgdlib.set_sqlLogFunction(mgdlib.sqlLogAll)

cmd = 'truncate table MLP_Strain'
mgdlib.sql(cmd, None, execute = 1)

cmd = 'truncate table MLP_StrainTypes'
mgdlib.sql(cmd, None, execute = 1)

cmd = 'truncate table %s..PRB_Strain_Marker' % os.environ['MGD']
mgdlib.sql(cmd, None, execute = 1)

fd = open('master.mgi.out', 'r')
line = fd.readline()	# first line contains header
line = string.strip(fd.readline())

while line:
	tokens = string.split(line, '\t')
	numFields = len(tokens)
	genes = []
	speciesKey = -1

	if numFields == 2:
		mgiID = tokens[0]
		background = tokens[1]
		genes = []
		strainType = ['Not Specified']
		tjl = ''
		species = 'Not Specified'
	
	elif numFields >= 3 and numFields <= 4:
		mgiID = tokens[0]
		background = tokens[1]
		genes = string.split(tokens[2], ', ')
		strainType = ['Not Specified']
		tjl = ''
		species = 'Not Specified'

	elif numFields >= 6:
		mgiID = tokens[0]
		background = tokens[1]
		genes = string.split(tokens[2], ', ')
		strainType = string.split(tokens[3], ', ')
		tjl = tokens[4]
		species = tokens[5]
		if len(species) == 0:
			species = 'Not Specified'

	# eliminate duplicate genes
	for g in genes:
		if genes.count(g) > 1:
			genes.remove(g)

	# Species

	cmd = 'select _Species_key from MLP_Species where species = "%s"' % (species)
	results = mgdlib.sql(cmd, 'auto')
	if len(results) > 0:
		speciesKey = results[0]['_Species_key']
	else:
		print 'Invalid Species: %s' % (species)
		line = string.strip(fd.readline())
		continue

	# Strain

	cmd = INS_STRAIN + ' values(%s,%d)' % (mgiID, speciesKey)
	mgdlib.sql(cmd, None, execute = 1)

	# Strain Types

	for s in strainType:
		st = string.strip(s)
		if len(st) > 0:
			cmd = 'select _StrainType_key from MLP_StrainType ' + \
				'where strainType = "%s"' % (st)
			results = mgdlib.sql(cmd, 'auto')
			if len(results) > 0:
				strainTypeKey = results[0]['_StrainType_key']
				cmd = INS_TYPE + ' values(%s,%d)' % (mgiID, strainTypeKey)
				mgdlib.sql(cmd, None, execute = 1)
			else:
				print 'Invalid Strain Type: %s' % (st)

	# Genes

	for g in genes:
		if len(g) > 0:
			cmd = 'select _Current_key, symbol from %s..MRK_Current_View where symbol = "%s"' % (os.environ['MGD'], g)
			results = mgdlib.sql(cmd, 'auto')
			markerkey = 0
			if len(results) > 0:
				for r in results:
					if r['symbol'] == g:
						markerkey = r['_Current_key']
			else:
				print 'Invalid Symbol: %s' % (g)

			if markerkey > 0:
				cmd = INS_GENE + ' values(%s,%d)' % (mgiID, markerkey)
				mgdlib.sql(cmd, None, execute = 1)


	# JAX Mice Registry Accession ID

	if len(tjl) > 0:
		cmd = 'exec %s..ACC_insert %s,"%s",22,"Strain",-1,1,1' % (os.environ['MGD'], mgiID, tjl)
		mgdlib.sql(cmd, None, execute = 1)

	line = string.strip(fd.readline())

fd.close()

cmd = "dump tran %s with no_log" % (STRAINSDB)
mgdlib.sql(cmd, None, execute = 1)

cmd = "dump tran %s with no_log" % (os.environ['MGD'])
mgdlib.sql(cmd, None, execute = 1)
