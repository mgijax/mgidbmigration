#!/usr/local/bin/python

import sys
import os
import string
import regsub
import db

DEBUG = 0

passwordFileName = os.environ['DBPASSWORDFILE']

#
# Main
#

db.useOneConnection(1)
db.set_sqlUser('mgd_dbo')
db.set_sqlPassword(string.strip(open(passwordFileName, 'r').readline()))
db.set_sqlLogFunction(db.sqlLogAll)

inFile = open('Cell_Line_data.txt', 'r')

es = {}
results = db.sql('select c._CellLine_key, a.accID from ALL_CellLine c, ACC_Accession a ' + \
	'where c.isMutant = 1 ' + \
	'and c._CellLine_key = a._Object_key ' + \
	'and a._MGIType_key = 28', 'auto')
for r in results:
    key = r['accID']
    value = r['_CellLine_key']
    es[key] = value

for line in inFile.readlines():

    tokens = string.split(line[:-1], '\t')
    alleleID = tokens[0]
    esID = tokens[1]

    if esID in ['Other (see notes)', 'Not Specified']:
	continue

    if not es.has_key(esID):
	continue

    results = db.sql('select _Object_key from ACC_Accession where accid = "%s"' % (alleleID), 'auto')
    alleleKey = results[0]['_Object_key']

    db.sql('update ALL_Allele set _MutantESCellLine_key = %s where _Allele_key = %s' % (es[esID], alleleKey), None)

# create an annotation that has a missing header

db.sql('delete from VOC_AnnotHeader where _Object_key = 18432 and sequenceNum = 2', None)

db.useOneConnection(0)

