
'''
# Report:
#
# tab-delimited text, with the following information for each sequence tag 
# in MGI (leave blank if no value can be determined):
#
#   1. MCL ID
#   2. Sequence Tag ID
#   3. GenBank ID
#   4. Creator
#   5. Sequence Tag Method
#   6. Vector
#   7. Chromosome (of Sequence Tag alignment)
#   8. start coordinate (of Sequence Tag alignment)
#   9. end coordinate (of Sequence Tag alignment)
#  10. Strand (trapped strand) *a
#  11. Comment *b
#  12. Gene Symbol *c
#  13. MGI Representative Genomic Sequence ID (Gene Model ID) of associated gene
#  14. Gene Model Provider for Representative Genomic sequence of assoc'd gene
#  15. Gene MGI ID
#  16. chromosome (of MGI gene)
#  17. start coordinate (of MGI gene)
#  18. end coordinate (of MGI gene)
#  19. strand (of MGI gene)
#  20. GenBank ID of Representative Sequence for the associated MGI allele
#  21. Point Coordinate of Representative Sequence for the associated MGI allele
#  22. Strand of Representative Sequence for the associated MGI allele
#  23. Mixed/Not_Mixed *d 
#  24. Parent Cell Line
#  25. Strain
# Update frequency: Since allele-to-gene associations change, this file should 
#   be updated with some regularity (weekly is probably adequate).
# 
# *a Strand (trapped strand):
# The strand for the sequence tag alignment as stored in MGI 
#   (since TR9788, we only store the trapped strand).
#
# *b Comment:
# If there are no coordinates in MGI for a featured sequence, list the reason 
#   for no Location. Options: multipleGoodAlignments or noGoodAlignments. 
#   These can be derived from SEQ_GeneTrap.goodHitCount.
#
# *c Associated Gene Information (columns 12-19):
# MGI marker information for the allele associated with the featured 
#   sequence (if any). Note: There may be a few cases where the curated 
#   marker for the associated gene trap allele is different from that 
#   which the load determined. This is OK; report the curated marker 
#   association (i.e. the associated marker in MGI).
#
# *d Mixed/Not_Mixed:
# Enter "Mixed" if the allele associated with the featured sequence tag is 
#   Mixed, otherwise enter "Not_Mixed". 
#
#
# Usage:
#      MGI_GTdbGSS_info.py
#
# History:
#
# 3/27/2012 sc - TR11021 add Parent Cell Line and strain
#
# 4/4/2011 sc - created TR 10661
#
'''
 
import sys
import os
import reportlib
import db

db.setTrace()

#
# constants
#

CRT = reportlib.CRT
TAB = reportlib.TAB

# the coordinate collection
COLLECTION = 'dbGSS Gene Trap'

#
# Lookups
#

# allele rep sequence info, point coord in main query from SEQ_GeneTrap
# {alleleKey:[gbId, strand], ...}
alleleRepSeqDictByAlleleKey = {}

# marker rep sequence info
markerRepSeqDictByAlleleKey = {}

# sequence tag alignments
# {seqKey:[start, end, chr, strand], ...}
seqTagAlignmentsBySeqKey = {}

# report columns
col1 = ''     # Mcl ID
col2 = ''     # Sequence Tag ID
col3 = ''     # GenBankID
col4 = ''     # Creator
col5 = ''     # Sequence Tag Method
col6 = ''     # Vector
col7 = ''     # Chromosome of Seq Tag alignment
col8 = ''     # Start Coordinate of Seq Tag alignment
col9 = ''     # End Coordinate of Seq Tag alignment
col10 = ''    # Strand
col11 = ''    # Comment
col12 = ''    # Gene Symbol
col13 = ''    # MGI Rep Gene Model ID of associated gene
col14 = ''    # Gene Model Provider for above
col15 = ''    # Gene MGI ID
col16 = ''    # Chr of MGI Gene
col17 = ''    # Start Coordinate of MGI Gene
col18 = ''    # End Coordinate of MGI Gene
col19 = ''    # Strand of MGI Gene
col20 = ''    # GenBank ID of Rep Seq for the associated MGI allele
col21 = ''    # Point Coordinate of Rep Seq for the associated MGI allele
col22 = ''    # Strand of Rep Seq for the associated MGI allele
col23 = ''    # Mixed/Not Mixed
col24 = ''    # Parent Cell Line
col25 = ''    # Strain

fp = reportlib.init(sys.argv[0], outputdir = \
   os.environ['REPORTOUTPUTDIR'], printHeading = None)

