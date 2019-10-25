#!/usr/local/bin/python

import string
import db

db.useOneConnection(1)

#
# REQUEST 1
#

newGoKey1 = 63641 # GO:0042802

repProteinDict = {}

# these annotations have IDA or IMP with no inferred from and
# does NOT have an IPI annotation
# these will be updated to GO:0042802 'identical protein binding'
# with evidence code IPI
# with inferredFrom Value the rep uniprot protein ID UniProtKB:XXX

db.sql(''' select distinct va._Annot_key, m._Marker_key, m.symbol, ve._annotevidence_key, 
	ve._evidenceTerm_key, ve.inferredFrom
    into temporary table toUpdateNoIPI
    from VOC_Annot va, VOC_Evidence ve, MRK_Marker m
    where va._AnnotType_key = 1000
    and va._Term_key = 63642 -- GO:0042803
    and va._Annot_key = ve._Annot_key
    and ve._evidenceTerm_key in (109, 110) -- IDA, IMP
    and ve.inferredFrom is null
    and va._Object_key = m._Marker_key
    and not exists (select 1
    from VOC_Annot va2, VOC_Evidence ve2
    where va._Annot_key = ve2._Annot_key
    and ve2._evidenceTerm_key = 111 ) -- IPI
    order by va._Annot_key''', None)

db.sql('''create index idx1 on toUpdateNoIPI(_Annot_key)''', None)

# get the rep protein sequence for the marker for the toUpdate set
results = db.sql('''select distinct u._Marker_key, a.accid
    from toUpdateNoIPI u, SEQ_Marker_Cache mc, ACC_Accession a
    where u._Marker_key = mc._Marker_key
    and mc._qualifier_key = 615421 -- representative sequence
    and mc._SequenceType_key = 316348 -- polypeptide
    and mc._Sequence_key = a._Object_key
    and a._MGIType_key = 19
    and a._LogicalDB_key in (13, 41)
    and a.preferred = 1''', 'auto')

for r in results:
    repProteinDict[r['_Marker_key']] = r['accid']

# these annotations have an IPI annotation, these will be updated 
# to GO:0042802 'identical protein binding'
db.sql('''select distinct va._Annot_key, m._Marker_key, m.symbol, ve._annotevidence_key,
        ve._evidenceTerm_key, ve.inferredFrom
    into temporary table withIPI
    from VOC_Annot va, VOC_Evidence ve, MRK_Marker m
    where va._AnnotType_key = 1000
    and va._Term_key = 63642 -- GO:0042803
    and va._Annot_key = ve._Annot_key
    and ve._evidenceTerm_key = 111 -- IPI
    and va._Object_key = m._Marker_key
    order by va._Annot_key''', None)

print 'REQUEST 1A'
print 'GO annotations to GO:0042803 with evidenceCode of IDA or IMP that do not also have IPI'
print 'These are updated to GO:0042802 "identical protein binding" with evidence code IPI and '
print 'inferredFrom Value the rep uniprot protein ID UniProtKB:XXX'

results = db.sql('''select * from toUpdateNoIPI''', 'auto')
toUpdateDict = {}  # some have multiple evidence
for r in results:
    annotKey = r['_Annot_key']
    if annotKey not in toUpdateDict:
	 toUpdateDict[annotKey] = []
    toUpdateDict[annotKey].append(r)

for annotKey in toUpdateDict:
    # 
    annotList = toUpdateDict[annotKey]
    for r in annotList:
	markerKey = r['_Marker_key']
	evidenceKey = r['_annotevidence_key']
	repProtein = ''
	inferredFromNew = ''
	if markerKey in repProteinDict:
	    repProtein = repProteinDict[markerKey]
	sql1 = '''update VOC_Annot
	    set _term_key = %s 
	    where _annot_key = %s''' % (newGoKey1, annotKey)	
	if repProtein != '':
	    inferredFromNew = 'UniProtKB:%s' % repProtein
	sql2 = '''update VOC_Evidence
	    set _evidenceterm_key = 111'''
	if inferredFromNew != '':
	    sql2 = sql2 + ''', inferredFrom = '%s' ''' % inferredFromNew
	sql2 = sql2 + '''\nwhere _annotevidence_key = %s''' % evidenceKey

	print '\n%s IPI %s' % (r['symbol'], inferredFromNew)
	if inferredFromNew == '':
	    print 'No inferredFromNew for %s' % r['symbol']
	print 'sql1: %s' % sql1
	print 'sql2: %s' % sql2
	db.sql(sql1, None)
	db.sql(sql2, None)
	db.commit()       

