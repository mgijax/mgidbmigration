#!/usr/local/bin/python

'''
#
# allele-collection tests
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

for provider in ['Australian PhenomeBank', 'Beutler Mutagenix', 'Harwell ENU Mutagenesis',
			'Neuroscience Blueprint cre', 'Pleiades Promoter Project', 'Sanger miRNA knockouts']:

	if provider == 'Australian PhenomeBank':
		inFile = open('/mgi/all/wts_projects/11500/11515/allele_collections/Australian_PhenomeBank.txt', 'r')
	elif provider == 'Beutler Mutagenix':
		inFile = open('/mgi/all/wts_projects/11500/11515/allele_collections/Beutler_Mutagenix.txt', 'r')
	elif provider == 'Harwell ENU Mutagenesis':
		inFile = open('/mgi/all/wts_projects/11500/11515/allele_collections/Harwell_ENU_Mutagenesis.txt', 'r')
	elif provider == 'Neuroscience Blueprint cre':
		inFile = open('/mgi/all/wts_projects/11500/11515/allele_collections/Neuroscience_Blueprint_cre.txt', 'r')
	elif provider == 'Pleiades Promoter Project':
		inFile = open('/mgi/all/wts_projects/11500/11515/allele_collections/Pleiades_Promoter_Project.txt', 'r')
	elif provider == 'Sanger miRNA knockouts':
		inFile = open('/mgi/all/wts_projects/11500/11515/allele_collections/Sanger_miRNA_knockouts.txt', 'r')

	for line in inFile.readlines():

       		tokens = line[:-1].split('\t')
       		symbol = tokens[0]
       		mgiID = tokens[1]

		sql = '''
			select a.symbol, t.term as outCollection
			from ALL_Allele a, ACC_Accession aa, VOC_Term t
			where aa.accID = '%s'
			and aa._MGIType_key = 11
			and aa._Object_key = a._Allele_key
			and a._Collection_key = t._Term_key
		'''

		value = 'pass'

		results = db.sql(sql % (mgiID), 'auto')

		if len(results) == 0:
			value = 'fail'
		else:
			for r in results:
				if r['outCollection'] != provider:
					value = 'fail'

		print value, symbol, mgiID, provider

	inFile.close()

db.useOneConnection(0)