# main query of 1:1 info about sequence tags
db.sql('''select a._Allele_key, 
                 a._Marker_key, 
                 a.isMixed, 
                 ac._CellLine_key,
                 t1.term as creator, 
                 t2.term as vector, 
                 ac2.cellLine as parentCellLine, 
                 s.strain
            into temporary table cellines
            from ALL_Allele a , 
                 ALL_Allele_CellLine aca, 
                 ALL_CellLine ac, 
                 ALL_CellLine ac2, 
                 PRB_Strain s, 
                 ALL_CellLine_Derivation acd, 
                 VOC_Term t1, 
                 VOC_Term t2
            where a._Allele_key = aca._Allele_key
            and aca._MutantCellLine_key =  ac._CellLine_key
            and ac._Strain_key = s._Strain_key
            and ac._Derivation_key = acd._Derivation_key
            and acd._Creator_key = t1._Term_key
            and acd._Vector_key = t2._Term_key
            and acd._ParentCellLine_key = ac2._CellLine_key''' , None)
db.sql('''create index cellines_idx1 on cellines(_Allele_key)''', None)

db.sql('''select distinct c._Allele_key, c._Marker_key
            into temporary table alleleMarkers
            from cellines c''', None)
db.sql('''create index alleleMarkers_idx1 on alleleMarkers(_Marker_key)''', None)

db.sql('''select m.*, smc._Sequence_key
            into temporary table markerRepSeq
            from alleleMarkers m, SEQ_Marker_Cache smc
            where m._Marker_key = smc._Marker_key
            and smc._Qualifier_key = 615419''', None) 
db.sql('''create index markerRepSeq_idx1 on markerRepSeq(_Sequence_key)''', None)
db.sql('''create index markerRepSeq_idx2 on markerRepSeq(_Marker_key)''', None)

db.sql('''select m.*, scc.chromosome, 
            scc.startCoordinate::int as startCoordinate,
            scc.endCoordinate::int as endCoordinate,
            scc.strand, v.mgiID, v.symbol, 
            a.accid as repSeqID, ldb.name as provider
            into temporary table markerRepCoord
            from markerRepSeq m, 
                 SEQ_Coord_Cache scc, 
                 MRK_Mouse_View v, 
                 ACC_Accession a, 
                 ACC_LogicalDB ldb
            where m._Sequence_key = scc._Sequence_key
            and m._Marker_key = v._Marker_key
            and m._Sequence_key = a._Object_key
            and a._MGIType_key = 19
            and a.preferred = 1
            and a._LogicalDB_key = ldb._LogicalDB_key''', None)
db.sql('''create index markerRepCoord_idx1 on markerRepCoord(_Marker_key)''', None)

db.sql('''select c.*, saa._Sequence_key, a.accid as seqTagID
            into temporary table seqTags
            from cellines c, SEQ_Allele_Assoc saa, ACC_Accession a
            where c._Allele_key = saa._Allele_key
            and saa._Sequence_key = a._Object_key
            and a._MGIType_key = 19
            and a._LogicalDB_key != 9
            and a.preferred = 1''', None)
db.sql('''create index seqTags_idx1 on seqTags(_Allele_key)''', None)

db.sql('''select s.*, a.accid as genbankID
            into temporary table seqGB
            from seqTags s, ACC_Accession a
            where s._Sequence_key = a._Object_key
            and a._MGIType_key = 19
            and a._LogicalDB_key = 9
            and a.preferred = 1''', None)
db.sql('''create index seqGB_idx1 on seqGB(_CellLine_key)''', None)

db.sql('''select s.*, a.accid as mclID
            into temporary table mclIDs
            from seqGB s, ACC_Accession a
            where s._CellLine_key = a._Object_key
            and a._MGIType_key = 28
            and a.preferred = 1''', None)
db.sql('''create index mclIDs_idx1 on mclIDs(_Sequence_key)''', None)

results = db.sql('''select m.*, sgt.goodHitCount, 
            sgt.pointCoordinate::int as pointCoordinate, 
            t1.term as seqTagMethod
            into temporary table seqTagsAll
            from mclIDs m, SEQ_GeneTrap sgt, VOC_Term t1
            where m._Sequence_key = sgt._Sequence_key
            and sgt._TagMethod_key = t1._Term_key''', None)

print('Loading lookups ...')
sys.stdout.flush()

# Lookup of marker rep sequence attributes
results = db.sql(''' select * from markerRepCoord''', 'auto')
for r in results:
    alleleKey = r['_Allele_key']
    chr = r['chromosome']
    start = r['startCoordinate']
    end = r['endCoordinate']
    strand = r['strand']
    mgiID = r['mgiID']
    symbol = r['symbol']
    repSeqID = r['repSeqID']
    provider = r['provider']
    markerRepSeqDictByAlleleKey[alleleKey] = [chr, start, end, strand, mgiID, symbol, repSeqID, provider]

