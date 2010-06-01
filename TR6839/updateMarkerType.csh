#!/bin/csh -fx

#
# how marker type is used in code is below
# note that non-mouse markers are only of type 'Gene'
#
# update 'DNA Segment' (key = 2) markers to 'Other Genome Feature' (key = 9)
# and 'MicroRNA' (key = 11) to 'Gene' (key = 1)
# Code that selects _MarkerType_key:
# /alomrkload/bin/aloMarkerAssoc.py
#	m._Marker_Type_key IN (1, 7, 11)
# ei/pcds/mgiOption.pcd
#	where _Marker_Type_key not in (4,5)
# /lib_java_dbsmgd_ro/java/org/jax/mgi/shr/datafactory/BatchFactory.java
#	and mlc._Marker_Type_key <> 6
# lib_java_dbsmgd_ro/java/org/jax/mgi/shr/datafactory/DiseaseFactory.java
#	and o._Marker_Type_key = 1"; // only genes
# /seqdb_engine/src/MGIDecider.java
# /seqdb_engine/src/MGISeqToMultiGeneDecider.java
# /seqdb_engine/src/MGISeqToOneGeneDecider.java 
# 	and mv._Marker_Type_key = 1
# /snpcacheload/snpmrkwithin.py
#	where mc._Marker_Type_key != %s and ' % MRKR_QTLTYPE_KEY
# /unigeneload/UniGeneLoad.py
# 	where m._Marker_Type_key = 1 /* genes only */
# /uniprotload/bin/makeGOAnnot.py
# 	and m._Marker_Type_key = 1
# 
# wi/lib/python/map.py:           query = query + ' and mm._Marker_Type_key != ' + `DNASEGMENTTYPE`
# wi/www/searches/marker_report.cgi:    QTL_key = 6 # _Marker_Type_key of a QTL
# wi/www/searches/marker_report.cgi:           _tuple['_Marker_Type_key'] == 3:
# wi/www/searches/marker_report.cgi:        if _tuple['_Marker_Type_key'] == QTL_key:
# reports_db/daily/GO_gene_association.py:    'and m._Marker_Type_key = 1 '
# reports_db/daily/GO_gene_association.py:    'and mm._Marker_Type_key = 1 ' + \
# reports_db/daily/GO_gene_association.py:    'and mm._Marker_Type_key = 11 ' + \
# reports_db/daily/GO_gp2protein.py:    and mm._Marker_Type_key = 1
# reports_db/daily/GO_gp2protein.py:    and mm._Marker_Type_key = 11
# reports_db/daily/GO_gp2protein.py:    and mm._Marker_Type_key = 1
# reports_db/daily/MGI_AllGenes.py:           'and m._Marker_Type_key = 1 ' + \
# reports_db/daily/MGI_GTGUP.py:  'and l._Marker_Type_key not in (2,6) ' + \
# reports_db/daily/MGI_Mutations.py:          'and m._Marker_Type_key = 1 ' + \
# reports_db/daily/MGI_PhenotypicAllele.py:       'and m._Marker_Type_key != 6', None)
# reports_db/daily/MGI_QTLAllele.py:      'and m._Marker_Type_key = 6', None)
# reports_db/daily/MRK_Ensembl_Pheno.py:       'and m._Marker_Type_key = 1 ' + \
# reports_db/daily/MRK_GOHuman.py:        'and m._Marker_Type_key = 1 ' + \
# qcreports_db/mgd/GO_Combined_Report.py: where  m._Marker_Type_key = 1
# qcreports_db/mgd/GO_NotGene.sql:and m._Marker_Type_key != 1
# qcreports_db/mgd/GXD_NonGeneMarkers.py:                  'mt._Marker_Type_key not in (1,2,11)
# qcreports_db/mgd/HMD_MouseSeq1.py:      'and m._Marker_Type_key = 1 ' + \
# qcreports_db/mgd/HMD_MouseSeq2.sql:and m._Marker_Type_key = 1
# qcreports_db/mgd/HMD_RatNoSeq.sql:and m._Marker_Type_key = 1
# qcreports_db/mgd/MGI_ENSEMBL_Associations.py:            'm._Marker_Type_key = 1 and 
# qcreports_db/mgd/MGI_GenesAndPseudogenesWithSequence.py:            and m._Marker_Type_key in (1,7)
# qcreports_db/mgd/MRK_AllNoGO.py:        'where m._Marker_Type_key = 1 ' + \
# qcreports_db/mgd/MRK_GOGold.py: 'and m._Marker_Type_key = 1 ' + \
# qcreports_db/mgd/MRK_GOGold.py: 'and m._Marker_Type_key = 1 ' + \
# qcreports_db/mgd/MRK_GOIEA.py:  'where m._Marker_Type_key = 1 ' + \
# qcreports_db/mgd/MRK_GOIEA.py:  'where m._Marker_Type_key = 1 ' + \
# qcreports_db/mgd/MRK_GORCA.py:  'where m._Marker_Type_key = 1 ' + \
# qcreports_db/mgd/MRK_InterimByDate.sql:where m._Marker_Type_key = 1
# qcreports_db/mgd/MRK_MappedNoRef.sql:and m._Marker_Type_key != 3
# qcreports_db/mgd/MRK_NoGO.py:       'where m._Marker_Type_key = 1 ' + \
# qcreports_db/mgd/MRK_NoSequence.py:     'and m._Marker_Type_key = 1 ' + \
# qcreports_db/mgd/MRK_NoSequence.py:     'and m._Marker_Type_key = 1 ' + \
# qcreports_db/mgd/MRK_Offsets.sql:and m._Marker_Type_key != 3
# qcreports_db/mgd/MRK_PirsfPseudogene.sql:and m._Marker_Type_key = 7
# qcreports_db/mgd/MRK_QTL.py:      'and m._Marker_Type_key = 6 ' + \
# qcreports_db/mgd/MRK_RatNoGO.sql:and m._Marker_Type_key = 1
# qcreports_db/mgd/MRK_TranscriptNoSP.sql:and m._Marker_Type_key = 1
# qcreports_db/pirsfload/OtherMarkerTypes.py:       'and m._Marker_Type_key != 1 ' + \
# qcreports_db/weekly/ALL_NoMutantSentence.py:            'm._Marker_Type_key = 1 and ' + \
# qcreports_db/weekly/ALL_Progress.py:    'and m._Marker_Type_key != 6', None)
# qcreports_db/weekly/ALL_Progress.py:    'and m._Marker_Type_key = 6', None)
# qcreports_db/weekly/ALL_Progress.py:    'where a._Marker_key = m._Marker_key and m._Marker_Type_key = 1', None)
# qcreports_db/weekly/ALL_Progress.py:    'where a._Marker_key = m._Marker_key and m._Marker_Type_key = 1', None)
# qcreports_db/weekly/MRK_New_QTLS.py:    'where m._Marker_Type_key = 6


