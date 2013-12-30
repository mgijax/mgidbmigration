#!/usr/local/bin/python

'''
#
# 1) use rules to set ALL_Allele._Collection_key field
#
'''
 
import sys 
import os
import db
import reportlib
import mgi_utils

CRT = reportlib.CRT
SPACE = reportlib.SPACE
TAB = reportlib.TAB
PAGE = reportlib.PAGE

DEBUG = 0

user = os.environ['MGD_DBUSER']
passwordFileName = os.environ['MGD_DBPASSWORDFILE']
db.set_sqlUser(user)
db.set_sqlPasswordFromFile(passwordFileName)

def processLDB():

	#
	# 125 KOMP-Regeneron-Project
	# 126 KOMP-CSD-Project
	# 138 EUCOMM projects
	# 143 NorCOMM-projects
	#

	print '\nstart: processing LDBs...'

	updateSQL = '''
		update ALL_Allele 
		set _Collection_key = %s
		from ALL_Allele a, ACC_Accession aa
		where a._Allele_key = aa._Object_key
		and aa._MGIType_key = 11
		and aa._LogicalDB_key = 125
		''' % (newTerm['KOMP-Regeneron'][0])
	print updateSQL
	db.sql(updateSQL, None)

	updateSQL = '''
		update ALL_Allele 
		set _Collection_key = %s
		from ALL_Allele a, ACC_Accession aa
		where a._Allele_key = aa._Object_key
		and aa._MGIType_key = 11
		and aa._LogicalDB_key = 126
		''' % (newTerm['KOMP-CSD'][0])
	print updateSQL
	db.sql(updateSQL, None)

	updateSQL = '''
		update ALL_Allele 
		set _Collection_key = %s
		from ALL_Allele a, ACC_Accession aa
		where a._Allele_key = aa._Object_key
		and aa._MGIType_key = 11
		and aa._LogicalDB_key = 138
		''' % (newTerm['EUCOMM'][0])
	print updateSQL
	db.sql(updateSQL, None)

	updateSQL = '''
		update ALL_Allele 
		set _Collection_key = %s
		from ALL_Allele a, ACC_Accession aa
		where a._Allele_key = aa._Object_key
		and aa._MGIType_key = 11
		and aa._LogicalDB_key = 143
		''' % (newTerm['NorCOMM'][0])
	print updateSQL
	db.sql(updateSQL, None)

	print 'end: processing LDBs...'

def processName():

	print 'start: processing allele name...'

	updateSQL = setSQL % (newTerm['Deltagen'][0], notSpecified) + "name like '%deltagen%'"
	print updateSQL
	db.sql(updateSQL, None)

	updateSQL = setSQL % (newTerm['Lexicon'][0], notSpecified) + "name like '%lexicon%'"
	print updateSQL
	db.sql(updateSQL, None)

	updateSQL = setSQL % (newTerm['GENSAT'][0], notSpecified) + "name like '%gensat project%'"
	print updateSQL
	db.sql(updateSQL, None)

	updateSQL = setSQL % (newTerm['Sanger Inst. Gene Trap Res.'][0], notSpecified) + "name like '%wellcome trust%'"
	print updateSQL
	db.sql(updateSQL, None)

	updateSQL = setSQL % (newTerm['RIKEN GSC ENU Project'][0], notSpecified) + "name like '%riken genomi%'"
	print updateSQL
	db.sql(updateSQL, None)

	print 'end: processing allele name...'

def processJNum():

	print 'start: processing jnumber...'

 	# J:175213     176309 

	updateSQL = '''
		update ALL_Allele
		set _Collection_key = %s
		from ALL_Allele a, MGI_Reference_Assoc av
		where a._Allele_key = av._Object_key
		and av._MGIType_key = 11
		and av._Refs_key = 176309
		and a._Collection_key = %s
		''' % (newTerm['B2B/CvDC'][0], notSpecified)
	print updateSQL
	db.sql(updateSQL, None)

 	# J:109155     110234 
 	# J:161341     162437 
 	# J:85113      86090 
 	# J:89098      90083 

	updateSQL = '''
		update ALL_Allele
		set _Collection_key = %s
		from ALL_Allele a, MGI_Reference_Assoc av
		where a._Allele_key = av._Object_key
		and av._MGIType_key = 11
		and av._Refs_key in (110234,162437,86090,90083)
		and a._Collection_key = %s
		''' % (newTerm['Mutagenesis for Dev. Defects'][0], notSpecified)
	print updateSQL
	db.sql(updateSQL, None)

	print 'end: processing jnumber...'

def processSpecificFiles():

	print 'start: processing specific file(s)...'

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

		newTermKey = newTerm[provider][0]

		for line in inFile.readlines():

        		tokens = line[:-1].split('\t')
        		symbol = tokens[0]
        		mgiID = tokens[1]

			updateSQL = '''
				update ALL_Allele 
				set _Collection_key = %s
				from ALL_Allele a, ACC_Accession aa
				where a._Allele_key = aa._Object_key
				and aa._MGIType_key = 11
				and aa._LogicalDB_key = 1
				and aa.preferred = 1
				and aa.accID = '%s'
				''' % (newTermKey, mgiID)
			print updateSQL
			db.sql(updateSQL, None)

	print 'end: processing specific file(s)...'

#
#
# main
#

newTerm = {}
results = db.sql('select _Term_key, term from VOC_Term where _Vocab_key = 92', 'auto')
for r in results:
	key = r['term']
	value = r['_Term_key']
	newTerm[key] = []
	newTerm[key].append(value)
print '\nnewTerms....'
print newTerm

notSpecified = newTerm['Not Specified'][0]

# to re-test
#db.sql('update ALL_Allele set _Collection_key = %s' % (notSpecified), None)

# this query will only update collections that are "Not Specified"
setSQL = 'update ALL_Allele set _Collection_key = %s where _Collection_key = %s and '

#processLDB()
#processName()
#processJNum()
processSpecificFiles()

