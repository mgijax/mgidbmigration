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

relFormat = '%s|1006|%s|%s|36770349|11391898|17396909|%s|1001|1001|%s|%s\n'

currentDate = mgi_utils.date('%m/%d/%Y')

def doMouse():
    global relKey

    sql = '''
	select distinct a._allele_key, a.symbol, m._marker_key, m.symbol, r._refs_key
	from mgi_note n, mgi_notechunk c, all_allele a, mrk_marker m, mgi_reference_assoc r
	where n._notetype_key = 1034 
	and n._note_key = c._note_key
	and n._object_key = a._allele_key
	and a._marker_key = m._marker_key
	and a._allele_key = r._object_key
	and r._mgitype_key = 11
	and r._refassoctype_key in (1012)
	-- recombinase attribute/subtype
	and exists (select 1 from VOC_Annot va 
		where va._AnnotType_key = 1014
		and a._Allele_key = va._Object_key
		and va._Term_key = 11025588
		)
	-- Targeted, Endonuclease/mediated
	and a._Allele_Type_key in (847116, 11927650)
        and a.symbol not like 'Gt(ROSA)%'
        and a.symbol not like 'Hprt<%'
        and a.symbol not like 'Col1a1<%'
	and a.symbol not like 'Evx2/Hoxd13<tm4(cre)Ddu>'
   	'''

    results = db.sql(sql, 'auto')
    for r in results:
        organizer = r['_allele_key']
	participant = r['_marker_key']
	refKey = r['_refs_key']
	relBcp.write(relFormat % (relKey, organizer, participant, refKey, currentDate, currentDate))
	relKey += 1

#
# non-mouse : marker = yes, mol note = yes
# testing using rat
#
def doNonMouse1():
    global relKey

    inFile = open('complicated_cre_markers.txt', 'r')

    for line in inFile.readlines():
        tokens = line[:-1].split('\t')
	allele = tokens[0]
	marker = tokens[1]
	organism = tokens[2]

	results = db.sql('''select _allele_key from ALL_Allele where symbol = '%s' ''' % (allele), 'auto')
	if len(results) == 1:
	    organizer = results[0]['_allele_key']
	elif len(results) > 1:
	    print 'more than 1 allele: ', results
	    continue
        else:
	    print 'invalid allele: ', allele
	    continue

	sql = '''select m._marker_key 
		from MRK_Marker m, MGI_Organism o
		where m.symbol = '%s' 
		and m._Organism_key = o._Organism_key
		and o.commonname = '%s'
		''' % (marker, organism)
	results = db.sql(sql, 'auto')
	if len(results) == 1:
	    participant = results[0]['_marker_key']
	elif len(results) > 1:
	    print 'more than 1 marker: ', results
	    continue
        else:
	    #print sql
	    print 'invalid marker: ', marker, organism
	    continue

	relBcp.write(relFormat % (relKey, organizer, participant, currentDate, currentDate))
	relKey += 1

    inFile.close()

#
# main
#
relKey = db.sql('select max(_Relationship_key) + 1 as maxkey from MGI_Relationship', 'auto')[0]['maxkey']

db.useOneConnection(1)

relBcp = open('MGI_Relationship.bcp', 'w')

doMouse()
#doNonMouse1()

#
#
#

relBcp.close()
 
db.useOneConnection(0)

