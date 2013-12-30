#!/usr/local/bin/python

'''
#
# read kim's specific allele test
#
'''
 
import sys 
import os
import db
import reportlib

CRT = reportlib.CRT
SPACE = reportlib.SPACE
TAB = reportlib.TAB
PAGE = reportlib.PAGE

#
#
# main
#

db.useOneConnection(1)

inFile = open('/mgi/all/wts_projects/11500/11515/AlleleTypeMigrationTests.txt', 'r')

for line in inFile.readlines():

	tokens = line[:-1].split('\t')
	symbol = tokens[0]
	mgiID = tokens[1]
	inGterm = tokens[2]
	subTypes = tokens[3].split(', ')

	sql = '''
		select a.symbol, gt.term as outGterm, st.term as outSterm
		from ALL_Allele a, ACC_Accession aa, VOC_Term gt, VOC_Annot va, VOC_Term st
		where aa.accID = '%s'
		and aa._MGIType_key = 11
		and aa._Object_key = a._Allele_key
		and a._Allele_Type_key = gt._Term_key
		and a._Allele_key = va._Object_key
		and va._AnnotType_key = 1014
		and va._Term_key = st._Term_key

		union

		select a.symbol, gt.term as outGterm, 'none'
		from ALL_Allele a, ACC_Accession aa, VOC_Term gt
		where aa.accID = '%s'
		and aa._MGIType_key = 11
		and aa._Object_key = a._Allele_key
		and a._Allele_Type_key = gt._Term_key
		and not exists (select 1 from VOC_Annot va
			where a._Allele_key = va._Object_key
			and va._AnnotType_key = 1014)
		'''

	value = 'pass'

	results = db.sql(sql % (mgiID, mgiID), 'auto')

	if len(results) == 0:
		value = 'fail'
	else:
		for r in results:
			if r['outGterm'] != inGterm:
				value = 'fail'
			if r['outSterm'] not in subTypes:
				value = 'fail'

	print value, symbol, mgiID, inGterm, subTypes

inFile.close()

db.useOneConnection(0)

