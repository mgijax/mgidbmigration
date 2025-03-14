#
# make the Ensembl Reg 108 ID an Exact Synonym of the Marker
#

import sys
import os
import db
import mgi_utils

results = db.sql('''
select m.symbol, m._marker_key, a.accid as mgiId, l.chromosome, l.startCoordinate, l.endCoordinate, l.strand, s.*,
m.symbol || ' from ENSEMBL 108 has alleles' as note
from seq_marker_cache s, mrk_marker m, acc_accession a, mrk_location_cache l
where s._logicaldb_key = 222
and s._marker_key = m._marker_key
and s._marker_key = a._object_key
and a._mgitype_key = 2
and a._logicaldb_key = 1
and a.preferred = 1
and s._marker_key = l._marker_key
and exists (select 1 from all_allele a where a._marker_key = s._marker_key )
union
select m.symbol, m._marker_key, a.accid as mgiId, l.chromosome, l.startCoordinate, l.endCoordinate, l.strand, s.*,
m.symbol || ' from ENSEMBL 108 has relationship' as note
from seq_marker_cache s, mrk_marker m, acc_accession a, mrk_location_cache l
where s._logicaldb_key = 222
and s._marker_key = m._marker_key
and s._marker_key = a._object_key
and a._mgitype_key = 2
and a._logicaldb_key = 1
and a.preferred = 1
and s._marker_key = l._marker_key
and not exists (select 1 from all_allele a where a._marker_key = s._marker_key )
and exists (select 1 from MGI_Relationship r where m._marker_key = r._object_key_1 and r._category_key in (1000,1002,1003,1004,1006,1008,1009,1010,1012,1013))
union
select m.symbol, m._marker_key, a.accid as mgiId, l.chromosome, l.startCoordinate, l.endCoordinate, l.strand, s.*,
m.symbol || ' from ENSEMBL 108 has relationship' as note
from seq_marker_cache s, mrk_marker m, acc_accession a, mrk_location_cache l
where s._logicaldb_key = 222
and s._marker_key = m._marker_key
and s._marker_key = a._object_key
and a._mgitype_key = 2
and a._logicaldb_key = 1
and a.preferred = 1
and s._marker_key = l._marker_key
and not exists (select 1 from all_allele a where a._marker_key = s._marker_key )
and exists (select 1 from MGI_Relationship r where m._marker_key = r._object_key_2 and r._category_key in (1000,1002,1003,1004,1006,1008,1009,1010,1012,1013))
''', 'auto')

def processSynonym():

    synFileName = 'MGI_Synonym.bcp'
    synFile = open(synFileName, 'w')

    maxresults = db.sql(''' select nextval('mgi_synonym_seq') as maxKey ''', 'auto')
    synKey = maxresults[0]['maxKey']

    mgiTypeKey = 2
    synTypeKey = 1004
    referenceKey = 551295       # J:321631
    createdByKey = 1093
    cdate = mgi_utils.date('%m/%d/%Y')  # current date

    for r in results:
        print(r)
        markerKey = r['_marker_key']
        esId = r['accid']
     
        synFile.write('%d|%d|%d|%d|%s|%s|%s|%s|%s|%s\n' \
            % (synKey, markerKey, mgiTypeKey, synTypeKey, referenceKey, esId, createdByKey, createdByKey, cdate, cdate))
        synKey = synKey + 1

    synFile.close()
    bcpCommand = os.environ['PG_DBUTILS'] + '/bin/bcpin.csh'
    currentDir = os.getcwd()
    bcp = '%s %s %s %s %s %s "|" "\\n" mgd' % \
        (bcpCommand, db.get_sqlServer(), db.get_sqlDatabase(), 'MGI_Synonym', currentDir, synFileName)
    
    os.system(bcp)
    
    db.sql(''' select setval('mgi_synonym_seq', (select max(_Synonym_key) from MGI_Synonym)) ''', None)
    db.commit()

def processMrkCoord():
    mcFileName = 'MrkCoord.txt'
    mcFile = open(mcFileName, 'w')

    for r in results:
        mcFile.write(r['mgiId'] + '\t')
        mcFile.write(r['chromosome'] + '\t')
        mcFile.write(str(r['startCoordinate']) + '\t')
        mcFile.write(str(r['endCoordinate']) + '\t')
        mcFile.write(r['strand'] + '\t')
        mcFile.write('MGI Curation' + '\t')
        mcFile.write('MGI' + '\t')
        mcFile.write('\t')
        mcFile.write(r['note'] + '\n')

    mcFile.close()

processSynonym()
processMrkCoord()