print '\nREQUEST 1B'
print 'GO annotations to GO:0042803 with evidenceCode of IPI'
print 'These are updated to GO:0042802 "identical protein binding"'

results = db.sql('''select * from withIPI''', 'auto')
for r in results:
    print r
    sql = '''update VOC_Annot
    set _term_key = %s
    where _annot_key = %s''' % (newGoKey1, r['_Annot_key'])
    print 'sql: %s' % sql
    db.sql(sql, None)
    db.commit()

# now run the queries again
print '\nQuery results after REQUEST 1A:'
results = db.sql(''' select distinct va._Annot_key, m._Marker_key, m.symbol, ve._annotevidence_key,
        ve._evidenceTerm_key, ve.inferredFrom
    from VOC_Annot va, VOC_Evidence ve, MRK_Marker m
    where va._AnnotType_key = 1000
    and va._Term_key = 63642 -- GO:0042803
    and va._Annot_key = ve._Annot_key
    and ve._evidenceTerm_key in (109, 110) -- IDA, IMP
    and ve.inferredFrom is null
    and va._Object_key = m._Marker_key
    and not exists (select 1
    from VOC_Annot va2, VOC_Evidence ve2
    where va._Annot_key = ve2._Annot_key
    and ve2._evidenceTerm_key = 111 ) -- IPI
    order by va._Annot_key''', 'auto')
for r in results:
    print r

print '\nQuery results after REQUEST 1B'
results = db.sql('''select distinct va._Annot_key, m._Marker_key, m.symbol, ve._annotevidence_key,
        ve._evidenceTerm_key, ve.inferredFrom
    from VOC_Annot va, VOC_Evidence ve, MRK_Marker m
    where va._AnnotType_key = 1000
    and va._Term_key = 63642 -- GO:0042803
    and va._Annot_key = ve._Annot_key
    and ve._evidenceTerm_key = 111 -- IPI
    and va._Object_key = m._Marker_key
    order by va._Annot_key''', 'auto')
for r in results:
    print r

#
# REQUEST 2
#
print '\nREQUEST 2'
print '''GO annotations made to the term GO:0046982 (protein 
    heterodimerization activity) with IPI and inferred from field. Filled in. These 
    should be changed to GO:0005515, protein binding.'''
newGoKey2 = 1300 # GO:0005515, protein binding
# 63701 # GO:0046982
results = db.sql('''select distinct va._Annot_key, m._Marker_key, m.symbol, 
	ve._annotevidence_key, ve._evidenceTerm_key, ve.inferredFrom
    from VOC_Annot va, VOC_Evidence ve, MRK_Marker m
    where va._AnnotType_key = 1000
    and va._Term_key = 63701 -- GO:0046982
    and va._Annot_key = ve._Annot_key
    and ve._evidenceTerm_key =  111 -- IPI
    and ve.inferredFrom is not null
    and va._Object_key = m._Marker_key''', 'auto')

for r in results:
    sql = '''update VOC_Annot
    set _term_key = %s
    where _annot_key = %s''' % (newGoKey2, r['_Annot_key'])
    print 'sql: %s' % sql
    db.sql(sql, None)
    db.commit()

print '\nQuery results after REQUEST 2:'
results = db.sql('''select distinct va._Annot_key, m._Marker_key, m.symbol,
        ve._annotevidence_key, ve._evidenceTerm_key, ve.inferredFrom
    from VOC_Annot va, VOC_Evidence ve, MRK_Marker m
    where va._AnnotType_key = 1000
    and va._Term_key = 63701 -- GO:0046982
    and va._Annot_key = ve._Annot_key
    and ve._evidenceTerm_key =  111 -- IPI
    and ve.inferredFrom is not null
    and va._Object_key = m._Marker_key''', 'auto')
for r in results:
    print r

db.useOneConnection(0)

print 'done'
