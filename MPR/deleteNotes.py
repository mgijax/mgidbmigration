#!/usr/local/bin/python

import sys
import os
import string
import db

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

results = db.sql('select a._Allele_key, a.note, a.sequenceNum ' + \
	'from ALL_Note a, ALL_NoteType nt ' +
	'where a._NoteType_key = nt._NoteType_key ' + \
	'and nt.noteType = "General" ' + \
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

    # we want to copy up the i and from j to the end of the notes

    n1 = resgsub.gsub('"', '""', allNotes[:i])
    n2 = resgsub.gsub('"', '""', allNotes[j+(len(endTag)):])
    newNote = n1 + string.lstrip(n2)
#    print 'new note:' + newNote

    # Write notes in chunks of 255

    cmds = []
    s = 1
    while len(newNote) > 255:
	cmds.append('insert into ALL_Note values(%s,%s,%s,0,"%s",getdate(),getdate())' % (k, noteTypeKey, s, newNote[:255]))
        newNote = newNote[255:]
        s = s + 1

    if len(newNote) > 0:
        cmds.append('insert into ALL_Note values(%s,%s,%s,0,"%s",getdate(),getdate())' % (k, noteTypeKey, s, newNote))

    db.sql('delete from ALL_Note where _Allele_key = %s' % (k), None)
    if len(cmds) > 0:
        db.sql(cmds, None)

db.useOneConnection(0)

