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


# Parse mapping file into lookup
#	of {emap_id : 'emapa_id + TS'}
emapLookup = {}
inFile = open('EMAP-EMAPA_mapping.txt', 'r')
lineNum = 0
for line in inFile.readlines():
	lineNum = lineNum + 1

	tokens = line[:-1].split('\t')
	emapID = 'EMAP:' + tokens[0].strip()
	tsValue = tokens[1].strip()
	emapaID = tokens[3].strip()

	# format of new EMAPA ID + TS
	propertyValue = 'EMAPA:%s %s' % (emapaID, tsValue)
	
	# if there are duplicate mappings
	#	the last value in the file wins
	emapLookup[emapID] = propertyValue
inFile.close()
#for emap, emapa in emapLookup.items():
#	print emap, emapa

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
             p.value like '%EMAP:%'
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

	# parse out comments, which occur after the last semicolon
	tokens = value.split(';')
	comments = ''

	if len(tokens) > 1:
		comments = ''.join(tokens[:-1]).strip()
	# force uppercase ID for searching
	emapID = tokens[-1].strip().upper()

	# skip any blank property values there may be
	if not emapID:
		continue

	if emapID in emapLookup:
		newValue = emapLookup[emapID]

		# add any pre-existing comments
		if comments:
			newValue = '%s; %s' % (comments, newValue)

		updateSQL = '''
			update VOC_Evidence_Property
			set value = '%s'
			where _EvidenceProperty_key = %s
			;
			''' % (newValue, propertyKey)
		logFile.write(updateSQL + '\n')
		db.sql(updateSQL, None)
	else:
		errorFile.write(r['accID'] + '\t' + r['symbol'] + '\t' + value + '\n')

db.commit()
db.useOneConnection(0)

