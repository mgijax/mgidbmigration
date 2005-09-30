#!/usr/local/bin/python

'''
#
# Purpose:
#
# Create bcp file for SEQ_Sequence
#
# Uses environment variables to determine Server and Database
# (DSQUERY and MGD).
#
# Usage:
#	seq.py
#
# History
#
# 10/23/2003	lec
#	- new (TR 3404, JSAM)
#
'''

import sys
import os
import db
import mgi_utils

def writeRecord(r):

        seqBCP.write(mgi_utils.prvalue(r['_Sequence_key']) + DL)
        seqBCP.write(mgi_utils.prvalue(r['_SequenceType_key']) + DL)
        seqBCP.write(mgi_utils.prvalue(r['_SequenceQuality_key']) + DL)
        seqBCP.write(mgi_utils.prvalue(r['_SequenceStatus_key']) + DL)
        seqBCP.write(mgi_utils.prvalue(r['_SequenceProvider_key']) + DL)
        seqBCP.write(mgi_utils.prvalue(r['_Organism_key']) + DL)
        seqBCP.write(mgi_utils.prvalue(r['length']) + DL)
        seqBCP.write(mgi_utils.prvalue(r['description']) + DL)
        seqBCP.write(mgi_utils.prvalue(r['version']) + DL)
        seqBCP.write(mgi_utils.prvalue(r['division']) + DL)
        seqBCP.write(mgi_utils.prvalue(r['virtual']) + DL)
        seqBCP.write(mgi_utils.prvalue(r['numberOfOrganisms']) + DL)
        seqBCP.write(mgi_utils.prvalue(r['srdate']) + DL)
        seqBCP.write(mgi_utils.prvalue(r['sdate']) + DL)
        seqBCP.write(mgi_utils.prvalue(r['_CreatedBy_key']) + DL)
        seqBCP.write(mgi_utils.prvalue(r['_ModifiedBy_key']) + DL)
        seqBCP.write(mgi_utils.prvalue(r['cdate']) + DL)
        seqBCP.write(mgi_utils.prvalue(r['mdate']) + NL)

        rawBCP.write(mgi_utils.prvalue(r['_Sequence_key']) + DL)
        rawBCP.write(mgi_utils.prvalue(r['rawType']) + DL)
        rawBCP.write(mgi_utils.prvalue(r['rawLibrary']) + DL)
        rawBCP.write(mgi_utils.prvalue(r['rawOrganism']) + DL)
        rawBCP.write(mgi_utils.prvalue(r['rawStrain']) + DL)
        rawBCP.write(mgi_utils.prvalue(r['rawTissue']) + DL)
        rawBCP.write(mgi_utils.prvalue(r['rawAge']) + DL)
        rawBCP.write(mgi_utils.prvalue(r['rawSex']) + DL)
        rawBCP.write(mgi_utils.prvalue(r['rawCellLine']) + DL)
        rawBCP.write(mgi_utils.prvalue(r['_CreatedBy_key']) + DL)
        rawBCP.write(mgi_utils.prvalue(r['_ModifiedBy_key']) + DL)
        rawBCP.write(mgi_utils.prvalue(r['cdate']) + DL)
        rawBCP.write(mgi_utils.prvalue(r['mdate']) + NL)

#
# Main
#

seenSeq = []

NL = '\n'
DL = os.environ['FIELDDELIM']

db.set_sqlLogFunction(db.sqlLogAll)
db.useOneConnection(1)
seqBCP = open('SEQ_Sequence.bcp', 'w')
rawBCP = open('SEQ_Sequence_Raw.bcp', 'w')

results = db.sql('select maxS = max(_Sequence_key) from SEQ_Sequence', 'auto')
for r in results:
    maxSequences = r['maxS']

i = 1
j = 100000
x = 100000
while j < maxSequences + x + x:

    results = db.sql('select s.*, ps._Organism_key, ' + \
	    'srdate = convert(char(10), s.seqrecord_date, 101), ' + \
	    'sdate = convert(char(10), s.sequence_date, 101), ' + \
	    'cdate = convert(char(10), s.creation_date, 101), ' + \
	    'mdate = convert(char(10), s.modification_date, 101) ' + \
	    'from SEQ_Sequence s, SEQ_Source_Assoc sa, PRB_Source ps ' + \
	    'where s.numberOfOrganisms is null ' + \
	    'and s._Sequence_key between %d and %d ' % (i, j) + \
	    'and s._Sequence_key = sa._Sequence_key ' + \
	    'and sa._Source_key = ps._Source_key', 'auto')

    for r in results:
	writeRecord(r)

    i = j + 1
    j = j + x

i = 1
j = 100000
x = 100000
while j < maxSequences + x + x:

    results = db.sql('select s.*, ps._Organism_key, ' + \
	    'srdate = convert(char(10), s.seqrecord_date, 101), ' + \
	    'sdate = convert(char(10), s.sequence_date, 101), ' + \
	    'cdate = convert(char(10), s.creation_date, 101), ' + \
	    'mdate = convert(char(10), s.modification_date, 101) ' + \
	    'from SEQ_Sequence s, SEQ_Source_Assoc sa, PRB_Source ps ' + \
	    'where s.numberOfOrganisms <= 1 ' + \
	    'and s._Sequence_key between %d and %d ' % (i, j) + \
	    'and s._Sequence_key = sa._Sequence_key ' + \
	    'and sa._Source_key = ps._Source_key', 'auto')

    for r in results:
	key = r['_Sequence_key']
	writeRecord(r)

    i = j + 1
    j = j + x

i = 1
j = 100000
x = 100000
while j < maxSequences + x + x:

    results = db.sql('select s.*, ps._Organism_key, ' + \
	    'srdate = convert(char(10), s.seqrecord_date, 101), ' + \
	    'sdate = convert(char(10), s.sequence_date, 101), ' + \
	    'cdate = convert(char(10), s.creation_date, 101), ' + \
	    'mdate = convert(char(10), s.modification_date, 101) ' + \
	    'from SEQ_Sequence s, SEQ_Source_Assoc sa, PRB_Source ps ' + \
	    'where s.numberOfOrganisms > 1 ' + \
	    'and s._Sequence_key between %d and %d ' % (i, j) + \
	    'and s._Sequence_key = sa._Sequence_key ' + \
	    'and sa._Source_key = ps._Source_key ' + \
	    'order by s._Sequence_key, ps._Organism_key', 'auto')

    for r in results:
	key = r['_Sequence_key']
	if key not in seenSeq:
	    writeRecord(r)
	    seenSeq.append(key)

    i = j + 1
    j = j + x

seqBCP.close()
rawBCP.close()
db.useOneConnection(0)

