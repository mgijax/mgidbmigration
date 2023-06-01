
'''
#
#	HUM_Coord_Compare.py
#
# Report:
#
# Usage:
#       HUM_Coord_Compare.py
#
# Notes:
#	- all reports use mgireport directory for output file
#	- all reports use db default of public login
#	- all reports use server/database default of environment
#	- use lowercase for all SQL commands (i.e. select not SELECT)
#	- use proper case for all table and column names e.g. 
#         use MRK_Marker not mrk_marker
#	- all public SQL reports require the header and footer
#	- all private SQL reports require the header
#
# History:
#
# sc	05/16/2023
#	- created Mapview vs Alliance Human analysis
#
'''
 
import sys 
import os
import string
import reportlib
import db

db.useOneConnection(1)

CRT = reportlib.CRT
SPACE = reportlib.SPACE
TAB = reportlib.TAB
PAGE = reportlib.PAGE

# mapview coordinates
#{markerKey:results, ...}
mapviewDict = {}

fp = reportlib.init(sys.argv[0], 'Mapview and Alliance coordinate comparison')

# mapview coordinates
resultsM = db.sql('''select m.symbol, m._marker_key,
        a1.accid as ncbiID,
        ch._chromosome_key,
        ch.chromosome as genomicChromosome,
        f._feature_key,
        f.startcoordinate,
        f.endcoordinate,
        f.strand
    from map_coord_collection c, map_coordinate mc, map_coord_feature f,
        mrk_chromosome ch, acc_accession a1, mrk_marker m
    where c.name = 'NCBI MapView Human Coordinates'
    and c._collection_key  = mc._collection_key
    and mc._object_key = ch._chromosome_key
    and mc._map_key = f._map_key
    and f._object_key = a1._object_key
    and a1._mgitype_key = 2
    and a1._logicaldb_key = 55
    and a1.preferred = 1
    and f._object_key = m._marker_key
    order by genomicChromosome, startcoordinate''', 'auto')

for r in resultsM:
    mapviewDict[r['_marker_key']] = r

resultsA = db.sql('''select m.symbol, m._marker_key,
        a1.accid as ncbiID,
        ch._chromosome_key,
        ch.chromosome as genomicChromosome,
        f._feature_key,
        f.startcoordinate,
        f.endcoordinate,
        f.strand
    from map_coord_collection c, map_coordinate mc, map_coord_feature f,
        mrk_chromosome ch, acc_accession a1, mrk_marker m
    where c.name = 'Alliance Human Coordinates'
    and c._collection_key  = mc._collection_key
    and mc._object_key = ch._chromosome_key
    and mc._map_key = f._map_key
    and f._object_key = a1._object_key
    and a1._mgitype_key = 2
    and a1._logicaldb_key = 55
    and a1.preferred = 1
    and f._object_key = m._marker_key
    order by symbol''', 'auto')

fp.write('Human Symbol%sNCBI ID%saChr%saStart%saEnd%saStrand%saSize%smvChr%smvStart%smvEnd%smvStrand%smvSize%s' % ( TAB, TAB, TAB, TAB, TAB, TAB, TAB, TAB,  TAB, TAB, TAB, CRT))
totalInMapview = 0
matchCt = 0
notMatchCt = 0
for r in resultsA:
    markerKey = r['_marker_key']
    if markerKey in mapviewDict:
        totalInMapview += 1
        aSymbol = r['symbol']
        aNcbiID = r['ncbiID']
        aChromosome = r['genomicChromosome']
        aStartcoordinate = r['startcoordinate']
        aEndcoordinate  = r['endcoordinate']
        aStrand = r['strand']
        aSize = int(aEndcoordinate) - int(aStartcoordinate) + 1

        mvResults = mapviewDict[markerKey]
        mvChromosome = mvResults['genomicChromosome']
        mvStartcoordinate = mvResults['startcoordinate']
        mvEndcoordinate  = mvResults['endcoordinate']
        mvStrand = mvResults['strand']
        mvSize = int(mvEndcoordinate) - int(mvStartcoordinate) + 1
        if aStartcoordinate != mvStartcoordinate or aEndcoordinate != mvEndcoordinate:
           notMatchCt +=1
           #print('%s' % (r))
           #print('    %s' % (mvResults))
        else:
            matchCt +=1
        fp.write('%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s' % (aSymbol, TAB, aNcbiID, TAB, aChromosome, TAB, aStartcoordinate, TAB, aEndcoordinate, TAB, aStrand, TAB, aSize, TAB, mvChromosome, TAB, mvStartcoordinate, TAB, mvEndcoordinate, TAB, mvStrand, TAB, mvSize, CRT))
fp.write(CRT)
fp.write('Total Alliance Genes with coordinates in MapView: %s' % totalInMapview)
fp.write(CRT + CRT)
fp.write('Total in MapView: %s' % len(resultsM))
fp.write(CRT)
fp.write('Total in Alliance: %s' % len(resultsA))
fp.write(CRT)
fp.write('Total Alliance Genes whose coordinates do not match MapView: %s' % notMatchCt)
fp.write(CRT)
fp.write('Total Alliance Genes whose coordinates match MapView: %s' % matchCt)

db.useOneConnection(0)
reportlib.finish_nonps(fp)	# non-postscript file
