#!/usr/local/bin/python

import sys 
import os
import db

user = os.environ['MGD_DBUSER']
passwordFileName = os.environ['MGD_DBPASSWORDFILE']
db.set_sqlUser(user)
db.set_sqlPasswordFromFile(passwordFileName)

def processDerivations():

	derivationSQL = ''

	print 'start: processing derivation names...'

	results = db.sql('''
		select a.name,
			t1.term as creator,
			t2.term as derivationType,
			c.cellLine, 
			s.strain,
			t3.term as vector,
			a._Derivation_key, a._Creator_key, a._Vector_key, 
			a._ParentCellLine_key, a._DerivationType_key
		from ALL_CellLine_Derivation a, ALL_CellLine c, PRB_Strain s, 
			VOC_Term t1, VOC_Term t2, VOC_Term t3
		where a._DerivationType_key in (847116,847126)
		and a._Creator_key = t1._Term_key
		and a._DerivationType_key = t2._Term_key
		and a._Vector_key = t3._Term_key
		and a._ParentCellLine_key = c._CellLine_key
		and c._Strain_key = s._Strain_key
		''', 'auto')

	for r in results:

		newName = r['creator'] + ' ' + r['derivationType'] + ' Library ' + r['cellLine'] + ' ' + r['strain'] + ' ' + r['vector']

		print r['name']
		print newName
		print '===='
		derivationSQL = derivationSQL + \
			'''
			update ALL_CellLine_Derivation
			set name = '%s'
			where _Derivation_key = %s
			''' % (newName, r['_Derivation_key'])

	print derivationSQL
	db.sql(derivationSQL, None)

	#
	# remove duplicates that do not contain cell line #1 but do contain cell line #2
	#

	db.sql('''
		select a1._Derivation_key, a1.name
		into #toDelete
		from ALL_CellLine_Derivation a1, ALL_CellLine_Derivation a2
		where a1.name = a2.name
		and a1._Derivation_key != a2._Derivation_key
		and not exists (select 1 from ALL_CellLine c where a1._Derivation_key = c._Derivation_key)
		and exists (select 1 from ALL_CellLine c where a2._Derivation_key = c._Derivation_key)
		''', None)

	db.sql('''
		delete ALL_CellLine_Derivation 
		from #toDelete t, ALL_CellLine_Derivation a
		where t._Derivation_key = a._Derivation_key''', None)

	#
	# merge duplicate derivations from one cell line to the other
	# where both contain a cell line link
	#

	db.sql('''
		select a1._Derivation_key, a1.name
		into #toMerge1
		from ALL_CellLine_Derivation a1, ALL_CellLine_Derivation a2
		where a1.name = a2.name
		and a1._Derivation_key != a2._Derivation_key
		and exists (select 1 from ALL_CellLine c where a1._Derivation_key = c._Derivation_key)
		and exists (select 1 from ALL_CellLine c where a2._Derivation_key = c._Derivation_key)
		union
		select a1._Derivation_key, a1.name
		from ALL_CellLine_Derivation a1, ALL_CellLine_Derivation a2
		where a1.name = a2.name
		and a1._Derivation_key != a2._Derivation_key
		and not exists (select 1 from ALL_CellLine c where a1._Derivation_key = c._Derivation_key)
		and not exists (select 1 from ALL_CellLine c where a2._Derivation_key = c._Derivation_key)
		''', None)

	db.sql('select *, min(_Derivation_key) as savedKey into #toMerge2 from #toMerge1 group by name', None)

	db.sql('create index #idx1 on #toMerge2(_Derivation_key)', None)
	db.sql('create index #idx2 on #toMerge2(savedKey)', None)

	db.sql('''
		update ALL_CellLine 
		set c._Derivation_key = t.savedKey
		from #toMerge2 t, ALL_CellLine c
		where c._Derivation_key = t._Derivation_key
		''', None)
		
	db.sql('''
		delete ALL_CellLine_Derivation
		from #toMerge2 t, ALL_CellLine_Derivation d
		where d._Derivation_key = t._Derivation_key
		and t._Derivation_key != t.savedKey
		''', None)

	print 'end: processing derivation names...'

#
#
# main
#

db.useOneConnection(1)
processDerivations()
db.useOneConnection(0)

