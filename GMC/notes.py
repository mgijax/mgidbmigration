#!/usr/local/bin/python
 
import sys
import os
import db

#
# Main
#

noteTables = { 'GXD_AssayNote':'_assay_key',
	}

db.useOneConnection(1)

for t in noteTables:

        noteLookup = {}
	table = t
	tkey = noteTables[t]
	print table, tkey

	sqlFile = open(table + '.sql', 'w')

	querySQL = '''
		select a.%s as tkey, a.*
		from %s a
		where exists (select * from %s b where a.%s = b.%s and b.sequenceNum > 1)
		order by a.sequenceNum, %s
		''' % (tkey, table, table, tkey, tkey, tkey)
	print querySQL
	results = db.sql(querySQL, 'auto')

	for r in results:
   		key = r['tkey']
   		value = r['assayNote']
   		value = value.replace('\\', '\\\\')
   		value = value.replace('#', '\#')
   		value = value.replace('?', '\?')
   		value = value.replace('\n', '\\n')
   		value = value.replace('\t', '\\t')
   		value = value.replace("'", "''")
   		value = value.replace('-', '\-')
   		value = value.replace('(', '\(')
   		value = value.replace(')', '\)')
   		if noteLookup.has_key(key):
        		noteLookup[key] = noteLookup[key] + value
   		else:
        		noteLookup[key] = value

	for r in noteLookup:
		note = noteLookup[r]
		updateSQL = '''update %s set assayNote = E'%s' where %s = %s and sequenceNum = 1;''' % (table, note, tkey, r)
		sqlFile.write(updateSQL + "\n")
		deleteSQL = 'delete from %s where %s = %s and sequenceNum > 1;' % (table, tkey, r)
		sqlFile.write(deleteSQL + "\n")
		sqlFile.write("\n\n")

	sqlFile.close()

db.useOneConnection(0)

