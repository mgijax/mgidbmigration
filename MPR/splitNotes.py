#!/usr/local/bin/python

import sys
import os
import string
import regsub
import db

DEBUG = 0

passwordFileName = os.environ['DBPASSWORDFILE']

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

print 'split Allele notes'

results = db.sql('select max(_Note_key) + 1 from MGI_Note', 'auto')
noteKey = results[0]['']

# 'and a._Object_key = 17309 '

db.sql('select distinct n.*, ' + \
	'cdate = convert(char(10), n.creation_date, 101), ' + \
	'mdate = convert(char(10), n.modification_date, 101) ' + \
	'into #notes ' + \
	'from VOC_Annot a, VOC_Evidence e, MGI_Note n, MGI_NoteChunk nc ' + \
	'where a._AnnotType_key in (1001, 1002) ' + \
	'and a._Annot_key = e._Annot_key ' + \
	'and e._AnnotEvidence_key = n._Object_key ' + \
	'and n._MGIType_key = 25 ' + \
	'and n._Note_key = nc._Note_key ' + \
	'and nc.note like "%#%"', None)

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

    # delete the old note
    db.sql('delete from MGI_Note where _Note_key = %s' % (k), None, execute = not DEBUG)

    n = notes[k]
    allNotes = string.rstrip(string.join(n, ''))

    # split the notes by the "#" tag
    tokens = string.split(allNotes, '#')

    # for each non-null note (token), create a new note record

    for t in tokens:
       if len(t) == 0:
	   continue
       db.sql(createNewNote(k, string.strip(t)), None, execute = not DEBUG)


db.sql('delete from MGI_NoteChunk where note = ""', None)

db.useOneConnection(0)

