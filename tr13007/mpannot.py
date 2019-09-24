#!/usr/local/bin/python

import sys
import os
import db

sql = '''
WITH mpAnnot AS (
select _object_key, _term_key, _qualifier_key
from voc_annot 
where _annottype_key = 1002 
group by _object_key, _term_key, _qualifier_key having count(*) > 1 
)
select a._annot_key, a._object_key, a._term_key, e._annotevidence_key, aa.accID, t.term
from mpAnnot m, voc_annot a, voc_evidence e, voc_term t, acc_accession aa
where m._object_key = a._object_key
and m._term_key = a._term_key
and a._annottype_key = 1002
and a._annot_key = e._annot_key
and a._object_key = aa._object_key
and aa._mgitype_key = 12
and aa._logicaldb_key = 1 
and a._term_key = t._term_key
order by a._object_key, a._term_key, a._annot_key
'''

results = db.sql(sql, 'auto')
sql = ''
prevKey = 0

for r in results:

	currentKey = r['_object_key'] + r['_term_key']
	objectKey = r['_object_key']
	termKey = r['_term_key']
	aKey = r['_annot_key']
	eKey = r['_annotevidence_key']
	accID = r['accID']
	term = r['term']

	if prevKey != currentKey:
		goodKey = aKey
		prevKey = currentKey
	else:
		badKey = aKey

		if goodKey != badKey:
			print "processing: " , objectKey, termKey, accID, badKey, goodKey, term
			sql += 'update VOC_Evidence set _annot_key = %s where _annotevidence_key = %s;\n' % (goodKey, eKey)
			sql += 'delete from VOC_Annot where _annot_key = %s;\n' % (badKey)
		else:
			print "skipping: good key == bad key ", objectKey, termKey, aKey, accID, term

try:
	db.sql(sql, None)
	db.commit();
except:
	pass

