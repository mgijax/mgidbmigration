#!/usr/local/bin/python

'''
#
# tr204a.py 10/07/99
#
# Usage:
#       tr204a.py
#
# TR 204a
#
# Create Controlled vocabulary MLP_StrainType and MLD_Species records
# from master.mgi.out.  Quick & dirty.
#
'''
 
import sys 
import string
import os
import mgdlib

EXECUTE = 1
STRAINSDB = os.environ['STRAINS']

strainTypesDict = {}
speciesDict = {}

INS_TYPE = 'insert MLP_StrainType (_StrainType_key, strainType)'
INS_SPECIES = 'insert MLP_Species (_Species_key, species)'

#
# Main
#

mgdlib.set_sqlUser('mgd_dbo')
mgdlib.set_sqlPassword(string.strip(open('/opt/sybase/admin/.mgd_dbo_password', 'r').readline()))
mgdlib.set_sqlDatabase(STRAINSDB)
#mgdlib.set_sqlLogFunction(mgdlib.sqlLogAll)

fd = open('master.mgi.out', 'r')
line = fd.readline()	# first line contains header
line = string.strip(fd.readline())

cmd = "truncate table MLP_StrainType"
mgdlib.sql(cmd, None, execute = EXECUTE)

cmd = "truncate table MLP_Species"
mgdlib.sql(cmd, None, execute = EXECUTE)

while line:
	tokens = string.split(line, '\t')

	try:
		strainType = tokens[3]

		strainTypes = string.split(strainType, ', ')
		for s in strainTypes:
			if s == 'Chromosome aberration':
				s = 'Chromosome Aberration'

			s = string.strip(s)
			if len(s) > 0 and s not in ['Not Specified', 'Not specified', 'Not Applicable']:
				if not strainTypesDict.has_key(s):
					strainTypesDict[s] = 1
	except:
		print 'No Strain Type:  ' + str(tokens)
		pass

	try:
		speciesVal = tokens[5]

		if len(speciesVal) > 0 and not speciesDict.has_key(speciesVal):
			speciesDict[speciesVal] = 1

	except:
		print 'No Species:  ' + str(tokens)
		pass

	line = string.strip(fd.readline())

fd.close()

cmd = INS_TYPE + ' values(-2,"Not Applicable")\n'
mgdlib.sql(cmd, None, execute = EXECUTE)

cmd = INS_TYPE + ' values(-1,"Not Specified")\n'
mgdlib.sql(cmd, None, execute = EXECUTE)

cmd = INS_SPECIES + ' values(-2,"Not Applicable")\n'
mgdlib.sql(cmd, None, execute = EXECUTE)

cmd = INS_SPECIES + ' values(-1,"Not Specified")\n'
mgdlib.sql(cmd, None, execute = EXECUTE)

key = 1
sortem = strainTypesDict.keys()
sortem.sort()
for s in sortem:
	cmd = INS_TYPE + ' values(%d,"%s")\n' % (key, s)
	mgdlib.sql(cmd, None, execute = EXECUTE)
	key = key + 1

key = 1
sortem = speciesDict.keys()
sortem.sort()
for s in sortem:
	cmd = INS_SPECIES + ' values(%d,"%s")\n' % (key, s)
	mgdlib.sql(cmd, None, execute = EXECUTE)
	key = key + 1

cmd = "dump tran %s with no_log" % (STRAINSDB)
mgdlib.sql(cmd, None, execute = EXECUTE)

