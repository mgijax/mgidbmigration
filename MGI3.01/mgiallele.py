#!/usr/local/bin/python

import os
import string
import loadlib

inFile = open('Change_Mut_Type4Lori.txt', 'r')
outFile = open('mgiallele.sql', 'w')

for line in inFile.readlines():
	tokens = string.split(line[:-1], '\t')
	alleleID = tokens[0]
	alleleType = tokens[4]

	alleleKey = loadlib.verifyObject(alleleID, 11, None, None, None)
	typeKey = loadlib.verifyObject("", 26, alleleType, None, None)

	cmd = 'update ALL_Allele set _Allele_Type_key = %s where _Allele_key = %s\n' % (typeKey, alleleKey)
	cmd = cmd + 'go\n'
	outFile.write(cmd)

inFile.close()
outFile.close()

