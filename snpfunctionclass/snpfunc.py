#
# Consequence Terms are part of the Sequence Ontology
#
 
import sys 
import os
import gzip

mgiids = []
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
                    print(symbol + "|" + mgiid + "|" + rsid + "|" + term)
                    #x = (rsid,symbol,mgiid,term)
                    #if x not in mgiids:
                    #    mgiids.append(x)

inFile.close()

#for r in mgiids:
#    print(r)

