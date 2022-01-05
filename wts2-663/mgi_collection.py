#
#  Purpose:
#
#

import sys
import os
import db
import mgi_utils


TAB =  '\t'
CRT = '\n'

# report counts and discrepancies between input files and db after loading
reportFile = open('Test.rpt', 'w')

MGIFile = open('MGI_C4AM_master.new.txt', 'r')
QTLFile = open('QTL_master.txt', 'r')

results = db.sql('''select distinct a.accid
        from ACC_Accession a, MAP_Coord_Collection c, MAP_Coordinate mc, MAP_Coord_Feature f
        where c.name = 'MGI'
        and c._Collection_key = mc._Collection_key
        and mc._Map_key = f._Map_key
        and f._Object_key = a._object_key
        and a._MGIType_key = 2
        and a._LogicalDB_key = 1
        and a.preferred = 1
        and a.prefixPart = 'MGI:' ''', 'auto')

MGIList = []
for r in results:
    MGIList.append(r['accid'])

results = db.sql('''select a.accid, f.startcoordinate, f.endcoordinate
        from ACC_Accession a, MAP_Coord_Collection c, MAP_Coordinate mc, MAP_Coord_Feature f
        where c.name = 'QTL'
        and c._Collection_key = mc._Collection_key
        and mc._Map_key = f._Map_key
        and f._Object_key = a._object_key
        and a._MGIType_key = 2
        and a._LogicalDB_key = 1
        and a.preferred = 1
        and a.prefixPart = 'MGI:' ''', 'auto')

QTLList = []
for r in results:
    QTLList.append(r['accid'])

inputList = []
header = MGIFile.readline()
counter = 0
for line in MGIFile.readlines():
    counter += 1
    tokens = line[:-1].split(TAB)
    mgiID = tokens[0]
    inputList.append(mgiID)
    if mgiID not in MGIList:
        reportFile.write('MGI in input File not in DB: %s%s' % (mgiID, CRT))

for id in MGIList:
    if id not in inputList:
        reportFile.write('MGI in DB not in input File: %s%s' % (id, CRT))

reportFile.write('Total MGI in database: %s%s' % (len(MGIList), CRT))
reportFile.write('Total MGI in input file: %s%s' % (counter, CRT))
reportFile.write(CRT)

header = QTLFile.readline()
counter = 0
for line in QTLFile.readlines():
    counter += 1
    tokens = line[:-1].split(TAB)
    mgiID = tokens[0]
    if mgiID not in QTLList:
        reportFile.write('QTL in input File not in DB: %s%s' % (mgiID, CRT))
reportFile.write('Total QTL in database: %s%s' % (len(QTLList), CRT))
reportFile.write('Total QTL in input file: %s%s' % (counter, CRT))

reportFile.close()
sys.exit(0)

