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
import mgi_utils

user = os.environ['MGD_DBUSER']
passwordFileName = os.environ['MGD_DBPASSWORDFILE']
db.set_sqlUser(user)
db.set_sqlPasswordFromFile(passwordFileName)

currentDate = mgi_utils.date('%m/%d/%y')

alleleProcessed = []

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
			newTermKey = newTerm[newTermName]
			#print oldTerm, newTermName
			generationSQL = generationSQL + generationScript % (newTermKey, termKey)
		else:
			print 'ERROR: ' + r

	print 'end: process generation...'

def processIKMC():
	global alleleProcessed
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

		alleleProcessed.append(aKey)

		newAttrName = ''

		#
		# tmX.2() => Null/knockout
		# tmXd() => Null/knockout
		#
		if (symbol.find('.2(') != -1) \
			or (symbol.find('d(') != -1):
			newAttrName = 'Null/knockout'
			newAttrKey = newAttr[newAttrName][0]
			attrFileBCP.write(attrFormat % (newAnnotKey, aKey, newAttrKey, currentDate, currentDate))
			newAnnotKey += 1

		#
		# tmXa() => Null/knockout, Reporter, Conditional ready
		#
		elif (symbol.find('a(') != -1):
			newAttrName = 'Null/knockout'
			newAttrKey = newAttr[newAttrName][0]
			attrFileBCP.write(attrFormat % (newAnnotKey, aKey, newAttrKey, currentDate, currentDate))
			newAnnotKey += 1

			newAttrName = 'Reporter'
			newAttrKey = newAttr[newAttrName][0]
			attrFileBCP.write(attrFormat % (newAnnotKey, aKey, newAttrKey, currentDate, currentDate))
			newAnnotKey += 1

			newAttrName = 'Conditional ready'
			newAttrKey = newAttr[newAttrName][0]
			attrFileBCP.write(attrFormat % (newAnnotKey, aKey, newAttrKey, currentDate, currentDate))
			newAnnotKey += 1

		#
		# tmXc() => Conditional ready
		#
		elif (symbol.find('c(') != -1):
			newAttrName = 'Conditional ready'
			newAttrKey = newAttr[newAttrName][0]
			attrFileBCP.write(attrFormat % (newAnnotKey, aKey, newAttrKey, currentDate, currentDate))
			newAnnotKey += 1

		#
		# the rest:
		# tmX() => Null/knockout, Reporter
		# tmX.1() => Null/knockout, Reporter
		# tmXb() => Null/knockout, Reporter
		# tmXe() => Null/knockout, Reporter
		#
		else:
			newAttrName = 'Null/knockout'
			newAttrKey = newAttr[newAttrName][0]
			attrFileBCP.write(attrFormat % (newAnnotKey, aKey, newAttrKey, currentDate, currentDate))
			newAnnotKey += 1

			newAttrName = 'Reporter'
			newAttrKey = newAttr[newAttrName][0]
			attrFileBCP.write(attrFormat % (newAnnotKey, aKey, newAttrKey, currentDate, currentDate))
			newAnnotKey += 1
	print 'end: processing IKMC alleles...'

def processAttribute():
	global alleleProcessed
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

		if aKey in alleleProcessed:
			continue

		newAttrName = ''

		if oldTerm in ('Targeted (knock-out)');
			newAttrName = 'Null/knockout'

		elif oldTerm in ('Targeted (Floxed/Frt)'):
			newAttrName = 'Conditional ready'

		elif oldTerm in ('Targeted (Reporter)'):
			newAttrName = 'Reporter'

		elif oldTerm in ('Transgenic (random, expressed)'):
			newAttrName = 'Inserted expressed sequence'

		elif oldTerm in ('Transgenic (Cre/Flp)'):
			newAttrName = 'Recombinase'

		elif oldTerm in ('Transgenic (Reporter)'):
			newAttrName = 'Reporter'

		elif oldTerm in ('Transgenic (Transposase)'):
			newAttrName = 'Transposase'

		if len(newAttrName) > 0:
			newAttrKey = newAttr[newAttrName][0]
			attrFileBCP.write(attrFormat % (newAnnotKey, aKey, newAttrKey, currentDate, currentDate))
			newAnnotKey += 1

		# secondary atrributes

		if oldTerm in ('Targeted (Floxed/Frt)'):
			newAttrName = 'No Functional Change'
			attrFileBCP.write(attrFormat % (newAnnotKey, aKey, newAttrKey, currentDate, currentDate))
			newAnnotKey += 1

		if oldTerm in ('Targeted (Reporter)'):
			newAttrName = 'Null/knockout'
			attrFileBCP.write(attrFormat % (newAnnotKey, aKey, newAttrKey, currentDate, currentDate))
			newAnnotKey += 1

		#
		# if term == 'Targeted (knock-in)'
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

#
# use existing term keys for new terms
# term names will be changed in the wrapper
#
newTerm = {'Targeted' : 847116, 'Transgenic' : 847126}
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
processGeneration(alleleGeneration)
processGeneration(derivationGeneration)

#
# allele sub-types associations
#

results = db.sql('select max(_Annot_key) + 1 as newAnnotKey from VOC_Annot', 'auto')
newAnnotKey = results[0]['newAnnotKey']

#
# primary key, annotation type (1014), allele key, term key, qualifier key (1614158)
#
attrFormat = '%s&=&1014&=&%s&=&%s&=&1614158&=&%s&=&%s#=#\n'

attrFileBCP = open('VOC_Annot.bcp', 'w')
processIKMC()
processAttribute()
attrFileBCP.close()

#
# must be done at the end
# we need to *before* vocabulary to still be in place
# so that the attribute-migration work correctly
#
print '\nstart: executing update...'
db.sql(generationSQL, None)
print 'end: executing update...'

db.useOneConnection(0)

