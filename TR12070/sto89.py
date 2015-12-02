#!/usr/local/bin/python

import sys 
import os
import db

#db.setTrace()
db.setAutoTranslate(False)
db.setAutoTranslateBE(False)

#
# Main
#

querySQL = '''
select a.symbol, n._note_key, n._object_key, c.note
from ALL_Allele a, MGI_Note n, MGI_NoteChunk c
where n._note_key = c._note_key
and n._notetype_key = 1032
and lower(c.note) like 'induced by %'
and n._object_key = a._allele_key
'''

db.useOneConnection(1)

results = db.sql(querySQL, 'auto')
for r in results:
	key = r['_Note_key']
	note = r['note']
	newnote = note.replace('induced by ', '')
	updateSQL = 'update MGI_NoteChunk set note = \'%s\' where _Note_key = %s' % (newnote, key)
	db.sql(updateSQL, None)

	print r
	print updateSQL
	print "\n\n"
		
print 'number of rows affected : \n', str(len(results))

results = db.sql(querySQL, 'auto')
if len(results) == 0:
	print "\nsuccessful\n"
else:
	print "\nfailed\n"

db.commit()
db.useOneConnection(0)

