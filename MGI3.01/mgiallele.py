#!/usr/local/bin/python

import os
import string
import db

inFile = open('Change_Mut_Type4Lori.txt', 'r')
outFile = open('mgiallele.sql', 'w')

alleles = {}
results = db.sql('select _Object_key, accID from ACC_Accession where _MGIType_key = 11 ' + \
	'and _LogicalDB_key = 1 and prefixPart = "MGI:"', 'auto')
for r in results:
	alleles[r['accID']] = r['_Object_key']

atypes = {}
results = db.sql('select _Allele_Type_key, alleleType from ALL_Type', 'auto')
for r in results:
	atypes[r['alleleType']] = r['_Allele_Type_key']

for line in inFile.readlines():
	tokens = string.split(line[:-1], '\t')
	alleleID = string.strip(tokens[0])
	alleleType = string.strip(tokens[4])

	if not alleles.has_key(alleleID):
		print alleleID
	elif not atypes.has_key(alleleType):
		print '#'+ alleleType + '#'
	else:
		alleleKey = alleles[alleleID]
		typeKey = atypes[alleleType]

		cmd = 'update ALL_Allele set _Allele_Type_key = %s where _Allele_key = %s\n' % (typeKey, alleleKey)
		cmd = cmd + 'go\n'
		outFile.write(cmd)

inFile.close()
outFile.close()

