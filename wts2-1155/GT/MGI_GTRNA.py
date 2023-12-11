
'''
#Report:
#       Tab-delimited file of MGI coordinates for RNA gene traps (gff format)
#       (TR 7493)
#
#   1. chromosome: e.g. '19'
#   2. source of feature: 'Gene Trap'
#   3. gene feature: 'exon'
#   4. start coordinate 
#   5. end coordinate
#   6. unused: '.'
#   7. strand
#   8. unused: '.'
#   9. feature attributes: Creator; Sequence_tag_ID; GenBank_ID; DBxref; Type; Clone
#	- where: 'Creator' is the cellLine creator
#		 'Sequence_tag_ID' is sequence tag ID 
#		 'GenBank_ID' is the seqID
#	 	 'DBxref' is the allele MGI ID
#		 'Type' is the sequence tag type e.g. RNA
#		 'Clone' is the sequence tag method
#       - example: 
#  1. "9"
#  2. "Gene Trap"
#  3. "Gene"
#  4. 70266600
#  5. 70266632
#  6. "."
#  7. "-"
#  8. "."
#  9. "Creator SIGTR; Sequence_tag_ID CH0294; GenBank_ID DU709485; \
#	DBxref MGI:3863700; Type RNA; Clone 5-Race"
#
# Usage:
#       MGI_GTRNA.py
#
# History:
#
# 05/02/2012	lec
#	- use '5'' RACE', '3'' RACE' to handle single quotes for postgres
#
# 6/2/2009 sc - created
#
'''
 
import sys
import os
import reportlib
import db

db.setTrace()

#
# Constants
#

CRT = reportlib.CRT
TAB = reportlib.TAB

#
# From Configuration
#
collection = "dbGSS Gene Trap"
outputDir = os.environ['REPORTOUTPUTDIR']
# rna sequence tag methods in order to determine sequence type
# note some seq types are incorrect in our database and in genbank
rnaMethods = "5'' RACE, 3'' RACE"

# put configured methods in form usable by sql
temp = ''
tokens = str.split(rnaMethods, ',') 
for i in range(len(tokens) - 1):
    # concatenate all but the last token 
    temp = temp + "'" + str.strip(tokens[i]) + "', "
# add last token, sans ','
temp = temp + "'" + str.strip(tokens[-1]) + "'"
rnaMethods = temp

masterGffFileName = os.environ['MASTER_GFF_FILE']
masterFile = open(masterGffFileName, 'r')

#
# data structures
#

# sequence key mapped to gene trap coordinates
# {seqKey:[strand, chr], ... }
gtCoordDictBySeqKey = {}

# sequence key mapped to seqId
# {seqKey:[seqID,seqTagMethod], ...}
seqIdDictBySeqKey = {}

# sequence key mapped to sequence tag Id
# {seqKey:seqTagId1, ...}
seqTagIdsDictBySeqKey = {}

# sequence key mapped to allele key
# {seqKey:alleleKey1, ...}
alleleKeyDictBySeqKey = {}

# allele key mapped to allele MGI ID and
#  cell line derivation creator
# {alleleKey:[mgiID, creator], ...}
alleleIdAndCreatorDictByAlleleKey = {}	

# sequence Id mapped to a set of exons
# {seqID:[ [start1, end1], ..., [startN, endN] ]
exonsBySeqIdDict = {}

# build the exon data structure from the master gff file
# master gff file example for seq Id CW509341:
# chr1    gtblatpipeline  gene    58557084        58558271        .       -       .       Gene CW509341
# chr1    gtblatpipeline  mRNA    58557084        58558271        .       -       .       mRNA  CW509341
# chr1    gtblatpipeline  exon    58557084        58557100        .       -       .       mRNA CW509341
# chr1    gtblatpipeline  exon    58557102        58557227        .       -       .       mRNA CW509341
# chr1    gtblatpipeline  exon    58558166        58558271        .       -       .       mRNA CW509341
# the following entry in exonsBySeqIdDict will result from above lines:
# CW509341:[ [58557084, 58557100], [58557102, 58557227], [58558166, 58558271] ]

print('Loading exon lookup ...')
sys.stdout.flush()

