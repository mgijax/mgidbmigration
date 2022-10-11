 
import sys 
import os
import db

db.setTrace()

#
# Main
#

db.useOneConnection(1)

db.sql('update prb_probe set ampPrimer = null where ampPrimer is not null', None)
db.commit()

inFile = open('migrationIDs.txt', 'r')
for line in inFile.readlines():

    tokens = line[:-1].split('\t')

    probeKey = tokens[0]
    name = tokens[1]
    ampId = tokens[2]
    print(probeKey, name, ampId)

    results = db.sql('''
        select a._object_key 
        from acc_accession a, prb_probe p
        where a.accid = '%s' 
        and a._mgitype_key = 3
        and a._object_key = p._probe_key
        and p._segmenttype_key = 63473
        ''' % (ampId), 'auto')

    if len(results) == 0:
        print('invalid amp primer : ' , probeKey, name, ampId)
        #print(ampId)
        continue

    ampKey = results[0]['_object_key']
    sql = "update prb_probe set ampPrimer = %s where _probe_key = %s;" % (ampKey, probeKey)
    db.sql(sql, None)
    db.commit()

inFile.close()

db.useOneConnection(0)
