#!/usr/local/bin/python

import string
import re
import db

MMR_RE = re.compile('(http.*html)')
MMR2_RE = re.compile('(http.*mmr/)')
replaceWith = 'https://www.jax.org/research-and-faculty/tools/mouse-mutant-resource'

results = db.sql('''select nc._note_key, nc.note 
    from MGI_NoteChunk nc, MGI_Note n
    where nc.note like '%http://www.jax.org/mmr/%'
    and nc._Note_key = n._Note_key
    and n._NoteType_key = 1023''', 'auto')

#
# count before updates
#
print 'MMR Before count: %s' % len(results)
for r in results:
    noteKey = r['_note_key']
    note = r['note']

    match = MMR_RE.search(note)
    if not match:
	#print 'no match for %s %s trying MMR2_RE' % (noteKey, note)
	match = MMR2_RE.search(note)
	if match:
	    #print 'found MMR2_RE match'
	    toReplace = match.group(1)
	    newNote = note.replace(toReplace, replaceWith, 2)
	    newNote = newNote.replace("'", "''")
	    sql = '''update MGI_NoteChunk
                set note = E'%s'
                where _note_key = %s''' % (newNote, noteKey)
	    #print sql
	    db.sql(sql, None)
    else:
	toReplace = match.group(1)
	newNote = note.replace(toReplace, replaceWith, 2)
	newNote = newNote.replace("'", "''")
	#print newNote
        sql = '''update MGI_NoteChunk
                set note = E'%s'
                where _note_key = %s''' % (newNote, noteKey)
	#print sql
	db.sql(sql, None)
    db.commit()

#
# count after updates
#
results = db.sql('''select nc._note_key, nc.note
    from MGI_NoteChunk nc, MGI_Note n
    where nc.note like '%http://www.jax.org/mmr/%'
    and nc._Note_key = n._Note_key
    and n._NoteType_key = 1023''', 'auto')

print 'MMR After count: %s' % len(results)
results = db.sql('''select nc._note_key, nc.note
    from MGI_NoteChunk nc, MGI_Note n
    where nc.note like '%https://www.jax.org/research-and-faculty/tools/mouse-mutant-resource%'
    and nc._Note_key = n._Note_key
    and n._NoteType_key = 1023''', 'auto')

print 'New URL Count: %s' % len(results)

print 'done'
