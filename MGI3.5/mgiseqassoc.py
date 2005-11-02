#!/usr/local/bin/python

import sys
import os
import db
import mgi_utils

def buildTemp():

    # select allassoc marker/sequence associations: ~ 555,000

    db.sql('select a._Accession_key, markerKey = a._Object_key, a._LogicalDB_key, a.accID, a.prefixPart, a.numericPart, ' + \
	'r._Refs_key, a._CreatedBy_key, a._ModifiedBy_key, ' + \
	'cdate = convert(char(10), a.creation_date, 101), mdate = convert(char(10), a.modification_date, 101) ' + \
	'into tempdb..allassoc ' + \
	'from ACC_Accession a, ACC_AccessionReference r ' + \
	'where a._MGIType_key = 2 ' + \
	'and a._LogicalDB_key in (9, 13, 27, 35, 36, 41, 53, 59, 60) ' + \
	'and a._Accession_key = r._Accession_key', None)

    db.sql('create index idx1 on tempdb..allassoc(_Accession_key)', None)
    db.sql('create index idx2 on tempdb..allassoc(accID)', None)

    # annotations to non-deleted sequences

    db.sql('select a._Accession_key, a.markerKey, a._LogicalDB_key, a.accID, a.prefixPart, a.numericPart, ' + \
	'a._Refs_key, a._CreatedBy_key, a._ModifiedBy_key, a.cdate, a.mdate, sequenceKey = s._Object_key ' + \
	'into tempdb..markers1 ' + \
	'from tempdb..allassoc a, ACC_Accession s, SEQ_Sequence ss ' + \
	'where a.accID = s.accID ' + \
	'and s._MGIType_key = 19 ' + \
	'and s._Object_key = ss._Sequence_key ' + \
	'and ss._SequenceStatus_key != 316343', None)

    db.sql('create index idx1 on tempdb..markers1(_Accession_key)', None)

    # annotations to deleted sequences

    db.sql('select a.* into tempdb..markers2 from tempdb..allassoc a ' + \
	'where not exists (select 1 from tempdb..markers1 m where a._Accession_key = m._Accession_key)', None)

    db.sql('create index idx1 on tempdb..markers2(accID)', None)

def dropTables():

    db.sql('drop table tempdb..allassoc', None)
    db.sql('drop table tempdb..markers1', None)
    db.sql('drop table tempdb..markers2', None)

#
# Main
#

db.useOneConnection(1)
db.set_sqlLogFunction(db.sqlLogAll)
outFile = open('SEQ_Marker_Assoc.bcp', 'w')
#dropTables()
buildTemp()

results = db.sql('select m.*, sequenceKey = s._Object_key ' + \
	'from tempdb..markers2 m, ACC_Accession s ' + \
	'where m.accID = s.accID ' + \
	'and s._MGIType_key = 19', 'auto')
for r in results:
    outFile.write('%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s\n' \
	% (r['sequenceKey'], r['markerKey'], r['_Refs_key'], r['_LogicalDB_key'], r['accID'], \
	mgi_utils.prvalue(r['prefixPart']), mgi_utils.prvalue(r['numericPart']),  \
	r['_CreatedBy_key'], r['_ModifiedBy_key'], r['cdate'], r['mdate']))

results = db.sql('select * from tempdb..markers1', 'auto')
for r in results:
    outFile.write('%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s\n' \
	% (r['sequenceKey'], r['markerKey'], r['_Refs_key'], r['_LogicalDB_key'], r['accID'], \
	mgi_utils.prvalue(r['prefixPart']), mgi_utils.prvalue(r['numericPart']),  \
	r['_CreatedBy_key'], r['_ModifiedBy_key'], r['cdate'], r['mdate']))

outFile.close()
dropTables()
db.useOneConnection(0)
