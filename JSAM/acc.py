#!/usr/local/bin/python

import os
import string

delim = '&=&'
eol = '#=#\n'
createdBy = os.environ['CREATEDBY']

aFile = open('ACC_Accession_Old.bcp', 'r')
bFile = open('ACC_Accession.bcp', 'w')
cFile = open('ACC_AccessionReference_Old.bcp', 'r')
dFile = open('ACC_AccessionReference.bcp', 'w')

for line in aFile.readlines():
	tokens = string.split(line[:-1], delim)

	for i in range(9):
		try:
			bFile.write(tokens[i] + delim)

		except:
			print 'Accession Old:  ' + str(tokens)

	try:
		bFile.write(createdBy + delim + createdBy + delim)
		bFile.write(tokens[9] + delim + tokens[10] + eol)
	except:
		bFile.write(eol)

for line in cFile.readlines():
	tokens = string.split(line[:-1], delim)

	for i in range(2):
		try:
			dFile.write(tokens[i] + delim)

		except:
			print 'Accession Reference Old:  ' + str(tokens)

	try:
		dFile.write(createdBy + delim + createdBy + delim)
		dFile.write(tokens[2] + delim + tokens[3] + eol)
	except:
		dFile.write(eol)

aFile.close()
bFile.close()
cFile.close()
dFile.close()

