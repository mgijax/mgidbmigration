#!/usr/local/bin/python

import sys 
import os
import db

db.setTrace()
db.setAutoTranslate(False)
db.setAutoTranslateBE(False)

#
# Main
#

db.useOneConnection(1)

logFile = open('sto20.log', 'w')
errorFile = open('sto20.error.log', 'w')

maLookup = {}
inFile = open('MA-EMAPA-TS.txt', 'r')
for line in inFile.readlines():
	tokens = line[:-1].split('\t')
	maID = tokens[0].strip()
	emapaID = tokens[1] + ' ' + tokens[2]
	maLookup[maID] = emapaID
inFile.close()
for r in maLookup.items():
	print r[0], r[1]

results = db.sql('''
        select distinct p._EvidenceProperty_key, p.value, aa.accID, m.symbol
        from VOC_Annot a, VOC_Evidence e, VOC_Evidence_Property p, VOC_Term t,
		ACC_Accession aa, MRK_Marker m
        where a._AnnotType_key = 1000 
        and a._Annot_key = e._Annot_key 
        and e._AnnotEvidence_key = p._AnnotEvidence_key
        and p._PropertyTerm_key = t._Term_key
        and t._Vocab_key = 82
        and t.term not in ('anatomy', 
                'cell type', 
                'dual-taxon ID', 
                'evidence', 
                'external ref', 
                'gene product', 
                'modification', 
                'target', 
                'text')
        and p.value is not null 
        and (
             p.value like '%MA:%'
            )
        and a._Term_key = aa._Object_key 
        and aa._MGIType_key = 13  
        and aa.preferred = 1 
        and a._Object_key = m._Marker_key 
        order by p.value
	''', 'auto')

for r in results:
	propertyKey = r['_EvidenceProperty_key']
	value = r['value']

	tokens = value.split(';')
	try:
		maID = tokens[1].strip()
		newValue = tokens[0]
	except:
		maID = tokens[0].strip()
		newValue = ''

	if maID in maLookup:
		newValue = newValue + ' ; ' + maLookup[maID]
		updateSQL = '''
			update VOC_Evidence_Property
			set value = '%s'
			where _EvidenceProperty_key = %s
			;
			''' % (newValue, propertyKey)
		logFile.write(updateSQL + '\n')
		#db.sql(updateSQL, None)
	else:
		errorFile.write(r['accID'] + '\t' + r['symbol'] + '\t' + value + '\n')

db.commit()
db.useOneConnection(0)

