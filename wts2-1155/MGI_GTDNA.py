
'''
#Report:
#       Tab-delimited file of MGI coordinates for DNA gene traps (gff format)
#       (TR 7493)
#
#   1. chromosome: e.g. '19' 
#   2. source of feature: 'Gene Trap'
#   3. gene feature: 'Gene'
#   4. start coordinate
#   5. end coordinate
#   6. unused: '.'
#   7. strand
#   8. unused: '.'
#   9. feature attributes: Creator; Sequence_tag_ID; GenBank_ID; DBxref; Type
#	- where: 'Creator' is the cellLine creator
#		 'Sequence_tag_ID' is sequence tag ID 
#		 'GenBank_ID' is the seqID
#	 	 'DBxref' is the allele MGI ID
#		 'Type' is the sequence tag type e.g. DNA
#       - example: 
#  1."5"
#  2. "Gene Trap"
#  3. "Gene"
#  4. 120120076.0
#  5. 120120254.0     
#  6. "."
#  7. "-"
#  8. "."
#  9. "Creator TIGM; Sequence_tag_ID IST11440A7BBF1; GenBank_ID EF833342; \
#	DBxref MGI:3988402; Type DNA"
#
# Usage:
#       MGI_GTDNA.py
#
# History:
#
# 6/2/2009 sc - created
#
'''
 
import sys
import os
import reportlib
import db

db.setTrace()

CRT = reportlib.CRT
TAB = reportlib.TAB

#
# environment variables
#
collection = 'dbGSS Gene Trap'
outputDir = os.environ['REPORTOUTPUTDIR']

# We use RNA sequence tag methods to determine sequence type
# this script uses NOT IN this list
# note some seq types are incorrect in our database and in genbank
rnaMethods = "5'' RACE, 3'' RACE"

# put configured methods in form usable by sql
temp = ''
tokens = str.split(rnaMethods, ',')
for i in range(len(tokens) - 1):
    # concatenate all but the last token
    #temp = temp + '"' + str.strip(tokens[i]) + '", '
    temp = temp + "'" + str.strip(tokens[i]) + "', "   
# add last token, sans ','
temp = temp + "'" + str.strip(tokens[-1]) + "'"
rnaMethods = temp
print(('rnaMethods: %s' %rnaMethods))


#
# data structures
#

# sequence key mapped to gene trap coordinates
# {seqKey:[start, end, strand, chr], ... }
gtCoordDictBySeqKey = {}

# sequence key mapped to seqId
# {seqKey:seqID, ...}
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

#
#  Query and build structures
#

print('Loading lookups ...')
sys.stdout.flush()

# get dbGSSGeneTrap Collection sequence coordinates
db.sql('''SELECT mcf.startCoordinate, mcf.endCoordinate, 
    mcf.strand, mcf._Object_key as _Sequence_key, chr.chromosome 
    INTO TEMPORARY TABLE coords 
    FROM MAP_Coord_Collection mcc, MAP_Coordinate mc, 
    MAP_Coord_Feature mcf, MRK_Chromosome chr 
    WHERE mcc.name = '%s' 
    AND mcc._Collection_key = mc._Collection_key
    AND mc._Map_key = mcf._Map_key
    AND mc._Object_key = chr._Chromosome_key''' % collection, None)

db.sql('CREATE INDEX coords_idx1 on coords(_Sequence_key)', None)

# reduce to just DNA
db.sql('''SELECT c.* 
    INTO TEMPORARY TABLE dnaCoords 
    FROM coords c, SEQ_GeneTrap s, VOC_Term v 
    WHERE c._Sequence_key = s._Sequence_key
    AND s._TagMethod_key = v._Term_key 
    AND v.term not in (%s)''' % rnaMethods, None)
db.sql('CREATE INDEX dnaCoords_idx1 on dnaCoords(_Sequence_key)', None)

# get seqID
db.sql('''SELECT c.*, a.accID as seqId 
    INTO TEMPORARY TABLE dcSeqs 
    FROM dnaCoords c, ACC_Accession a 
    WHERE c._Sequence_key = a._Object_key 
    AND a._MGIType_key = 19 
    AND a._LogicalDB_key = 9
    AND a.preferred = 1''', None)

db.sql('CREATE INDEX dcSeqs_idx1 on dcSeqs(_Sequence_key)', None)

results = db.sql('SELECT * from dcSeqs', 'auto')