for line in masterFile.readlines():
    tokens = str.split(line, TAB)
    if tokens[2] != 'exon':
        continue
    start = tokens[3]
    end = tokens[4]
    seqId = tokens[8]
    seqId = str.split(seqId)[1]

    if seqId in exonsBySeqIdDict:
        coordList = exonsBySeqIdDict[seqId]
        coordList.append([start, end])
    else:
        coordList = [ [start, end] ]
    exonsBySeqIdDict[seqId] = coordList
#
#  Query and build structures
#

print('Loading database lookups ...')
sys.stdout.flush()

# get dbGSSGeneTrap Collection coordinates
db.sql('''
        SELECT mcf.strand, mcf._Object_key as _Sequence_key, 
        chr.chromosome 
        INTO TEMPORARY TABLE coords 
        FROM MAP_Coord_Collection mcc, MAP_Coordinate mc, 
        MAP_Coord_Feature mcf, MRK_Chromosome chr 
        WHERE mcc.name = '%s'
        AND mcc._Collection_key = mc._Collection_key 
        AND mc._Map_key = mcf._Map_key 
        AND mc._Object_key = chr._Chromosome_key
        ''' % (collection), None)

db.sql('CREATE INDEX coords_idx1 on coords(_Sequence_key)', None)

# reduce to just RNA and grab sequence tag method
db.sql('''
        SELECT c.*, v.term as seqTagMethod 
        INTO TEMPORARY TABLE rnaCoords 
        FROM coords c, SEQ_GeneTrap s, VOC_Term v 
        WHERE c._Sequence_key = s._Sequence_key 
        AND s._TagMethod_key = v._Term_key 
        AND v.term in (%s)
        ''' % (rnaMethods), None)
db.sql('CREATE INDEX rnaCoords_idx1 on rnaCoords(_Sequence_key)', None)

# get seqID
db.sql('''
        SELECT c.*, a.accID as seqId 
        INTO TEMPORARY TABLE rcSeqs 
        FROM rnaCoords c, ACC_Accession a 
        WHERE c._Sequence_key = a._Object_key 
        AND a._MGIType_key = 19 
        AND a._LogicalDB_key = 9 
        AND a.preferred = 1 
        ''', None)

db.sql('CREATE INDEX rcSeqs_idx1 on rcSeqs(_Sequence_key)', None)

results = db.sql('SELECT * from rcSeqs', 'auto')

# load gtCoordDictBySeqKey and seqIdDictBySeqKey
findText = "' "
replaceText = "-"
for r in results:
    seqKey = r['_Sequence_key']
    cList = [ r['strand'], r['chromosome']]
    tagMethod = r['seqTagMethod']
    charNum = str.find(tagMethod, findText)
    if charNum >= 0:
        tagMethod =tagMethod.replace(findText, replaceText)
    sList = [r['seqId'], tagMethod] 
    gtCoordDictBySeqKey[seqKey] = cList
    seqIdDictBySeqKey[seqKey] = sList

# get dbGSS sequence tag IDs
results = db.sql('''
        SELECT c._Sequence_key, a.accId as seqTagId 
        FROM rcSeqs c, ACC_Accession a 
        WHERE a._MGIType_key = 19 
        AND a._LogicalDB_key != 9 
        AND a.preferred = 1 
        AND a._Object_key = c._Sequence_key 
        ORDER BY c._Sequence_key
        ''' , 'auto')

# load seqTagIdsDictBySeqKey, there is 1 seqTagId per sequence
for r in results:
    seqKey = r['_Sequence_key']
    seqTagId = r['seqTagId']
    seqTagIdsDictBySeqKey[seqKey] = seqTagId

# get MGI ID of the allele associated with the sequence
db.sql('''
        SELECT c._Sequence_key, sa._Allele_key, a.accID as mgiID 
        INTO TEMPORARY TABLE mgiIDs 
        FROM rnaCoords c, SEQ_Allele_Assoc sa, ALL_Allele aa, 
        ACC_Accession a 
        where c._Sequence_key = sa._Sequence_key 
        and sa._Allele_key = aa._Allele_key 
        and aa.isMixed = 0 
        and sa._Allele_key = a._Object_key 
        and a._MGIType_key = 11 
        and a._LogicalDB_key = 1 
        and a.preferred = 1 
        and a.prefixPart = 'MGI:'
        ''', None)

