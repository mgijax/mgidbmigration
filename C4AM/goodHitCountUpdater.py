#!/usr/local/bin/python

import sys
import os
import string
import db
import reportlib

CRT = reportlib.CRT
SPACE = reportlib.SPACE
TAB = reportlib.TAB
PAGE = reportlib.PAGE


bestHitsFile = '/data/loads/genbank/gtblatpipeline/output.build38/best_blat_hits.psl'
singleHitsFile = '/data/loads/genbank/gtblatpipeline/output.build38/best_blat_hits_single_Gbrowse.gff'
goodHitCountDict = {}
try:
    fpBestHits = open(bestHitsFile, 'r')
except:
    print('Cannot open report file: ' + bestHitsFile)
    exit(1)

try:
    fpSingleHits = open(singleHitsFile, 'r')
except:
    print('Cannot open report file: ' + singleHitsFile)
    exit(1)

# load best hits into lookup
# column 10 contains seqid and looks like "gi|53838793|gb|CW509288.1|CW509288"

for line in fpBestHits.readlines():
    columnList = string.split(line, TAB)
    column10 = columnList[9]
    column10List = string.split(column10, '|')
    seqID = string.strip(column10List[4])
    if not goodHitCountDict.has_key(seqID):
	goodHitCountDict[seqID] = 1
        #print 'adding %s to lookup' % seqID
    else:
	count = goodHitCountDict[seqID] + 1
	goodHitCountDict[seqID] = count
	#print 'adding count %s to %s' % (count, seqID)

# load single hits into lookup
for line in fpSingleHits.readlines():
    columnList = string.split(line, TAB)
    column9 = columnList[8]
    seqID = string.strip(column9[4:])
    goodHitCountDict[seqID] = 1
    #print 'adding single hit %s to lookup' % seqID

#for s in goodHitCountDict.keys():
#    print '%s : %s' % (s, goodHitCountDict[s])

results = db.sql('''select a.accid, sgt._Sequence_key, sgt.goodHitCount
	from ACC_Accession a, SEQ_GeneTrap sgt
	where a._MGIType_key = 19
	and a._LogicalDB_key = 9
	and a.preferred = 1
	and a._Object_key = sgt._Sequence_key''', 'auto')

toUpdateDict = {}
sameCt = 0
newCt = 0
sgtCt = len(results)
for r in results:
    seqID = r['accid']
    seqKey = r['_Sequence_key']
    oldGhc = int(r['goodHitCount'])
    newGhc = 0 # default
    if goodHitCountDict.has_key(seqID):
	newGhc = goodHitCountDict[seqID]
    if newGhc != oldGhc:
	toUpdateDict[seqKey] = newGhc
	print 'UPDATE: %s %s old: %s new: %s' % (seqID, seqKey, oldGhc, newGhc) 
        newCt += 1
    else:
	print 'SAME: %s goodHitCount: %s' % (seqID, oldGhc)
	sameCt += 1
print 'Total in SEQ_GeneTrap: %s' % sgtCt
print 'goodHitCount updated: %s' % newCt
print 'goodHitCount same: %s' % sameCt

fpBestHits.close()
fpSingleHits.close()

#
#  Set up a connection to the mgd database.
#
dbServer = os.environ['MGD_DBSERVER']
dbName = os.environ['MGD_DBNAME']
user = os.environ['MGD_DBUSER']
passwordFileName = os.environ['MGD_DBPASSWORDFILE']
db.useOneConnection(1)
db.set_sqlUser(user)
db.set_sqlPasswordFromFile(passwordFileName)

for s in toUpdateDict.keys():
    ghc = toUpdateDict[s]
    #print 'updating %s to %s' % (s, ghc)
    db.sql('''update SEQ_GeneTrap
		set goodHitCount = %s
		where _Sequence_key = %s''' % (ghc, s), None)

db.useOneConnection(0)
