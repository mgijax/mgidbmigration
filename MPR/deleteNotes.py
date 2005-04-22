#!/usr/local/bin/python

import sys
import os
import string
import regsub
import db

DEBUG = 0

passwordFileName = os.environ['DBPASSWORDFILE']

startTag = '<!--start delete-->'
endTag = '<!--stop delete-->'

db.useOneConnection(1)
db.set_sqlUser('mgd_dbo')
db.set_sqlPassword(string.strip(open(passwordFileName, 'r').readline()))
db.set_sqlLogFunction(db.sqlLogAll)

print 'delete Allele notes'

results = db.sql('select _NoteType_key from ALL_NoteType where noteType = "General"', 'auto')
noteTypeKey = results[0]['_NoteType_key']

#	'and a._Allele_key in (16,34928) ' + \
#	'and a._Allele_key in (28597) ' + \
#	'and a._Allele_key in (9536) ' + \

results = db.sql('select a._Allele_key, a.note, a.sequenceNum ' + \
	'from ALL_Note a ' +
	'where a._NoteType_key = %s ' % (noteTypeKey) + \
	'order by a._Allele_key, a.sequenceNum', 'auto')
notes = {}
for r in results:
    key = r['_Allele_key']
    value = r['note']
    if not notes.has_key(key):
	notes[key] = []
    notes[key].append(value)

for k in notes.keys():

    n = notes[k]
    allNotes = string.rstrip(string.join(n, ''))

    i = string.find(allNotes, startTag)
    if i < 0:
	continue
    
    j = string.find(allNotes, endTag)
    if j < 0:
       print 'cannot find end tag for allele key ' + str(n)
       continue

    if i > j:
       print 'delete tags are in incorrect order ' + str(n)
       continue

    # we want to copy up the i and from the end of j to the end of the notes

    n1 = allNotes[:i]
    n2 = allNotes[j+(len(endTag)):]
    newNote = n1 + string.lstrip(n2)

    # Write notes in chunks of 255

    cmds = []
    s = 1

    while len(newNote) > 255:

        n1 = regsub.gsub('"', '""', newNote[:255])
	cmds.append('insert into ALL_Note values(%s,%s,%s,0,"%s",getdate(),getdate())' % (k, noteTypeKey, s, n1))
        newNote = newNote[255:]
        s = s + 1

    if len(newNote) > 0:

        n1 = regsub.gsub('"', '""', newNote)
        cmds.append('insert into ALL_Note values(%s,%s,%s,0,"%s",getdate(),getdate())' % (k, noteTypeKey, s, n1))

    db.sql('delete from ALL_Note where _Allele_key = %s and _NoteType_key = %s' % (k, noteTypeKey), None, execute = not DEBUG)
    if len(cmds) > 0:
        db.sql(cmds, None, execute = not DEBUG)

db.useOneConnection(0)

