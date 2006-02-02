#!/usr/local/bin/python

import sys
import os
import db
import string
import mgi_utils

TAB = '\t'
CRT = '\n'

def buildTemp(mgiType):

    # select allassoc marker/sequence associations: ~ 580,000

    db.sql('select a._Accession_key, a._MGIType_key, a._Object_key, a._LogicalDB_key, ' + \
	'a.accID, a.prefixPart, a.numericPart, a.private, ' + \
	'r._Refs_key, a._CreatedBy_key, a._ModifiedBy_key, ' + \
	'cdate = convert(char(10), a.creation_date, 101), mdate = convert(char(10), a.modification_date, 101) ' + \
	'into tempdb..allassoc ' + \
	'from ACC_Accession a, ACC_AccessionReference r ' + \
	'where a._MGIType_key = %s ' % (mgiType) + \
	'and a._LogicalDB_key in (9, 13, 27, 35, 36, 41, 53, 59, 60) ' + \
	'and a._Accession_key = r._Accession_key', None)

    db.sql('create index idx1 on tempdb..allassoc(_Accession_key)', None)
    db.sql('create index idx2 on tempdb..allassoc(accID)', None)

    # annotations to non-deleted sequences

    db.sql('select a._Accession_key, a._MGIType_key, a._Object_key, a._LogicalDB_key, ' + \
	'a.accID, a.prefixPart, a.numericPart, a.private, ' + \
	'a._Refs_key, a._CreatedBy_key, a._ModifiedBy_key, a.cdate, a.mdate, sequenceKey = s._Object_key ' + \
	'into tempdb..objects1 ' + \
	'from tempdb..allassoc a, ACC_Accession s, SEQ_Sequence ss ' + \
	'where a.accID = s.accID ' + \
	'and a._LogicalDB_key = s._LogicalDB_key ' + \
	'and s._MGIType_key = 19 ' + \
	'and s._Object_key = ss._Sequence_key ' + \
	'and ss._SequenceStatus_key != 316343', None)

    db.sql('create index idx1 on tempdb..objects1(_Accession_key)', None)
    db.sql('create index idx2 on tempdb..objects1(accID)', None)

    # annotations to deleted sequences

    db.sql('select a._Accession_key, a._MGIType_key, a._Object_key, a._LogicalDB_key, ' + \
	'a.accID, a.prefixPart, a.numericPart, a.private, ' + \
	'a._Refs_key, a._CreatedBy_key, a._ModifiedBy_key, a.cdate, a.mdate, sequenceKey = s._Object_key ' + \
	'from tempdb..allassoc a, ACC_Accession s, SEQ_Sequence ss ' + \
	'where a.accID = s.accID ' + \
	'and a._LogicalDB_key = s._LogicalDB_key ' + \
	'and s._MGIType_key = 19 ' + \
	'and s._Object_key = ss._Sequence_key ' + \
	'and ss._SequenceStatus_key = 316343', None)

    db.sql('create index idx1 on tempdb..objects2(_Accession_key)', None)
    db.sql('create index idx2 on tempdb..objects2(accID)', None)

def dropTables():

    db.sql('drop table tempdb..allassoc', None)
    db.sql('drop table tempdb..objects1', None)
    db.sql('drop table tempdb..objects2', None)

def analysis():

    db.sql('select _Object_key, accID into #dupsbygene from tempdb..allassoc group by accID, _Object_key having count(*) > 1', None)
    db.sql('create index idx1 on #dupsbygene(accID)', None)

    db.sql('select _Object_key, accID into #dupsbyacc from tempdb..allassoc group by accID having count(*) > 1', None)
    db.sql('create index idx1 on #dupsbyacc(accID)', None)

    # duplicates by gene/accid (same accid annotated to same gene more than once)

    fp1 = open('dupAnnotByGeneAcc', 'w')
    results = db.sql('select _Object_key, accID from #dupsbygene', 'auto')
    for r in results:
	fp1.write(str(r['_Object_key']) + TAB + r['accID'] + CRT)
    fp1.write('\n(%d rows affected)\n' % (len(results)))
    fp1.close()


    # duplicates by accid (same accid annotated to more than one gene)

    fp2 = open('dupAnnotByAcc', 'w')
    results = db.sql('select d._Object_key, d.accID from #dupsbyacc d ' + \
	'where not exists (select 1 from #dupsbygene g where d.accID = g.accID)', 'auto')
    for r in results:
	fp2.write(str(r['_Object_key']) + TAB + r['accID'] + CRT)
    fp2.write('\n(%d rows affected)\n' % (len(results)))
    fp2.close()

    # annotations to sequences that are statused as deleted 

    fp3 = open('annotToDeletedSequences', 'w')
    results = db.sql('select _Object_key, accID from tempdb..objects2', 'auto')
    for r in results:
	fp3.write(str(r['_Object_key']) + TAB + r['accID'] + CRT)
    fp3.write('\n(%d rows affected)\n' % (len(results)))
    fp3.close()

def writeBCP():

    assocKey = 1

    results = db.sql('select * from tempdb..objects2', 'auto')
    for r in results:
        outFile.write('%d|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s\n' \
	    % (assocKey, r['sequenceKey'], r['_MGIType_key'], r['_Object_key'], r['_Refs_key'], r['_LogicalDB_key'], r['accID'], \
	    mgi_utils.prvalue(r['prefixPart']), mgi_utils.prvalue(r['numericPart']),  \
	    r['private'], r['_CreatedBy_key'], r['_ModifiedBy_key'], r['cdate'], r['mdate']))
        assocKey = assocKey + 1

    results = db.sql('select * from tempdb..objects1', 'auto')
    for r in results:
        outFile.write('%d|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s\n' \
	    % (assocKey, r['sequenceKey'], r['_MGIType_key'], r['_Object_key'], r['_Refs_key'], r['_LogicalDB_key'], r['accID'], \
	    mgi_utils.prvalue(r['prefixPart']), mgi_utils.prvalue(r['numericPart']),  \
	    r['private'], r['_CreatedBy_key'], r['_ModifiedBy_key'], r['cdate'], r['mdate']))
        assocKey = assocKey + 1

    outFile.close()

#
# Main
#

db.useOneConnection(1)
db.set_sqlLogFunction(db.sqlLogAll)
outFile = open('MGI_Sequence_Assoc.bcp', 'w')
dropTables()
buildTemp(2)
analysis()
writeBCP()
#dropTables()
db.useOneConnection(0)

