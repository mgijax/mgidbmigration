#!/usr/local/bin/python

import sys 
import string
import db
import reportlib
import mgi_utils

CRT = reportlib.CRT
SPACE = reportlib.SPACE
TAB = reportlib.TAB
PAGE = reportlib.PAGE

#
# Main
#

fp = reportlib.init('mpannotations', printHeading = 0)

# select all Genotype annotations that have PS annotations and no MP annotations

db.sql('select distinct a._Object_key into #tomigrate from VOC_Annot a where a._AnnotType_key = 1001 ' + \
	'and not exists (select 1 from VOC_Annot a2 where a2._AnnotType_key = 1002 ' + \
	'and a._Object_key = a2._Object_key)', None)

db.sql('create index idx1 on #tomigrate (_Object_key)', None)

results = db.sql('select t._Object_key, g.accID ' + \
	'from #tomigrate t, ACC_Accession g ' + \
	'where t._Object_key = g._Object_key ' + \
	'and g._MGIType_key = 12 ', 'auto')
objectID = {}
for r in results:
    key = r['_Object_key']
    value = r['accID']
    objectID[key] = value

results = db.sql('select distinct ac._Object_key, ac.accID ' + \
	'from #tomigrate t, VOC_Annot a, ACC_Accession ac ' + \
	'where t._Object_key = a._Object_key ' + \
	'and a._AnnotType_key = 1001 ' + \
	'and a._Term_key = ac._Object_key ' + \
	'and ac._MGIType_key = 13 ' + \
	'and ac.preferred = 1', 'auto')
termID = {}
for r in results:
    key = r['_Object_key']
    value = r['accID']
    termID[key] = value

results = db.sql('select e._AnnotEvidence_key, nc.note, nc.sequenceNum ' + \
	'from #tomigrate t, VOC_Annot a, VOC_Evidence e, MGI_Note n, MGI_NoteChunk nc ' + \
	'where t._Object_key = a._Object_key ' + \
	'and a._AnnotType_key = 1001 ' + \
	'and a._Annot_key = e._Annot_key ' + \
	'and e._AnnotEvidence_key = n._Object_key ' + \
	'and n._MGIType_key = 25 ' + \
	'and n._Note_key = nc._Note_key ' + \
	'order by e._AnnotEvidence_key, nc.sequenceNum', 'auto')
enote = {}
for r in results:
    key = r['_AnnotEvidence_key']
    value = string.strip(r['note'])

    if not enote.has_key(key):
	enote[key] = []
    enote[key].append(value)

results = db.sql('select t._Object_key, a._Term_key, a.isNot, ' + \
	'e._AnnotEvidence_key, e.inferredFrom, ' + \
	'ecode = ev.abbreviation, jnumID = b.accID, ' + \
	'createdBy = u1.login, ' + \
	'ecdate = convert(char(10), e.creation_date, 101) ' + \
	'from #tomigrate t, VOC_Annot a, VOC_Evidence e, VOC_Term ev, ACC_Accession b, MGI_User u1 ' + \
	'where t._Object_key = a._Object_key ' + \
	'and a._AnnotType_key = 1001 ' + \
	'and a._Annot_key = e._Annot_key ' + \
	'and e._EvidenceTerm_key = ev._Term_key ' + \
	'and e._CreatedBy_key = u1._User_key ' + \
	'and e._Refs_key = b._Object_key ' + \
	'and b._MGIType_key = 1 ' + \
	'and b._LogicalDB_key = 1 ' + \
	'and b.prefixPart = "J:" ', 'auto')

for r in results:
    key = r['_Object_key']
    termKey = r['_Term_key']
    evKey = r['_AnnotEvidence_key']

    if r['isNot'] == '1':
	isNot = 'NOT'
    else:
	isNot = ''

    if enote.has_key(evKey):
	note = string.join(enote[evKey], ' ')
    else:
	note = ''

    fp.write(termID[termKey] + TAB + \
             objectID[key] + TAB + \
             r['jnumID'] + TAB + \
             r['ecode'] + TAB + \
             mgi_utils.prvalue(r['inferredFrom']) + TAB + \
             mgi_utils.prvalue(isNot) + TAB + \
	     r['createdBy'] + TAB + \
	     r['ecdate'] + TAB + \
	     mgi_utils.prvalue(note) + CRT)

reportlib.finish_nonps(fp)

