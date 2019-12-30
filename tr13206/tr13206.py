#!/usr/local/bin/python

import sys
import os
import db
import string

TAB = '\t'
CRT = '\n'

cmd1 = '''select a.symbol, nc._note_key, nc.note
from MGI_Note n, MGI_NoteChunk nc, ALL_Allele a
where n._MGIType_key = 11
and n._NoteType_key = 1021
and nc.note ilike '%This is a new promoter%'
and n._Object_key = a._Allele_key
and n._Note_key = nc._Note_key''' 

updateList = []
fp = open('tr13206.rpt', 'w')

results = db.sql(cmd1, 'auto')

for r in results:
    note = r['note']
    noteKey = r['_note_key']
    symbol = r['symbol']
    toFind = ''
    if string.find(note, 'This is a new promoter 1') != -1:
	toFind = 'This is a new promoter 1'
    elif string.find(note, 'This is a new promoter 2') != -1:
        toFind = 'This is a new promoter 2'
    elif string.find(note, 'This is a new promoter 3') != -1:
        toFind = 'This is a new promoter 3'
    elif string.find(note, 'This is a new promoter 4') != -1:
        toFind = 'This is a new promoter 4'
    elif string.find(note, 'This is a new promoter 5') != -1:
        toFind = 'This is a new promoter 5'
    elif string.find(note, 'This is a new promoter 6') != -1:
        toFind = 'This is a new promoter 6'
    elif string.find(note, 'This is a new promoter 7') != -1:
        toFind = 'This is a new promoter 7'
    elif string.find(note, 'This is a new promoter 8') != -1:
        toFind = 'This is a new promoter 8'
    elif string.find(note, 'This is a new promoter 9') != -1:
        toFind = 'This is a new promoter 9'
    else:
	toFind = 'This is a new promoter'

    note = note.replace(toFind, 'human beta-actin promoter, SV40 polyA')
    cmd2 = "update MGI_NoteChunk set note = '%s' where _note_key = %s" % (note, noteKey)
    db.sql(cmd2, None)
    fp.write('%s%s%s%s' % (symbol, TAB, note, CRT))
db.commit();

results = db.sql(cmd1)

fp.write(CRT)
fp.write('Count of "This is a new promoter" in the database: %s' % len(results))
fp.close()

