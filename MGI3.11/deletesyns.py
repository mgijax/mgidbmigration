#!/usr/local/bin/python

import sys
import os
import string
import db

radar = os.environ['RADARDB']
taxid = 9606

passwordFileName = os.environ['DBPASSWORDFILE']

db.useOneConnection(1)
db.set_sqlUser('mgd_dbo')
db.set_sqlPassword(string.strip(open(passwordFileName, 'r').readline()))
db.set_sqlLogFunction(db.sqlLogAll)

print 'synonyms associated with J:66660, J:66661 and match EG human by case'

results = db.sql('select m._Other_key, m.name, s.synonym ' + \
	'from MRK_Other m, %s..DP_EntrezGene_Info e, %s..DP_EntrezGene_Synonym s ' % (radar, radar) + \
	'where m._Refs_key in (67607, 67608) ' + \
	'and e.taxID = %s ' % (taxid) + \
	'and e.geneID = s.geneID ' + \
	'and m.name = s.synonym ', 'auto')
for r in results:

    if r['name'] == r['synonym']:

	deleteIt = 1

	for i in range(len(r['name'])):
	    if r['name'][i] not in string.uppercase:
		deleteIt = 0
		break

	if deleteIt:
            key = r['_Other_key']
	    print r['name']
            db.sql('delete MRK_Other where _Other_key = %s' % (key), None)

print 'synonyms with no J: that exactly match an EntrezGene human synonym'

results = db.sql('select m._Other_key, m.name, s.synonym ' + \
	'from MRK_Other m, %s..DP_EntrezGene_Info e, %s..DP_EntrezGene_Synonym s ' % (radar, radar) + \
	'where m._Refs_key is null ' + \
	'and e.taxID = %s ' % (taxid) + \
	'and e.geneID = s.geneID ' + \
	'and m.name = s.synonym ', 'auto')
for r in results:
    if r['name'] == r['synonym']:

	deleteIt = 1

	for i in range(len(r['name'])):
	    if r['name'][i] not in string.uppercase:
		deleteIt = 0
		break

	if deleteIt:
            key = r['_Other_key']
	    print r['name']
            db.sql('delete MRK_Other where _Other_key = %s' % (key), None)

print 'allele name file'

results = db.sql('select a.accID, a._Object_key ' + \
	'from ACC_Accession a ' + \
	'where a._MGIType_key = 2 ' + \
	'and a._LogicalDB_key = 1 ' + \
	'and a.preferred = 1 ' + \
	'and a.prefixPart = "MGI:"', 'auto')
markers = {}
for r in results:
    key = r['accID']
    value = r['_Object_key']
    markers[key] = value

fp = open('Allelenames_to_delete_with_mgiids_011905.txt', 'r')

for line in fp.readlines():
     tokens = string.split(line[:-1], '\t')
     print str(tokens)
     accID = tokens[0]
     synonym = tokens[1]

     db.sql('delete from MRK_Other where name = "%s" and _Marker_key = %s' % (synonym, markers[accID]), None)
fp.close()

print 'allele symbol file'

fp = open('AlleleSymbols_to_delete_with_mgiids_012505.txt', 'r')

for line in fp.readlines():
     tokens = string.split(line[:-1], '\t')
     accID = tokens[0]
     synonym = tokens[1]

     db.sql('delete from MRK_Other where name = "%s" and _Marker_key = %s' % (synonym, markers[accID]), None)
fp.close()

db.useOneConnection(0)
