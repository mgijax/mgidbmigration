#!/usr/local/bin/python

import sys
import os
import string
import regsub
import db

startTag = '<!--start delete-->'
endTag = '<!--stop delete-->'

db.useOneConnection(1)
db.set_sqlLogFunction(db.sqlLogAll)

print 'delete Allele notes'

results = db.sql('select _NoteType_key from ALL_NoteType where noteType = "General"', 'auto')
noteTypeKey = results[0]['_NoteType_key']

#	'and a._Allele_key in (16,34928) ' + \

results = db.sql('select e.symbol, a._Allele_key, a.note, a.sequenceNum ' + \
	'from ALL_Allele e, ALL_Note a, ALL_NoteType nt ' +
	'where e._Allele_key = a._Allele_key ' + \
	'and a._NoteType_key = nt._NoteType_key ' + \
	'and nt.noteType = "General" ' + \
	'order by a._Allele_key, a.sequenceNum', 'auto')
notes = {}
alleles = {}
for r in results:
    key = r['_Allele_key']
    value = r['note']
    value2 = r['symbol']

    if not notes.has_key(key):
	notes[key] = []
    notes[key].append(value)

    alleles[key] = value2

for k in notes.keys():

    n = notes[k]
    allNotes = string.rstrip(string.join(n, ''))

    i = string.find(allNotes, startTag)
    j = string.find(allNotes, endTag)

    if i < 0 and j > 0:
	print 'cannot find start tag for allele ' + str(alleles[k])

    if j < 0 and i > 0:
        print 'cannot find end tag for allele ' + str(alleles[k])

db.useOneConnection(0)

