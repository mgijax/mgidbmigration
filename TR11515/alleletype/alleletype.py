#!/usr/local/bin/python

'''
#
# Report:
#       Enter TR # and describe report inputs/output
#
# History:
#
# lec	01/18/99
#	- created
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

DEBUG = 0

user = os.environ['MGD_DBUSER']
passwordFileName = os.environ['MGD_DBPASSWORDFILE']
db.set_sqlUser(user)
db.set_sqlPasswordFromFile(passwordFileName)

def processGeneration(generationScript):

	# select terms that require migration

	print '\nstart: process generation...'

	generationSQL = ''

	results = db.sql('''
		select t._Term_key, t.term 
		from VOC_Term t
		where t._Vocab_key = 38
		and t.term in (
			'Targeted (Floxed/Frt)',
			'Targeted (knock-in)',
			'Targeted (knock-out)',
			'Targeted (other)',
			'Targeted (Reporter)',
			'Transgenic (Cre/Flp)',
			'Transgenic (random, expressed)',
			'Transgenic (random, gene disruption)',
			'Transgenic (Reporter)',
			'Transgenic (Transposase)'
			)
		''', 'auto')

	for r in results:

		termKey = r['_Term_key']
		oldTerm = r['term']

		#
		# allele-type
		#

		newTermName = ''

		if oldTerm in (
			'Targeted (Floxed/Frt)',
			'Targeted (knock-in)',
			'Targeted (knock-out)',
			'Targeted (other)',
			'Targeted (Reporter)'):
			newTermName = 'Targeted'

		elif oldTerm in (
			'Transgenic (Cre/Flp)',
			'Transgenic (random, expressed)',
			'Transgenic (random, gene disruption)',
			'Transgenic (Reporter)',
			'Transgenic (Transposase)'):
			newTermName = 'Transgenic'

		if len(newTermName) > 0:
			newTermKey = newTerm[newTermName][0]
			print oldTerm, newTermName
			generationSQL = generationSQL + generationScript % (newTermKey, termKey)
		else:
			print 'ERROR: ' + r

	print generationSQL
	if not DEBUG:
		print '\nstart: executing update...'
		db.sql(generationSQL, None)
		print 'end: executing update...'

	print 'end: process generation...'

def processIKMC():

	# IKMC alleles
	# 125 KOMP-Regeneron-Project
	# 126 KOMP-CSD-Project
	# 138 EUCOMM projects
	# 143 NorCOMM-projects

	print '\nstart: processing IKMC alleles...'

	results = db.sql('''
		select a.symbol, a._Allele_key, aa._LogicalDB_key, t._Term_key, t.term, ldb.name as ldbname
		from ALL_Allele a, VOC_Term t, ACC_Accession aa, ACC_LogicalDB ldb
		where t._Vocab_key = 38
		and a._Allele_key = aa._Object_key
		and aa._MGIType_key = 11
		and aa._LogicalDB_key in (125, 126, 138, 143)
		and aa._LogicalDB_key = ldb._LogicalDB_key
		and t._Term_key = a._Allele_Type_key
		order by a.symbol
		''', 'auto')

	for r in results:

		symbol = r['symbol']
		aKey = r['_Allele_key']
		termKey = r['_Term_key']
		oldTerm = r['term']
		ldb = r['_LogicalDB_key']
		ldbName = r['ldbname']

		newAttrName = ''

		if (ldb == 125 and symbol.find('tm1.2(KOMP)Vlcg>') != -1) or \
		   (ldb == 126 and symbol.find('tm1d(KOMP)Wtsi>') != -1) or \
		   (ldb == 138 and symbol.find('tm1d(EUCOMM)Wtsi>') != -1) or \
		   (ldb == 138 and symbol.find('tm1d(EUCOMM)Hmgu>') != -1):
			newAttrName = 'Null (knock-out)'
			newAttrKey = newAttr[newAttrName][0]
			attrFile.write(ldbName + TAB + \
				symbol + TAB + \
				oldTerm + TAB + \
				str(newAttrName) + TAB + \
				str(termKey) + TAB + \
				str(newAttrKey) +  CRT)

		elif (ldb == 143 and symbol.find('(NCOM)') != -1) or \
		   (ldb == 125 and symbol.find('tm1(KOMP)Vlcg>') != -1) or \
		   (ldb == 125 and symbol.find('tm1.1(KOMP)Vlcg>') != -1) or \
		   (ldb == 126 and symbol.find('tm1b(KOMP)Wtsi>') != -1) or \
		   (ldb == 126 and symbol.find('tm1e(KOMP)Wtsi>') != -1) or \
		   (ldb == 138 and symbol.find('tm1b(EUCOMM)Wtsi>') != -1) or \
		   (ldb == 138 and symbol.find('tm1b(EUCOMM)Hmgu>') != -1) or \
		   (ldb == 138 and symbol.find('tm1e(EUCOMM)Wtsi>') != -1) or \
		   (ldb == 138 and symbol.find('tm1e(EUCOMM)Hmgu>') != -1):
			newAttrName = 'Null (knock-out)'
			newAttrKey = newAttr[newAttrName][0]
			attrFile.write(ldbName + TAB + \
				symbol + TAB + \
				oldTerm + TAB + \
				str(newAttrName) + TAB + \
				str(termKey) + TAB + \
				str(newAttrKey) +  CRT)
			newAttrName = 'Reporter'
			newAttrKey = newAttr[newAttrName][0]
			attrFile.write(ldbName + TAB + \
				symbol + TAB + \
				oldTerm + TAB + \
				str(newAttrName) + TAB + \
				str(termKey) + TAB + \
				str(newAttrKey) +  CRT)


		elif (ldb == 126 and symbol.find('tm1a(KOMP)Wtsi>') != -1) or \
		   (ldb == 138 and symbol.find('tm1a(EUCOMM)Wtsi>') != -1) or \
		   (ldb == 138 and symbol.find('tm1a(EUCOMM)Hmgu>') != -1):
			newAttrName = 'Null (knock-out)'
			newAttrKey = newAttr[newAttrName][0]
			attrFile.write(ldbName + TAB + \
				symbol + TAB + \
				oldTerm + TAB + \
				str(newAttrName) + TAB + \
				str(termKey) + TAB + \
				str(newAttrKey) +  CRT)
			newAttrName = 'Reporter'
			newAttrKey = newAttr[newAttrName][0]
			attrFile.write(ldbName + TAB + \
				symbol + TAB + \
				oldTerm + TAB + \
				str(newAttrName) + TAB + \
				str(termKey) + TAB + \
				str(newAttrKey) +  CRT)
			newAttrName = 'Conditional Ready'
			newAttrKey = newAttr[newAttrName][0]
			attrFile.write(ldbName + TAB + \
				symbol + TAB + \
				oldTerm + TAB + \
				str(newAttrName) + TAB + \
				str(termKey) + TAB + \
				str(newAttrKey) +  CRT)

		elif (ldb == 126 and symbol.find('tm1c(KOMP)Wtsi>') != -1) or \
		   (ldb == 138 and symbol.find('tm1c(EUCOMM)Wtsi>') != -1) or \
		   (ldb == 138 and symbol.find('tm1c(EUCOMM)Hmgu>') != -1):
			newAttrName = 'Conditional Ready'
			newAttrKey = newAttr[newAttrName][0]
			attrFile.write(ldbName + TAB + \
				symbol + TAB + \
				oldTerm + TAB + \
				str(newAttrName) + TAB + \
				str(termKey) + TAB + \
				str(newAttrKey) +  CRT)


	print 'end: processing IKMC alleles...'

def processAttribute():

	# special code to handle knock-in / allele-attribute

	hasDerivation = []
	results = db.sql('select _Object_key from MGI_Note where _MGIType_key = 11 and _NoteType_key = 1034', 'auto')
	for r in results:
		hasDerivation.append(r['_Object_key'])

	hasInducible = []
	results = db.sql('select _Object_key from MGI_Note where _MGIType_key = 11 and _NoteType_key = 1032', 'auto')
	for r in results:
		hasInducible.append(r['_Object_key'])

	#
	# non-IKMC alleles
	#

	print '\nstart: processing non-IKMC alleles...'

	results = db.sql('''
		select a.symbol, a._Allele_key, t._Term_key, t.term
		from ALL_Allele a, VOC_Term t
		where t._Vocab_key = 38
		and not exists (select 1 from ACC_Accession aa
			where a._Allele_key = aa._Object_key
				and aa._MGIType_key = 11
				and aa._LogicalDB_key in (125, 126, 138, 143))
		and t.term in (
			'Targeted (Floxed/Frt)',
			'Targeted (knock-in)',
			'Targeted (knock-out)',
			'Targeted (other)',
			'Targeted (Reporter)',
			'Transgenic (Cre/Flp)',
			'Transgenic (random, expressed)',
			'Transgenic (random, gene disruption)',
			'Transgenic (Reporter)',
			'Transgenic (Transposase)'
			)
		and t._Term_key = a._Allele_Type_key
		''', 'auto')

	for r in results:

		symbol = r['symbol']
		aKey = r['_Allele_key']
		termKey = r['_Term_key']
		oldTerm = r['term']

		newAttrName = ''
		if oldTerm in ('Targeted (knock-out)'):
			newAttrName = 'Null (knock-out)'
		elif oldTerm in ('Targeted (Floxed/Frt)'):
			newAttrName = 'Conditional Ready'
		elif oldTerm in ('Targeted (Reporter)'):
			newAttrName = 'Reporter'
		elif oldTerm in ('Transgenic (random, expressed)'):
			newAttrName = 'Inserted expressed sequence'
		elif oldTerm in ('Transgenic (Cre/Flp)'):
			newAttrName = 'Inserted expressed sequence'
		elif oldTerm in ('Transgenic (Reporter)'):
			newAttrName = 'Inserted expressed sequence'
		elif oldTerm in ('Transgenic (Transposase)'):
			newAttrName = 'Inserted expressed sequence'

		if len(newAttrName) > 0:
			newAttrKey = newAttr[newAttrName][0]
			attrFile.write(symbol + TAB + \
				oldTerm + TAB + \
				str(newAttrName) + TAB + \
				str(termKey) + TAB + \
				str(newAttrKey) +  CRT)

		# do another one...
		newAttrName = ''
		if oldTerm in ('Transgenic (Cre/Flp)'):
			newAttrName = 'Recombinase'
		elif oldTerm in ('Transgenic (Reporter)'):
			newAttrName = 'Reporter'
		elif oldTerm in ('Transgenic (Transposase)'):
			newAttrName = 'Transposase'

		if len(newAttrName) > 0:
			newAttrKey = newAttr[newAttrName][0]
			attrFile.write(symbol + TAB + \
				oldTerm + TAB + \
				str(newAttrName) + TAB + \
				str(termKey) + TAB + \
				str(newAttrKey) +  CRT)

		#
		# if term == 'Targeted (knock-in)':
		#
		# 	if driver note, then add 'Inserted expressed sequence'
		#		and 'Recombinase'
		#
		# 	elif inducible note , then add 'Inducible''
		#

		if oldTerm in ('Targeted (knock-in)') and aKey in hasDerivation:
			newAttrName = 'Recombinase'
			newAttrKey = newAttr[newAttrName][0]
			attrFile.write(symbol + TAB + \
				oldTerm + TAB + \
				str(newAttrName) + TAB + \
				str(termKey) + TAB + \
				str(newAttrKey) +  CRT)
			newAttrName = 'Inserted expressed sequence'
			newAttrKey = newAttr[newAttrName][0]
			attrFile.write(symbol + TAB + \
				oldTerm + TAB + \
				str(newAttrName) + TAB + \
				str(termKey) + TAB + \
				str(newAttrKey) +  CRT)
		elif oldTerm in ('Targeted (knock-in)') and aKey in hasInducible:
			newAttrName = 'Inducible'
			newAttrKey = newAttr[newAttrName][0]
			attrFile.write(symbol + TAB + \
				oldTerm + TAB + \
				str(newAttrName) + TAB + \
				str(termKey) + TAB + \
				str(newAttrKey) +  CRT)

	print 'end: processing non-IKMC alleles...'

#
#
# main
#

db.useOneConnection(1)

newTerm = {}
results = db.sql('''select _Term_key, term from VOC_Term 
	where _Vocab_key = 38 and term in ('Targeted', 'Transgenic')''', 'auto')
for r in results:
	key = r['term']
	value = r['_Term_key']
	newTerm[key] = []
	newTerm[key].append(value)
print '\nnewTerms....'
print newTerm

newAttr = {}
results = db.sql('''select t._Term_key, t.term from VOC_Term t, VOC_Vocab v
	where v.name = 'Allele Attribute'
	and v._Vocab_key = t._Vocab_key
	''', 'auto')
for r in results:
	key = r['term']
	value = r['_Term_key']
	newAttr[key] = []
	newAttr[key].append(value)
print '\nnewAttr...'
print newAttr

alleleGeneration = 'update ALL_Allele set _Allele_Type_key = %s where _Allele_Type_key = %s\n'
derivationGeneration = 'update ALL_CellLine_Derivation set _DerivationType_key = %s where _DerivationType_key = %s\n'

processGeneration(alleleGeneration)
processGeneration(derivationGeneration)

attrFile = open('alleleAttribute.bcp', 'w')
processIKMC()
processAttribute()
attrFile.close()

db.useOneConnection(0)

