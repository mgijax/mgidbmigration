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

user = os.environ['MGD_DBUSER']
passwordFileName = os.environ['MGD_DBPASSWORDFILE']
db.set_sqlUser(user)
db.set_sqlPasswordFromFile(passwordFileName)

generationSQL = ''

def processGeneration(generationScript):
	global generationSQL

	# select terms that require migration

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
			generationSQL = generationSQL + generationScript % (newTermKey, termKey)
		else:
			print 'ERROR: ' + r

def processAttribute():

	# special code to handle knock-in / allele-attribute

	hasDerivation = []
	results = db.sql('select _Object_key from MGI_Note where _MGIType_key = 11 and _NoteType_key = 1034', 'auto')
	for r in results:
		hasDerivation.append(r['_Object_key'])

	results = db.sql('''
		select a.symbol, a._Allele_key, t._Term_key, t.term
		from ALL_Allele a, VOC_Term t
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
		and t._Term_key = a._Allele_Type_key
		order by t.term, a.symbol
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
			attrFile.write(symbol + TAB + oldTerm + TAB + str(newAttrName) + TAB + str(termKey) + TAB + str(newAttrKey) +  CRT)

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
			attrFile.write(symbol + TAB + oldTerm + TAB + str(newAttrName) + TAB + str(termKey) + TAB + str(newAttrKey) +  CRT)

		#
		# if term == 'Targeted (knock-in)':
		#
		# 	if driver note, then add 'Inserted expressed sequence'
		#		and 'Recombinase'
		#
		# 	elif inducible note , then add 'Incucible''
		#

		if oldTerm in ('Targeted (knock-in)') and aKey in hasDerivation:
			newAttrName = 'Recombinase'
			attrFile.write(symbol + TAB + oldTerm + TAB + str(newAttrName) + TAB + str(termKey) + TAB + str(newAttrKey) +  CRT)
			newAttrName = 'Inserted expressed sequence'
			attrFile.write(symbol + TAB + oldTerm + TAB + str(newAttrName) + TAB + str(termKey) + TAB + str(newAttrKey) +  CRT)

#
#
# main
#

db.useOneConnection(1)

attrFile = open('alleleAttribute.bcp', 'w')

newTerm = {}
results = db.sql('''select _Term_key, term from VOC_Term 
	where _Vocab_key = 38 and term in ('Targeted', 'Transgenic')''', 'auto')
for r in results:
	key = r['term']
	value = r['_Term_key']
	newTerm[key] = []
	newTerm[key].append(value)
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
print newAttr

alleleGeneration = 'update ALL_Allele set _Allele_Type_key = %s where _Allele_Type_key = %s\n'
derivationGeneration = 'update ALL_CellLine_Derivation set _DerivationType_key = %s where _DerivationType_key = %s\n'

processGeneration(alleleGeneration)
processGeneration(derivationGeneration)
processAttribute()

print generationSQL
#db.sql(generationSQL, None)

attrFile.close()

db.useOneConnection(0)

