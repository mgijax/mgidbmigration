import sys
import os
import db

sql = '''
WITH goAnnot AS (
select _object_key, _term_key, _qualifier_key
from voc_annot 
where _annottype_key = 1000 
group by _object_key, _term_key, _qualifier_key having count(*) > 1 
)
select a._annot_key, a._object_key, a._term_key, a._qualifier_key, e._annotevidence_key, aa.accID, t.term
from goAnnot m, voc_annot a, voc_evidence e, voc_term t, acc_accession aa
where m._object_key = a._object_key
and m._term_key = a._term_key
and a._annottype_key = 1000
and a._annot_key = e._annot_key
and a._object_key = aa._object_key
and aa._mgitype_key = 2
and aa._logicaldb_key = 1 
and aa.preferred = 1
and a._term_key = t._term_key
order by a._object_key, a._term_key, a._annot_key, a._qualifier_key
'''

results = db.sql(sql, 'auto')
sql = ''
deletesql = ''
prevKey = 0

for r in results:

	currentKey = r['_object_key'] + r['_term_key'] + r['_qualifier_key']
	objectKey = r['_object_key']
	termKey = r['_term_key']
	qualifierKey = r['_qualifier_key']
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
			print("processing: " , objectKey, termKey, qualifierKey, accID, badKey, goodKey, term)
			sql += 'update VOC_Evidence set _annot_key = %s where _annotevidence_key = %s;\n' % (goodKey, eKey)
			deletesql += 'delete from VOC_Annot where _annot_key = %s;\n' % (badKey)
		else:
			print("skipping: good key == bad key ", objectKey, termKey, qualifierKey, aKey, accID, term)
try:
	db.sql(sql, None)
	db.sql(deletesql, None)
	db.commit();
except:
	pass

