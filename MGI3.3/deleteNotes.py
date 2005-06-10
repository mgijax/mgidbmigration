#!/usr/local/bin/python

import sys
import os
import string
import regsub
import db

DEBUG = 1

passwordFileName = os.environ['DBPASSWORDFILE']

startTag = '<!--start delete-->'
endTag = '<!--stop delete-->'

def createNewNote(k, notes):
    global noteKey

    obj = noteObjects[k]

    # escape quotes
    newNote = regsub.gsub('"', '""', notes)

    insertCmd = []

    # master MGI_Note record

    insertCmd.append('insert into MGI_Note values(%s,%s,%s,%s,%s,%s,"%s","%s")' \
	% (noteKey, obj['_Object_key'], obj['_MGIType_key'], obj['_NoteType_key'], \
	   obj['_CreatedBy_key'], obj['_ModifiedBy_key'], obj['cdate'], obj['mdate']))

    # Write notes in chunks of 255
    s = 1
    while len(newNote) > 255:
	insertCmd.append('insert into MGI_NoteChunk values(%s,%s,"%s",%s,%s,"%s","%s")' \
		% (noteKey, s, newNote[:255], obj['_CreatedBy_key'], obj['_ModifiedBy_key'], obj['cdate'], obj['mdate']))
        newNote = newNote[255:]
        s = s + 1

    if len(newNote) > 0:
	insertCmd.append('insert into MGI_NoteChunk values(%s,%s,"%s",%s,%s,"%s","%s")' \
		% (noteKey, s, newNote, obj['_CreatedBy_key'], obj['_ModifiedBy_key'], obj['cdate'], obj['mdate']))

    noteKey = noteKey + 1
    return insertCmd

#
# Main
#

db.useOneConnection(1)
db.set_sqlUser('mgd_dbo')
db.set_sqlPassword(string.strip(open(passwordFileName, 'r').readline()))
db.set_sqlLogFunction(db.sqlLogAll)

print 'delete Allele notes that are tagged for deletion'

results = db.sql('select max(_Note_key) + 1 from MGI_Note', 'auto')
noteKey = results[0]['']

db.sql('select distinct n.*, ' + \
        'cdate = convert(char(10), n.creation_date, 101), ' + \
        'mdate = convert(char(10), n.modification_date, 101) ' + \
        'into #notes ' + \
        'from MGI_Note n, MGI_NoteChunk nc, MGI_NoteType nt ' + \
        'where n._MGIType_key = 11 ' + \
        'and n._NoteType_key = nt._NoteType_key ' + \
        'and nt.noteType = "General" ' + \
        'and n._Note_key = nc._Note_key ', None)

db.sql('create index idx1 on #notes(_Note_key)', None)

results = db.sql('select * from #notes', 'auto')
noteObjects = {}
for r in results:
    key = r['_Note_key']
    value = r
    noteObjects[key] = value

results = db.sql('select n._Note_key, nc.note, nc.sequenceNum ' + \
        'from #notes n, MGI_NoteChunk nc ' + \
        'where n._Note_key = nc._Note_key ' + \
        'order by n._Note_key, nc.sequenceNum', 'auto')

notes = {}
for r in results:
    key = r['_Note_key']
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

    db.sql('delete from MGI_Note where _Note_key = %s' % (k), None, execute = not DEBUG)
    db.sql(createNewNote(k, newNote), None, execute = not DEBUG)

db.useOneConnection(0)

