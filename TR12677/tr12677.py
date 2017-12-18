#!/usr/local/bin/python

import string
import re
import db

CRT = '\n'
MMR_RE = re.compile('(http.*html)')
replaceWith = 'http://www.jax.org/mmr/newmutations.html'

print 'querying db'
results = db.sql('''select _note_key, note from MGI_NOteChunk
    where note like '%http://www.jax.org/mmr/%'
    order by _Note_key''', 'auto')

print 'iterating through results'
for r in results:
    noteKey = r['_note_key']
    note = r['note']

    match = MMR_RE.search(note)
    if not match:
	print 'no match for %s %s' % (noteKey, note)
    else:
	toReplace = match.group(1)
	newNote = note.replace(toReplace, replaceWith)
	print 'before:'
        print note 
	print 'after:'
	print newNote
	print CRT
	db.sql('''update MGI_NoteChunk
		set note = \'%s\'
		where _note_key = %s''' % (newNote, noteKey), None)
