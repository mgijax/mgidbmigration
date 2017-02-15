#!/bin/csh -fx

# Migration for TR12427/Disease Ontology
#
# mgidbmigration : git/trunk : 
# mirror_wget : git trunk
# annotload-6-0-8-1
# doload-6-0-8-1
# ei-6-0-8-1
# mgicacheload-6-0-8-1
# mrkcacheload-6-0-8-1
# omim_hpoload-6-0-8-1
# pgdbutilities-6-0-8-1
# pgmgddbschema-6-0-8-1
# qcreports_db-6-0-8-2
# reports_db-6-0-8-1
# rollupload-6-0-8-1
# vocload-6-0-8-1
# lib_py_postgres-6-0-8-1
# nomenload-6-0-8-1
# seqcacheload-6-0-8-1
# 

###----------------------###
###--- initialization ---###
###----------------------###

if ( ${?MGICONFIG} == 0 ) then
	setenv MGICONFIG /usr/local/mgi/live/mgiconfig
endif

source ${MGICONFIG}/master.config.csh

# start a new log file for this migration, and add a datestamp

setenv LOG $0.log
rm -rf ${LOG}
touch ${LOG}

#${PG_DBUTILS}/bin/loadDB.csh mgi-testdb4 lec radar /bhmgidevdb01/dump/radar.dump
#${PG_DBUTILS}/bin/loadDB.csh mgi-testdb4 lec mgd /bhmgidevdb01/dump/mgd.dump

date | tee -a ${LOG}
echo 'step 1 : run mirror_wget downloads' | tee -a $LOG || exit 1
${MIRROR_WGET}/download_package raw.githubusercontent.com.diseaseontology | tee -a $LOG || exit 1
${MIRROR_WGET}/download_package data.omim.org.omim | tee -a $LOG || exit 1
${MIRROR_WGET}/download_package compbio.charite.de.phenotype_annotation | tee -a $LOG || exit 1

#
# update schema-version and public-version
#
date | tee -a ${LOG}
cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG

update MGI_dbinfo set schema_version = '6-0-8', public_version = 'MGI 6.08';

delete from MGI_Synonym where _synonymtype_key = 1031;
delete from MGI_SynonymType where _synonymtype_key = 1031;

update ACC_LogicalDB set name = 'HP' where _logicaldb_key = 180;

--
-- non-preferred OMIM ids (44) can be deleted
--

select * from ACC_Accession 
where _MGIType_key = 13
and _LogicalDB_key = 15
and preferred = 0
;

delete from ACC_Accession 
where _MGIType_key = 13
and _LogicalDB_key = 15
and preferred = 0
;

select accID
from ACC_Accession
where _MGIType_key = 13
and _LogicalDB_key = 15
and accID not like 'OMIM:%'
;

update ACC_Accession
set accID = 'OMIM:' || accID, prefixPart = 'OMIM:'
where _MGIType_key = 13
and _LogicalDB_key = 15
and accID not like 'OMIM:%'
;

select accID
from ACC_Accession
where _MGIType_key = 13
and _LogicalDB_key = 15
and accID not like 'OMIM:%'
;

delete from DAG_DAG where _DAG_key = 50;
insert into DAG_DAG values(50,99561,13,'Disease Ontology','DOID',now(),now());
insert into VOC_VocabDAG values(125, 50, now(), now());
delete from VOC_Annot where _AnnotType_key in (1020, 1021, 1022, 1023, 1024, 1025, 1026);
delete from VOC_Term where _Vocab_key = 125;

EOSQL

${PG_MGD_DBSCHEMADIR}/table/MRK_DO_Cache_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/MRK_DO_Cache_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/index/MRK_DO_Cache_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/index/GO_Tracking_drop.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/index/GO_Tracking_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/BIB_Refs_drop.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/BIB_Refs_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/GXD_Genotype_drop.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/GXD_Genotype_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/MRK_Marker_drop.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/MRK_Marker_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/VOC_Term_drop.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/VOC_Term_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/trigger/MRK_Marker_create.object | tee -a $LOG || exit 1

