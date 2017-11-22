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

    print '\n******\n'
    print 'start : doMouse()'

    sql = '''
	select a._Allele_key, a.symbol, m._Marker_key, m.symbol, min(r._Refs_key) as _Refs_key
	from ALL_Allele a, MRK_Marker m, MGI_Reference_Assoc r
	where a._Marker_key = m._Marker_key
	-- exclude deleted alleles
	and a._Allele_Status_key != 847112
	-- Targeted, Endonuclease/mediated
	and a._Allele_Type_key in (847116, 11927650)
        and a.symbol not like 'Gt(ROSA)%'
        and a.symbol not like 'Hprt<%'
        and a.symbol not like 'Col1a1<%'
	and a.symbol not like 'Evx2/Hoxd13<tm4(cre)Ddu>'
	-- recombinase attribute/subtype
	and exists (select 1 from VOC_Annot va 
		where va._AnnotType_key = 1014
		and a._Allele_key = va._Object_key
		and va._Term_key = 11025588
		)
	-- molecular reference
	and a._Allele_key = r._Object_key
	and r._MGIType_key = 11
	and r._RefAssocType_key in (1012)
	group by a._Allele_key, a.symbol, m._Marker_key, m.symbol
   	'''

    results = db.sql(sql, 'auto')
    for r in results:
        organizer = r['_Allele_key']
	participant = r['_Marker_key']
	refsKey = r['_Refs_key']
	relBcp.write(relFormat % (relKey, organizer, participant, refsKey, currentDate, currentDate))
	relKey += 1

    print 'end: doMouse()'
    print '\n******\n'

def doComplicated():
    global relKey

    print '\n******\n'
    print 'start : doComplicated()'

    inFile = open('complicated_cre_markers.txt', 'r')

    for line in inFile.readlines():
        tokens = line[:-1].split('\t')
	allele = tokens[0]
	marker = tokens[1]
	chromosome = tokens[2]
	organism = tokens[3]

	# use UN chromosome if none given
	if organism != 'mouse, laboratory' and len(chromosome) == 0:
	    chromosome = 'UN'

	results = db.sql('''select a._Allele_key, min(r._Refs_key) as _Refs_key
		from ALL_Allele a, MGI_Reference_Assoc r
		where a.symbol = '%s' 
		and a._Allele_key = r._Object_key
		and r._MGIType_key = 11
		and r._RefAssocType_key in (1012)
		group by a._Allele_key
		''' % (allele), 'auto')
	if len(results) == 1:
	    organizer = results[0]['_Allele_key']
	    refsKey = results[0]['_Refs_key']
	elif len(results) > 1:
	    print 'more than 1 allele: ', results, allele
	    continue
        else:
	    print 'invalid allele, check molecular reference: ', allele
	    continue

	# if mouse, then ignore chromosome/allow user to leave blank
	if organism == 'mouse, laboratory':
		sql = '''select m._Marker_key, m.chromosome
			from MRK_Marker m, MGI_Organism o
			where m.symbol = '%s' 
			and m._Organism_key = o._Organism_key
			and o.commonname = '%s'
			and m._Marker_Status_key = 1
			''' % (marker, organism)

	# if non-mouse, then chromosome is required
	else:
		sql = '''select m._Marker_key, m.chromosome
			from MRK_Marker m, MGI_Organism o
			where m.symbol = '%s' 
			and m._Organism_key = o._Organism_key
			and o.commonname = '%s'
			and m._Marker_Status_key = 1
			and m.chromosome = '%s'
			''' % (marker, organism, chromosome)
	#print sql
	results = db.sql(sql, 'auto')
	if len(results) == 1:
	    participant = results[0]['_Marker_key']
	    chromosome = results[0]['chromosome']
	elif len(results) > 1:
	    print 'more than 1 marker: ', results, marker, organism
	    continue
        else:
	    print 'adding new marker: ', marker, organism, chromosome
	    sql = '''
	    	insert into MRK_Marker values 
		(
		(select max(_Marker_key) + 1 from MRK_Marker),
		(select _Organism_key from MGI_Organism where commonname = '%s'),
		1,1,'%s','%s','%s',null,1001,1001,now(),now()
	    	)
	    	''' % (organism, marker, marker, chromosome)
	    print sql
	    db.sql(sql, None)
	    db.commit()
	    # get the new particpant key
	    results = db.sql('select max(_Marker_key) as _Marker_key from MRK_Marker', 'auto')
	    participant = results[0]['_Marker_key']

	relBcp.write(relFormat % (relKey, organizer, participant, refsKey, currentDate, currentDate))
	relKey += 1

    inFile.close()

    print 'end : doComplicated()'
    print '\n******\n'

#
# main
#
relKey = db.sql('select max(_Relationship_key) + 1 as maxkey from MGI_Relationship', 'auto')[0]['maxkey']

db.useOneConnection(1)

relBcp = open('MGI_Relationship.bcp', 'w')

doMouse()
doComplicated()

relBcp.close()
 
db.useOneConnection(0)

