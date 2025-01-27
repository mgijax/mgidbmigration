#
# Consequence Terms are part of the Sequence Ontology
#
 
import sys 
import os
import gzip
import db

fxLookup = {}
results = db.sql('''
select t._term_key, t.term, s.badname, a.accid
from voc_term t, mgi_translation s, acc_accession a
where t._vocab_key = 49
and s._translationtype_key = 1014
and s._object_key = t._term_key
and t._term_key = a._object_key
and a._mgitype_key = 13
''', 'auto')
for r in results:
    key = r['badname']
    value = r['term']
    fxLookup[key] = []
    fxLookup[key].append(value)
#print(fxLookup)

inFile = gzip.open('/data/downloads/download.alliancegenome.org/variants/7.4.0/MGI/MGI.vep.vcf.gz', 'rt')
for line in inFile:

    if line.startswith("##"):
        #print(line)
        continue

    if line.startswith("#"):
        #print(line)
        continue

    #if line.find("MGI:1351639") <= -1:
    #    continue

    columns = line.split('\t')
    rsid = columns[2]

    # split col 7 by ';'
    properties = columns[7].split(';')
    for property in properties:
        # if starts with CSQ
        if property.startswith('CSQ'):
            # split by ',' to find consequence entries
            centries = property.split(',')
            for entry in centries:
                fields = entry.split('|')
                if not fields[4].startswith("MGI:") :
                    continue
                cterms = fields[1].split('&')
                symbol = fields[3]
                mgiid = fields[4]
                for term in cterms:
                    if term in fxLookup:
                        for t in fxLookup[term]:
                            print(rsid + "|" + mgiid + "|" + symbol + "|" + term + "|" + t)

inFile.close()
