#!/usr/local/bin/python

'''
#
# 1) translate "current" allele-type to "generation" allele-type
#
# 2) create vocabulary-associations between "generation" and "allele attribute (subtype)"
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

user = os.environ['MGD_DBUSER']
passwordFileName = os.environ['MGD_DBPASSWORDFILE']
db.set_sqlUser(user)
db.set_sqlPasswordFromFile(passwordFileName)

currentDate = mgi_utils.date('%m/%d/%y')

def processPrintGeneration(generationScript):

	# select alleles/terms that require migration

	print '\nstart: print generation...'

	results = db.sql('''
		select a.symbol, t._Term_key, t.term 
		from VOC_Term t, ALL_Allele a
		where t._Vocab_key = 38
		and t.term in (
			'Targeted (knock-out)',
			'Targeted (knock-in)',
			'Targeted (Floxed/Frt)',
			'Targeted (Reporter)',
			'Targeted (other)',
			'Transgenic (Cre/Flp)',
			'Transgenic (random, expressed)',
			'Transgenic (random, gene disruption)',
			'Transgenic (Reporter)',
			'Transgenic (Transposase)'
			)
		and t._Term_key = a._Allele_Type_key
		order by a.symbol
		''', 'auto')

	for r in results:

		symbol = r['symbol']
		termKey = r['_Term_key']
		oldTerm = r['term']

		#
		# allele-type
		#

		newTermName = ''

		if oldTerm in (
			'Targeted (knock-out)',
			'Targeted (knock-in)',
			'Targeted (Floxed/Frt)',
			'Targeted (Reporter)',
			'Targeted (other)'):
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
			print symbol, oldTerm, newTermName
		else:
			print 'ERROR: ' + r

	print 'end: print generation...'

def processGeneration(generationScript):
	global generationSQL

	# select terms that require migration

	print '\nstart: process generation...'

	results = db.sql('''
		select t._Term_key, t.term 
		from VOC_Term t
		where t._Vocab_key = 38
		and t.term in (
			'Targeted (knock-out)',
			'Targeted (knock-in)',
			'Targeted (Floxed/Frt)',
			'Targeted (Reporter)',
			'Targeted (other)',
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
			'Targeted (knock-out)',
			'Targeted (knock-in)',
			'Targeted (Floxed/Frt)',
			'Targeted (Reporter)',
			'Targeted (other)'):
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

	print 'end: process generation...'

def processIKMC():
	global newAnnotKey

	# IKMC alleles (iin ldb group):
	# 125 KOMP-Regeneron-Project
	# 126 KOMP-CSD-Project
	# 138 EUCOMM projects
	# 143 NorCOMM-projects
	# + add "<tm%(" (tm1a, tm1b, etc.)
	#
	# not in ldb group
	# + add "<tm[0-9][a-e](" (tm1a, tm1b, etc.)
	#

	print '\nstart: processing IKMC alleles...'

	results = db.sql('''
		(
		select a.symbol, a._Allele_key, t._Term_key, t.term
		from ALL_Allele a, VOC_Term t
		where t._Vocab_key = 38
		and a.symbol like '%<tm%(%'
		and t._Term_key = a._Allele_Type_key
		and exists (select 1 from ACC_Accession aa
			where a._Allele_key = aa._Object_key
			and aa._MGIType_key = 11
			and aa._LogicalDB_key in (125, 126, 138, 143)
			)
		)
		union
		(
		select a.symbol, a._Allele_key, t._Term_key, t.term
		from ALL_Allele a, VOC_Term t
		where t._Vocab_key = 38
		and a._Allele_Type_key = t._Term_key
		and t._Term_key = a._Allele_Type_key
		and a.symbol like '%<tm[0-9][a-e](%'
		and not exists (select 1 from ACC_Accession aa
			where a._Allele_key = aa._Object_key
			and aa._MGIType_key = 11
			and aa._LogicalDB_key in (125, 126, 138, 143)
			)
		)
		order by a.symbol
		''', 'auto')

	for r in results:

		symbol = r['symbol']
		aKey = r['_Allele_key']
		termKey = r['_Term_key']
		oldTerm = r['term']

		newAttrName = ''

		#
		# tmX.2() => Null (knock-out)
		# tmXd() => Null (knock-out)
		#
		if (symbol.find('.2(') != -1) \
			or (symbol.find('d(') != -1):
			newAttrName = 'Null (knock-out)'
			newAttrKey = newAttr[newAttrName][0]
			attrFileBCP.write(attrFormat % (newAnnotKey, aKey, newAttrKey, currentDate, currentDate))
			newAnnotKey += 1

		#
		# tmXa() => Null (knock-out), Reporter, Conditional Ready
		#
		elif (symbol.find('a(') != -1):
			newAttrName = 'Null (knock-out)'
			newAttrKey = newAttr[newAttrName][0]
			attrFileBCP.write(attrFormat % (newAnnotKey, aKey, newAttrKey, currentDate, currentDate))
			newAnnotKey += 1

			newAttrName = 'Reporter'
			newAttrKey = newAttr[newAttrName][0]
			attrFileBCP.write(attrFormat % (newAnnotKey, aKey, newAttrKey, currentDate, currentDate))
			newAnnotKey += 1

			newAttrName = 'Conditional Ready'
			newAttrKey = newAttr[newAttrName][0]
			attrFileBCP.write(attrFormat % (newAnnotKey, aKey, newAttrKey, currentDate, currentDate))
			newAnnotKey += 1

		#
		# tmXc() => Conditional Ready
		#
		elif (symbol.find('c(') != -1):
			newAttrName = 'Conditional Ready'
			newAttrKey = newAttr[newAttrName][0]
			attrFileBCP.write(attrFormat % (newAnnotKey, aKey, newAttrKey, currentDate, currentDate))
			newAnnotKey += 1

		#
		# the rest:
		# tmX() => Null (knock-out), Reporter
		# tmX.1() => Null (knock-out), Reporter
		# tmXb() => Null (knock-out), Reporter
		# tmXe() => Null (knock-out), Reporter
		#
		else:
			newAttrName = 'Null (knock-out)'
			newAttrKey = newAttr[newAttrName][0]
			attrFileBCP.write(attrFormat % (newAnnotKey, aKey, newAttrKey, currentDate, currentDate))
			newAnnotKey += 1

			newAttrName = 'Reporter'
			newAttrKey = newAttr[newAttrName][0]
			attrFileBCP.write(attrFormat % (newAnnotKey, aKey, newAttrKey, currentDate, currentDate))
			newAnnotKey += 1
	print 'end: processing IKMC alleles...'