#
# obsolete
#
rm -rf ${DATALOADSOUTPUT}/mgi/vocload/OMIM/OMIM.clusters.*

date | tee -a ${LOG}
echo 'step 1 : vocload/OMIM.config' | tee -a $LOG || exit 1
${VOCLOAD}/runSimpleIncLoadNoArchive.sh OMIM.config | tee -a $LOG || exit 1
date | tee -a ${LOG}

date | tee -a ${LOG}
echo 'step 2 : omim_hpoload (OMIM format changes)' | tee -a $LOG || exit 1
${OMIMHPOLOAD}/bin/omim_hpoload.sh | tee -a $LOG || exit 1
date | tee -a ${LOG}

date | tee -a ${LOG}
echo 'step 3 : vocload/DO & omim-to-DO annotation translation' | tee -a $LOG || exit 1
${DOLOAD}/bin/do.sh | tee -a $LOG || exit 1
date | tee -a ${LOG}

date | tee -a ${LOG}
echo 'step 4 : run omim cache' | tee -a $LOG || exit 1
${MRKCACHELOAD}/mrkomim.csh | tee -a $LOG || exit 1
date | tee -a ${LOG}

#date | tee -a ${LOG}
#echo 'step 5 : qc reports' | tee -a $LOG || exit 1
#./qcnightly_reports.csh | tee -a $LOG || exit 1
#date | tee -a ${LOG}

date | tee -a ${LOG}
echo 'step 6 : adding cache key to cache tables (TR12083)' | tee -a $LOG || exit 1
/mgi/all/wts_projects/12000/12083/caches/caches.csh | tee -a $LOG || exit 1
date | tee -a ${LOG}

date | tee -a ${LOG}
echo 'step 7 : TR11083/nomenclature merge' | tee -a $LOG || exit 1
/mgi/all/wts_projects/11000/11083/tr11083.csh | tee -a $LOG || exit 1
date | tee -a ${LOG}

date | tee -a ${LOG}
echo 'step 8 : bib_refs' | tee -a $LOG || exit 1
./bibrefs.csh | tee -a $LOG || exit 1
date | tee -a ${LOG}

date | tee -a ${LOG}
echo 'step 9 : seqcacheload/seqmarker.csh' | tee -a $LOG || exit 1
${SEQCACHELOAD}/seqmarker.csh | tee -a $LOG || exit 1
${SEQCACHELOAD}/seqprobe.csh | tee -a $LOG || exit 1
date | tee -a ${LOG}

date | tee -a ${LOG}
echo 'step 10 : seqcacheload/seqmarker.csh' | tee -a $LOG || exit 1
${MRKCACHELOAD}/mrklabel.csh | tee -a $LOG || exit 1
${MRKCACHELOAD}/mrkref.csh | tee -a $LOG || exit 1
${MRKCACHELOAD}/mrklocation.csh | tee -a $LOG || exit 1
${MRKCACHELOAD}/mrkprobe.csh | tee -a $LOG || exit 1
${MRKCACHELOAD}/mrkmcv.csh | tee -a $LOG || exit 1
${MRKCACHELOAD}/mrkomim.csh | tee -a $LOG || exit 1
date | tee -a ${LOG}

# final database check
${PG_MGD_DBSCHEMADIR}/procedure/MRK_deleteWithdrawal_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/procedure/GXD_getGenotypesDataSets_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/procedure/VOC_deleteGOGAFRed_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/procedure/VOC_deleteGOWithdrawn_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/procedure/BIB_getCopyright_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/index/MGI_Reference_Assoc_drop.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/index/MGI_Reference_Assoc_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/view/MGI_NoteType_Marker_View_create.object | tee -a $LOG || exit 1
${PG_DBUTILS}/bin/grantPublicPerms.csh ${PG_DBSERVER} ${PG_DBNAME} mgd | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/objectCounter.sh | tee -a $LOG || exit 1

#cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG
#
#EOSQL

echo "--- Finished" | tee -a ${LOG}

