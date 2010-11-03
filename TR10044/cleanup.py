#!/usr/local/bin/python

'''
#
# Report:
#       TR10044/GO Notes
#
#	fix GO notes
#	migrate to VOC_Evidence_Property
#
# History:
#
# lec	11/03/2010
#
'''
 
import sys 
import string
import db
import reportlib

CRT = reportlib.CRT
SPACE = reportlib.SPACE
TAB = reportlib.TAB
PAGE = reportlib.PAGE

updateSQL = 'update MGI_NoteChunk set note = "%s" where _Note_key = %s and sequenceNum = %s'

#
# Main
#

db.useOneConnection(1)

results = db.sql('''
	select n._Note_key, nc.sequenceNum, nc.note
	from VOC_Annot a, VOC_Evidence e, MGI_Note n, MGI_NoteChunk nc
	where a._AnnotType_key = 1000 
	and a._Annot_key = e._Annot_key 
	and n._NoteType_key = 1008 
	and n._Object_key = e._AnnotEvidence_key 
	and n._Note_key = nc._Note_key 
	and nc.note like '%protein product:%'
	and nc.note like '%external reference:%'
	''', 'auto')

for r in results:
    key = r['_Note_key']
    s = r['sequenceNum']
    note = r['note']
    newNote = string.replace(note, 'protein product:', 'gene product:')
    newNote = string.replace(newNote, 'external reference:', 'external ref:')
    setSQL = updateSQL % (newNote, key, s)
    print setSQL

db.useOneConnection(0)