# load gtCoordDictBySeqKey and seqIdDictBySeqKey
for r in results:
    seqKey = r['_Sequence_key']
    coordList = [ r['startCoordinate'], r['endCoordinate'], \
        r['strand'], r['chromosome'] ]
    gtCoordDictBySeqKey[seqKey] = coordList
    seqIdDictBySeqKey[seqKey] = r['seqId']

# get dbGSS sequence tag IDs
results = db.sql('''SELECT c._Sequence_key, a.accId as seqTagId 
    FROM dcSeqs c, ACC_Accession a 
    WHERE a._MGIType_key = 19 
    AND a._LogicalDB_key != 9
    AND a.preferred = 1 
    AND a._Object_key = c._Sequence_key 
    ORDER BY c._Sequence_key''' , 'auto')

# load seqTagIdsDictBySeqKey, there is 1 seqTagId per sequence
for r in results:
    seqKey = r['_Sequence_key']
    seqTagId = r['seqTagId']
    seqTagIdsDictBySeqKey[seqKey] = seqTagId

# get MGI ID of the allele associated with the sequence
db.sql('''SELECT c._Sequence_key, sa._Allele_key, a.accID as mgiID 
    INTO TEMPORARY TABLE mgiIDs 
    FROM dnaCoords c, SEQ_Allele_Assoc sa, ALL_Allele aa, 
    ACC_Accession a 
    where c._Sequence_key = sa._Sequence_key 
    and sa._Allele_key = aa._Allele_key 
    and aa.isMixed = 0 
    and sa._Allele_key = a._Object_key 
    and a._MGIType_key = 11 
    and a._LogicalDB_key = 1 
    and a.preferred = 1 
    and a.prefixPart = 'MGI:' ''', None)

db.sql('CREATE INDEX mgiIDs_idx1 on mgiIDs(_Allele_key)', None)

results = db.sql('SELECT * from mgiIDs', 'auto')

# load mapping from sequence key to allele key. A sequence is associated
# with one allele, but an allele can be associated with multiple sequences 
for r in results:
    alleleKey = r['_Allele_key']
    sequenceKey = r['_Sequence_key']
    alleleKeyDictBySeqKey[sequenceKey] = alleleKey

# get allele creator
results = db.sql('''SELECT c.*, t.term as creator 
    FROM mgiIDs c, ALL_Allele_CellLine aca, ALL_CellLine ac, 
    ALL_CellLine_Derivation acd, VOC_Term t 
    WHERE c._Allele_key = aca._Allele_key 
    AND aca._MutantCellLine_key =  ac._CellLine_key 
    AND ac._Derivation_key = acd._Derivation_key 
    AND acd._Creator_key = t._Term_key ''', 'auto')

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
column3 = 'Gene'
column6 = '.'
column8 = '.'

# variable columns
column1 = ''     # chromosome
column4 = ''     # startCoordinate
column5 = ''     # endCoordinate
column7 = ''     # strand

# template for column nine
column9 = 'Creator %s; Sequence_tag_ID %s; GenBank_ID %s; DBxref %s; Type %s'

# components of column 9
creator = ''
seqTagID = ''
seqID = ''
mgiID = ''
seqType = 'DNA'

fp = reportlib.init(sys.argv[0], fileExt = '.gff', outputdir = \
   outputDir, printHeading = None)

print('Writing gff file ...')
sys.stdout.flush()

for seqKey in gtCoordDictBySeqKey:
    if seqKey in alleleKeyDictBySeqKey:
        coordList = gtCoordDictBySeqKey[seqKey]
        column1 = coordList[3]
        column4 = str(coordList[0])
        column5 = str(coordList[1])
        column7 = coordList[2]
        alleleKey = alleleKeyDictBySeqKey[seqKey]
        seqTagID = seqTagIdsDictBySeqKey[seqKey]
        seqID = seqIdDictBySeqKey[seqKey]
        
        alleleList = alleleIdAndCreatorDictByAlleleKey[alleleKey]
        mgiID = alleleList[0]
        creator = alleleList[1]
        fp.write(column1 + TAB)
        fp.write(column2 + TAB)
        fp.write(column3 + TAB)
        fp.write(column4 + TAB)
        fp.write(column5 + TAB)
        fp.write(column6 + TAB)
        fp.write(column7 + TAB)
        fp.write(column8 + TAB)
        fp.write(column9 % (creator, seqTagID, seqID, mgiID, seqType) + CRT)

reportlib.finish_nonps(fp)