def processAttribute():
	global newAnnotKey

	# special code to handle knock-in / allele-attribute

	hasDriver = []
	results = db.sql('select _Object_key from MGI_Note where _MGIType_key = 11 and _NoteType_key = 1034', 'auto')
	for r in results:
		hasDriver.append(r['_Object_key'])

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
			'Targeted (knock-out)',
			'Targeted (knock-in)',
			'Targeted (Floxed/Frt)',
			'Targeted (Reporter)',
			'Targeted (other)',
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
			attrFileBCP.write(attrFormat % (newAnnotKey, aKey, newAttrKey, currentDate, currentDate))
			newAnnotKey += 1

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
			attrFileBCP.write(attrFormat % (newAnnotKey, aKey, newAttrKey, currentDate, currentDate))
			newAnnotKey += 1

		#
		# if term == 'Targeted (knock-in)'
		# if term == 'Transgenic (Cre/Flp)'
		#
		# 	if driver note, 
		#		then add 'Inserted expressed sequence' and 'Recombinase'
		#
		# 	if inducible note , then add 'Inducible''
		#

		if oldTerm in ('Targeted (knock-in)'):
			if aKey in hasDriver:
				newAttrName = 'Recombinase'
				newAttrKey = newAttr[newAttrName][0]
				attrFileBCP.write(attrFormat % (newAnnotKey, aKey, newAttrKey, currentDate, currentDate))
				newAnnotKey += 1
	
				newAttrName = 'Inserted expressed sequence'
				newAttrKey = newAttr[newAttrName][0]
				attrFileBCP.write(attrFormat % (newAnnotKey, aKey, newAttrKey, currentDate, currentDate))
				newAnnotKey += 1

			if aKey in hasInducible:
				newAttrName = 'Inducible'
				newAttrKey = newAttr[newAttrName][0]
				attrFileBCP.write(attrFormat % (newAnnotKey, aKey, newAttrKey, currentDate, currentDate))
				newAnnotKey += 1

		if oldTerm in ('Transgenic (Cre/Flp)'):
			if aKey in hasInducible:
				newAttrName = 'Inducible'
				newAttrKey = newAttr[newAttrName][0]
				attrFileBCP.write(attrFormat % (newAnnotKey, aKey, newAttrKey, currentDate, currentDate))
				newAnnotKey += 1

	print 'end: processing non-IKMC alleles...'

#
#
# main
#

db.useOneConnection(1)

#
# translate allele-type => allele-generation-type
#

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
results = db.sql('select _Term_key, term from VOC_Term where _Vocab_key = 93', 'auto')
for r in results:
	key = r['term']
	value = r['_Term_key']
	newAttr[key] = []
	newAttr[key].append(value)
print '\nnewAttr...'
print newAttr

alleleGeneration = 'update ALL_Allele set _Allele_Type_key = %s where _Allele_Type_key = %s\n'
derivationGeneration = 'update ALL_CellLine_Derivation set _DerivationType_key = %s where _DerivationType_key = %s\n'

generationSQL = ''
processPrintGeneration(alleleGeneration)
processGeneration(alleleGeneration)
processGeneration(derivationGeneration)

#
# allele sub-types associations
#

results = db.sql('select max(_Annot_key) + 1 as newAnnotKey from VOC_Annot', 'auto')
newAnnotKey = results[0]['newAnnotKey']

# primary key, annotation type (1014), allele key, term key, qualifier key (1614158)
attrFormat = '%s&=&1014&=&%s&=&%s&=&1614158&=&%s&=&%s#=#\n'

attrFileBCP = open('VOC_Annot.bcp', 'w')
processIKMC()
processAttribute()
attrFileBCP.close()

# must be done at the end
# we need to *before* vocabulary to still be in place
# so that the attribute-migration work correctly
print generationSQL
print '\nstart: executing update...'
db.sql(generationSQL, None)
print 'end: executing update...'

db.useOneConnection(0)

