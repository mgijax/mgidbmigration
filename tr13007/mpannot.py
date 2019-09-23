#!/usr/local/bin/python

import sys
import os
import db

sql = '''
WITH mpAnnot AS (
select _object_key, _term_key  
from voc_annot 
where _annottype_key = 1002 
group by _object_key, _term_key having count(*) > 1
)
select a._annot_key, a._object_key, a._term_key, e._annotevidence_key, aa.accID
from voc_annot a, mpAnnot m, voc_evidence e, acc_accession aa
where a._annottype_key = 1002
and a._object_key = m._object_key
and a._term_key = m._term_key
and a._annot_key = e._annot_key
and a._object_key = aa._object_key
and aa._mgitype_key = 12
and aa._logicaldb_key = 1
order by a._object_key, a._term_key, a._annot_key
;
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

	if prevKey != currentKey:
		goodKey = aKey
		prevKey = currentKey
	else:
		badKey = aKey

		if goodKey != badKey:
			print "processing: " , objectKey, termKey, aKey, accID
			sql += 'update VOC_Evidence set _annot_key = %s where _annotevidence_key = %s;\n' % (goodKey, eKey)
			sql += 'delete from VOC_Annot where _annot_key = %s;\n' % (badKey)
		else:
			print "skipping: good key == bad key ", objectKey, termKey, aKey, accID

try:
	db.sql(sql, None)
	db.commit();
except:
	pass