# Lookup of allele rep sequence attributes
db.sql('''select distinct saa._Sequence_key, saa._Allele_key,
            a.accid as allRepSeqId
            into temporary table alleleRepSeq
            from SEQ_Allele_Assoc saa,  ACC_Accession a
            where saa._Qualifier_key = 3983018
            and saa._Sequence_key = a._Object_key
            and a._MGIType_key = 19
            and a._LogicalDB_key = 9
            and a.preferred = 1''', None)
db.sql('''create index alleleRepSeq_idx1 on alleleRepSeq(_Sequence_key)''', None)
results = db.sql('''select s.*, f.strand
        from alleleRepSeq s, MAP_Coord_feature f
        where s._Sequence_key = f._Object_key
        and f._MGIType_key = 19''', 'auto')
for r in results:
    alleleKey = r['_Allele_key']
    allRepSeqID = r['allRepSeqId']
    strand = r['strand']
    alleleRepSeqDictByAlleleKey[alleleKey] = [allRepSeqID, strand]

# Lookup of gene trap sequence tag alignments
results = db.sql('''select c.chromosome, 
            f.startCoordinate::int as startCoordinate,
            f.endCoordinate::int as endCoordinate,
            f.strand, f._Object_key as _Sequence_key
            from MAP_Coord_Collection mcc, MAP_Coordinate mc,
            MRK_Chromosome c, MAP_Coord_Feature f
            where mcc.name = '%s'
            and mcc._Collection_key = mc._Collection_key
            and mc._Object_key = c._Chromosome_key
            and mc._Map_key = f._Map_key''' % COLLECTION, 'auto')
for r in results:
    seqKey = r['_Sequence_key']
    chr = r['chromosome']
    start = r['startCoordinate']
    end = r['endCoordinate']
    strand = r['strand']
    seqTagAlignmentsBySeqKey[seqKey] = [chr, start, end, strand]

# write the report
results = db.sql('''select * from seqTagsAll
                order by mclID''', 'auto')

for r in results:
    col1 = r['mclID']
    col2 = r['seqTagID']
    col3 = r['genbankID']
    col4 = r['creator']
    col5 = r['seqTagMethod']
    col6 = r['vector']
    seqKey = r['_Sequence_key']
    col7 = ''	# chr
    col8 = ''	# start
    col9 = ''	# end
    col10 = ''	# strand
    col11 = ''      # reason for no location
    if seqKey in seqTagAlignmentsBySeqKey:
        (col7, col8, col9, col10) = seqTagAlignmentsBySeqKey[seqKey]
    else:
        goodHitCount = r['goodHitCount']
        if int(goodHitCount) < 1:
            col11 = 'noGoodAlignments'
        elif int(goodHitCount) > 1:
            col11 = 'multipleGoodAlignments'
    col12 = ''	# gene symbol
    col13 = ''	# rep gene model ID
    col14 = ''	# gene model provider
    col15 = ''	# gene mgi ID
    col16 = ''	# chr of mgi gene
    col17 = ''	# start coord of mgi gene
    col18 = '' 	# end coord of mgi gene
    col19 = ''	# strand of mgi gene
    alleleKey = r['_Allele_key']
    if alleleKey in markerRepSeqDictByAlleleKey:
        (col16, col17, col18, col19, col15, col12, col13, col14) = \
            markerRepSeqDictByAlleleKey[alleleKey]
    col20 = ''	# genbank ID of allele rep seq
    col21 = r['pointCoordinate']
    if col21 == None:
        col21 = ''
    col22 = ''	# strand of allele rep seq
    col23 = r['isMixed']
    col24 = r['parentCellLine']
    col25 = r['strain']
    if int(col23) == 1:
        col23 = 'Mixed'
    else: 
        col23 = 'Not_Mixed'
    if alleleKey in alleleRepSeqDictByAlleleKey:
        (col20, col22) = alleleRepSeqDictByAlleleKey[alleleKey]
    pointCoord = r['pointCoordinate']
    if pointCoord == None:
        pointCoord = ''
    fp.write('%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s' % (col1, TAB, col2, TAB, col3, TAB, col4, TAB, col5, TAB, col6, TAB, col7, TAB, col8, TAB, col9, TAB, col10, TAB, col11, TAB, col12, TAB, col13, TAB, col14, TAB, col15, TAB, col16, TAB, col17, TAB, col18, TAB, col19, TAB, col20, TAB, col21, TAB, col22, TAB, col23, TAB, col24, TAB, col25, CRT))

reportlib.finish_nonps(fp)
