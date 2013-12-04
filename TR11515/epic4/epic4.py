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

def updateAllele():

	updateSQL = ''

	# select terms that require migration

	results = db.sql('''
		select aa.accID, a.symbol, a._Allele_key, a._Allele_Type_key, t.term 
		from ALL_Allele a, VOC_Term t, ACC_Accession aa
		where a._Allele_Type_key = t._Term_key
		and a._Allele_key = aa._Object_key
		and aa._LogicalDB_key = 1
		and aa._MGIType_key = 11
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

	updateSQL = ''
	for r in results:

		print r

		alleleKey = r['_Allele_key']
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
			updateSQL = updateSQL + '''
				update ALL_Allele 
				set _Allele_Type_key = %s
				where _Allele_key = %s
				''' % (newTermKey, alleleKey)

		else:
			print 'ERROR: ' + r

		#
		# allele-attribute
		#

		# plus note #1
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
			attrFile.write(r['symbol'] + TAB)
			attrFile.write(oldTerm + TAB)
			attrFile.write(str(newAttrName) + TAB)
			attrFile.write(str(alleleKey) + TAB)
			attrFile.write(str(newAttrKey) + TAB)
			attrFile.write(CRT)

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
			attrFile.write(r['symbol'] + TAB)
			attrFile.write(oldTerm + TAB)
			attrFile.write(str(newAttrName) + TAB)
			attrFile.write(str(alleleKey) + TAB)
			attrFile.write(str(newAttrKey) + TAB)
			attrFile.write(CRT)

	print updateSQL
	#db.sql(updateSQL, None)

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

updateAllele()

attrFile.close()

db.useOneConnection(0)

