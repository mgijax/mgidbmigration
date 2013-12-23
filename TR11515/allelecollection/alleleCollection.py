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
		''' % (newTerm['KOMP-Regeneron'])
	print updateSQL
	#db.sql(updateSQL, None)

	updateSQL = '''
		update ALL_Allele 
		set _Collection_key = %s
		from ALL_Allele a, ACC_Accession aa
		where a._Allele_key = aa._Object_key
		and aa._MGIType_key = 11
		and aa._LogicalDB_key = 126
		''' % (newTerm['KOMP-CSD'])
	print updateSQL
	#db.sql(updateSQL, None)

	updateSQL = '''
		update ALL_Allele 
		set _Collection_key = %s
		from ALL_Allele a, ACC_Accession aa
		where a._Allele_key = aa._Object_key
		and aa._MGIType_key = 11
		and aa._LogicalDB_key = 138
		''' % (newTerm['EUCOMM'])
	print updateSQL
	#db.sql(updateSQL, None)

	updateSQL = '''
		update ALL_Allele 
		set _Collection_key = %s
		from ALL_Allele a, ACC_Accession aa
		where a._Allele_key = aa._Object_key
		and aa._MGIType_key = 11
		and aa._LogicalDB_key = 143
		''' % (newTerm['NorCOMM'])
	print updateSQL
	#db.sql(updateSQL, None)

	print 'end: processing LDBs...'

def processName():

	print 'start: processing allele name...'

	updateSQL = '''
		update ALL_Allele
		set _Collection_key = %s
		where name like '%deltagen%'
		''' % (newTerm['Deltagen'])
	print updateSQL
	#db.sql(updateSQL, None)

	updateSQL = '''
		update ALL_Allele
		set _Collection_key = %s
		where name like '%lexicon%'
		''' % (newTerm['Lexicon'])
	print updateSQL
	#db.sql(updateSQL, None)

	updateSQL = '''
		update ALL_Allele
		set _Collection_key = %s
		where name like '%gensat project%'
		''' % (newTerm['GENSAT'])
	print updateSQL
	#db.sql(updateSQL, None)

	updateSQL = '''
		update ALL_Allele
		set _Collection_key = %s
		where name like '%wellcome trust%'
		and _Allele_Type_key = 847121
		''' % (newTerm['Sanger Inst. Gene Trap Res.'])
	print updateSQL
	#db.sql(updateSQL, None)

	updateSQL = '''
		update ALL_Allele
		set _Collection_key = %s
		where name like '%riken genomic%'
		and _Allele_Type_key = 847122
		''' % (newTerm['RIKEN GSC ENU Project'])
	print updateSQL
	#db.sql(updateSQL, None)

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
		''' % (newTerm['B2B/CvDC'])
	print updateSQL
	#db.sql(updateSQL, None)

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
		''' % (newTerm['Mutagenesis for Dev. Defects'])
	print updateSQL
	#db.sql(updateSQL, None)

	# J:104190     105261 

	updateSQL = '''
		update ALL_Allele
		set _Collection_key = %s
		from ALL_Allele a, MGI_Reference_Assoc av
		where a._Allele_key = av._Object_key
		and av._MGIType_key = 11
		and av._Refs_key in (105261)
		''' % (newTerm['Australian PhenomeBank'])
	print updateSQL
	#db.sql(updateSQL, None)

	print 'start: processing jnumber...'

#
#
# main
#

db.useOneConnection(1)

newTerm = {}
results = db.sql('select _Term_key, term from VOC_Term where _Vocab_key = 92', 'auto')
for r in results:
	key = r['term']
	value = r['_Term_key']
	newTerm[key] = []
	newTerm[key].append(value)
print '\nnewTerms....'
print newTerm

updateSQL = 'update ALL_Allele set _Collection_key = %s where _Allele_key = %s'

processLDB()
processName()
processJNum()

db.useOneConnection(0)

