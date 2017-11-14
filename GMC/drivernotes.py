#!/usr/local/bin/python

'''
#
# migration of bib_dataset/bib_dataset_assoc to bib_workflow_status, bib_workflow_tag
#
'''
 
import sys 
import os
import db
import mgi_utils

#db.setTrace()

# 36770349 = term 'has_driver'
# 11391898 = qualifier 'Not Specified'
# 17396909 = evidence 'Not Specified'

#refKey = 2222
relFormat = '%s|1006|%s|%s|36770349|11391898|17396909|2222|1001|1001|%s|%s\n'

currentDate = mgi_utils.date('%m/%d/%Y')

def doMouse():
    global relKey

    sql = '''
	select distinct a._allele_key, a.symbol, m._marker_key, m.symbol
	from mgi_note n, mgi_notechunk c, all_allele a, mrk_marker m
	where n._notetype_key = 1034 
	and n._note_key = c._note_key
	and n._object_key = a._allele_key
	and c.note = m.symbol
	and m._organism_key = 1
	and a._Allele_Type_key = 847116
        and a.symbol not like 'Gt(ROSA)%'
        and a.symbol not like 'Hprt<%'
        and a.symbol not like 'Col1a1<%'
   	'''

    results = db.sql(sql, 'auto')
    for r in results:
        organizer = r['_allele_key']
	participant = r['_marker_key']
	relBcp.write(relFormat % (relKey, organizer, participant, currentDate, currentDate))
	relKey += 1

#
# non-mouse : marker = yes, mol note = yes
# testing using rat
#
def doNonMouse1():
    global relKey

    sql = '''
	WITH nonmouse AS (
	select distinct a._allele_key, a._Allele_Type_key, a.symbol, r._Refs_key, c.note
	from mgi_note n, mgi_notechunk c, all_allele a, mgi_reference_assoc r
	where n._notetype_key = 1034 
	and n._note_key = c._note_key
	and n._object_key = a._allele_key
	and c.note not like 'unknown%'
	and a._Refs_key = r._Refs_key
	and r._mgitype_key = 11
	and r._refassoctype_key in (1012)
	)
	select n.*, m._marker_key, m._organism_key
	from nonmouse n, mrk_marker m
	where n.note = m.symbol
	and n.note = m.symbol
	and m._organism_key = 40
	and (n._Allele_Type_key != 847116
        	or n.symbol like 'Gt(ROSA)%'
        	or n.symbol like 'Hprt<%'
        	or n.symbol like 'Col1a1<%'
	    )
	'''

    results = db.sql(sql, 'auto')
    for r in results:
        organizer = r['_allele_key']
	participant = r['_marker_key']
	relBcp.write(relFormat % (relKey, organizer, participant, currentDate, currentDate))
	relKey += 1

#
# main
#
relKey = db.sql('select max(_Relationship_key) + 1 as maxkey from MGI_Relationship', 'auto')[0]['maxkey']

db.useOneConnection(1)

relBcp = open('MGI_Relationship.bcp', 'w')

doMouse()
doNonMouse1()

#
#
#

relBcp.close()
 
db.useOneConnection(0)

