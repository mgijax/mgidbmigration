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

logFile = open('sto19.log', 'w')
errorFile = open('sto19.error.log', 'w')

emapLookup = {}
inFile = open('EMAP-EMAPA_mapping.txt', 'r')
lineNum = 0
for line in inFile.readlines():
	lineNum = lineNum + 1

	tokens = line[:-1].split('\t')
	emapID = tokens[0]
	emapLookup[emapID] = []
	emapLookup[emapID].append(tokens)
inFile.close()
#for r in emapLookup:
#	print emapLookup[r][0][0], emapLookup[r][0][1], emapLookup[r][0][3]

results = db.sql('''
        select distinct p._AnnotEvidence_key, p.value, aa.accID, m.symbol
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
             p.value like '%EMAP:%'
            )
        and a._Term_key = aa._Object_key 
        and aa._MGIType_key = 13  
        and aa.preferred = 1 
        and a._Object_key = m._Marker_key 
        order by p.value
	''', 'auto')

for r in results:
	key = r['_AnnotEvidence_key']
	value = r['value']

	tokens = value.split('; ')

	if len(tokens) > 1:
		keepText = tokens[0]
		emapID = tokens[1]
	else:
		keepText = ''
		emapID = tokens[0]

	search_emapID = emapID.replace('EMAP:', '')
	if emapLookup.has_key(search_emapID):
		newValue = keepText + '; ' + 'EMAPA:' + emapLookup[search_emapID][0][3] + ' ' + emapLookup[search_emapID][0][1]
		updateSQL = '''
			update VOC_Evidence_Property
			set value = '%s'
			where _AnnotEvidence_key = %s
			;
			''' % (newValue, key)
		logFile.write(updateSQL + '\n')
		db.sql(updateSQL, None)
	else:
		errorFile.write(r['accID'] + '\t' + r['symbol'] + '\t' + value + '\n')

db.commit()
db.useOneConnection(0)