db.sql('CREATE INDEX mgiIDS_idx1 on mgiIDs(_Allele_key)', None)

results = db.sql('SELECT * from mgiIDs', 'auto')

# load mapping from sequence key to allele key. A sequence is associated
# with one allele, but an allele can be associated with multiple sequences
for r in results:
    alleleKey = r['_Allele_key']
    sequenceKey = r['_Sequence_key']
    alleleKeyDictBySeqKey[sequenceKey] = alleleKey

# get allele creator
results = db.sql('''
        SELECT c.*, t.term as creator 
        FROM mgiIDs c, ALL_Allele_CellLine aca, ALL_CellLine ac, 
        ALL_CellLine_Derivation acd, VOC_Term t 
        WHERE c._Allele_key = aca._Allele_key 
        AND aca._MutantCellLine_key =  ac._CellLine_key 
        AND ac._Derivation_key = acd._Derivation_key 
        AND acd._Creator_key = t._Term_key 
        ''', 'auto')

# load alleleIdAndCreatorDictByAlleleKey
for r in results:
    alleleKey = r['_Allele_key']
    valueList = [ r['mgiID'], r['creator'] ]
    alleleIdAndCreatorDictByAlleleKey[alleleKey] = valueList
#
# Write gff file
#

# static columns
column2 = 'Gene Trap'
column3 = 'exon'
column6 = '.'
column8 = '.'

# variable columns
column1 = ''     # chromosome
column4 = ''     # startCoordinate
column5 = ''     # endCoordinate
column7 = ''     # strand

# template for column nine
column9 = 'Creator %s; Sequence_tag_ID %s; GenBank_ID %s; DBxref %s; Type %s; Clone %s'

# components of column 9
creator = ''
seqTagID = ''
seqID = ''
mgiID = ''
seqType = 'RNA'

fp = reportlib.init(sys.argv[0], fileExt = '.gff', outputdir = \
    outputDir, printHeading = None)

print('Writing gff file ...')
sys.stdout.flush()

# for each dbGSS GT sequence with coordinates
for seqKey in gtCoordDictBySeqKey:
    # if there was an allele created for this gene trap 
    if seqKey in alleleKeyDictBySeqKey:
        # get the chromosome and strand value
        cValues = gtCoordDictBySeqKey[seqKey]
        column1 = cValues[1]
        column7 = cValues[0]

        # get the sequence tag ID and the sequence ID 
        if seqKey not in seqTagIdsDictBySeqKey:
            continue
        seqTagID = seqTagIdsDictBySeqKey[seqKey]
        sValues = seqIdDictBySeqKey[seqKey]
        seqID = sValues[0]
        tagMethod = sValues[1]

        # get the allele MGI ID and allele creator for allele
        # associated with this sequence
        alleleKey = alleleKeyDictBySeqKey[seqKey]
        alleleList = alleleIdAndCreatorDictByAlleleKey[alleleKey]
        mgiID = alleleList[0]
        creator = alleleList[1] 

        # now get the set of exons for the sequence
        if seqID not in exonsBySeqIdDict: # it has to, but check just in case
            print(('seqId %s has coordinates in the database, but not present \
                in master gff file' % seqID))
            sys.stdout.flush()
            continue
        coordList = exonsBySeqIdDict[seqID]
        # write a line for each exon
        for coordSet in coordList:
            # start coordinate
            column4 = coordSet[0]
            # end coordinate
            column5 = coordSet[1]
            fp.write(column1 + TAB)
            fp.write(column2 + TAB)
            fp.write(column3 + TAB)
            fp.write(column4 + TAB)
            fp.write(column5 + TAB)
            fp.write(column6 + TAB)
            fp.write(column7 + TAB)
            fp.write(column8 + TAB)
            fp.write(column9 % (creator, seqTagID, seqID, mgiID, seqType, tagMethod) + CRT)

reportlib.finish_nonps(fp)
