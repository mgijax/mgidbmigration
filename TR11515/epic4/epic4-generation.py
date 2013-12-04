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

def updateAlleleType():

	updateSQL = ''

	# select terms that require migration
#			'Targeted (Floxed/Frt)'
#			'Targeted (knock-out)',
#			'Targeted (other)',
#			'Targeted (Reporter)',
#			'Transgenic (Cre/Flp)',
#			'Transgenic (random, expressed)',
#			'Transgenic (random, gene disruption)',
#			'Transgenic (Reporter)',
#			'Transgenic (Transposase)'

	results = db.sql('''
		select aa.accID, a.symbol, a._Allele_key, a._Allele_Type_key, t.term 
		from ALL_Allele a, VOC_Term t, ACC_Accession aa
		where a._Allele_Type_key = t._Term_key
		and a._Allele_key = aa._Object_key
		and aa._LogicalDB_key = 1
		and aa._MGIType_key = 11
		and t.term in (
			'Targeted (knock-in)'
			)

		''', 'auto')

	updateSQL = ''
	for r in results:

		alleleKey = r['_Allele_key']
		oldTerm = r['term']

		newTermKey = 0

		print r

		if oldTerm in (
			'Targeted (Floxed/Frt)',
			'Targeted (knock-in)',
			'Targeted (knock-out)',
			'Targeted (other)',
			'Targeted (Reporter)'):
			newTermKey = newTerm['Targeted'][0]
		elif oldTerm in (
			'Transgenic (Cre/Flp)',
			'Transgenic (random, expressed)',
			'Transgenic (random, gene disruption)',
			'Transgenic (Reporter)',
			'Transgenic (Transposase)'):
			newTermKey = newTerm['Transgenic'][0]

		if newTermKey > 0:
			updateSQL = updateSQL + '''
				update ALL_Allele 
				set _Allele_Type_key = %s
				where _Allele_key = %s
				''' % (newTermKey, alleleKey)

		else:
			print 'ERROR: ' + r

	print updateSQL
	#db.sql(updateSQL, None)

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
print newTerm

updateAlleleType()

db.useOneConnection(0)