cd `dirname $0` && source ../Configuration

echo "Server: ${MGD_DBSERVER}"
echo "Database: ${MGD_DBNAME}"

setenv LOG $0.log.$$
rm -rf ${LOG}
touch ${LOG}
date | tee -a ${LOG}


setenv SCHEMA ${MGD_DBSCHEMADIR}
setenv PERMS ${MGD_DBPERMSDIR}
setenv UTILS ${MGI_DBUTILS}


date | tee -a ${LOG}

# bcp out the the tables we are updating
${MGI_DBUTILS}/bin/bcpout.csh ${MGD_DBSERVER} ${MGD_DBNAME} MRK_Marker
${MGI_DBUTILS}/bin/bcpout.csh ${MGD_DBSERVER} ${MGD_DBNAME} MRK_Location_Cache
${MGI_DBUTILS}/bin/bcpout.csh ${MGD_DBSERVER} ${MGD_DBNAME} MRK_OMIM_Cache
${MGI_DBUTILS}/bin/bcpout.csh ${MGD_DBSERVER} ${MGD_DBNAME} NOM_Marker
${MGI_DBUTILS}/bin/bcpout.csh ${MGD_DBSERVER} ${MGD_DBNAME} SEQ_Marker_Cache

cat - <<EOSQL | doisql.csh ${MGD_DBSERVER} ${MGD_DBNAME} $0 | tee -a ${LOG}

use ${MGD_DBNAME}
go

print 'update microRNA to Gene'
print 'MRK_Marker'

update MRK_Marker
set _Marker_Type_key = 1
where _Marker_Type_key = 11
go

print 'MRK_Location_Cache'
update MRK_Location_Cache
set _Marker_Type_key = 1
where _Marker_Type_key = 11
go

print 'MRK_OMIM_Cache'
update MRK_OMIM_Cache
set _Marker_Type_key = 1
where _Marker_Type_key = 11
go

print 'NOM_Marker'
update  NOM_Marker
set _Marker_Type_key = 1
where _Marker_Type_key = 11
go

print 'SEQ_Marker_Cache'
update SEQ_Marker_Cache
set _Marker_Type_key = 1
where _Marker_Type_key = 11
go

print 'delete the microRNA marker type'
delete from MRK_Types
where _Marker_Type_key = 11
go

EOSQL
date >> ${LOG}
