#!/bin/csh -fx

# Migration for TR12540/Disease Ontology
#
# mgidbmigration
# ei : tr12540
# mgipython
# pwi
# pgmgddbschema : mrk_omim_cache is obsolete
# pgdbutilties : tr12540 : sp
# mrkcacheload : tr12540 : mrk_omim_cache is obsolete : working
#
# rollupload (remove 1016) : tr12540 : working
# omim_hpoload (1018, 1024) : tr12540 : working
# entrezgeneload (1006/1022) : tr12540 : working
# vocload : tr12540 : working
# doload : obsolete : remove from loadadmin
#
# qcreports_db :
# reports_db :
# 
# loadadmin : remove
#	mrkcacheload/mrkomim.csh
#	doload
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
${MIRROR_WGET}/download_package ftp.ncbi.nih.gov.entrez_gene | tee -a $LOG || exit 1
${MIRROR_WGET}/download_package ftp.ncbi.nih.gov.homologene | tee -a $LOG || exit 1

#
# update schema-version and public-version
#
date | tee -a ${LOG}
cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG
update MGI_dbinfo set schema_version = '6-0-10', public_version = 'MGI 6.010';
delete from VOC_Annot where _AnnotType_key in (1005, 1012, 1006, 1016, 1018, 1025, 1026);
delete from VOC_AnnotType where _AnnotType_key in (1005, 1012, 1006, 1016, 1018, 1025, 1026);
drop table MRK_OMIM_Cache;
select count(*) from VOC_Annot where _AnnotType_key = 1020;
select count(*) from VOC_Annot where _AnnotType_key = 1021;
select count(*) from VOC_Annot where _AnnotType_key = 1022;
select count(*) from VOC_Annot where _AnnotType_key = 1023;
select count(*) from VOC_Annot where _AnnotType_key = 1024;
select count(*) from MRK_DO_Cache;
EOSQL

date | tee -a ${LOG}
echo 'step 1 : vocload/OMIM.config' | tee -a $LOG || exit 1
echo 'OMIMtermcheck.current.rpt : genotype check removed' | tee -a $LOG || exit 1
echo 'OMIM.animalmodel : turned off, should be empty' | tee -a $LOG || exit 1
${VOCLOAD}/runSimpleIncLoadNoArchive.sh OMIM.config | tee -a $LOG || exit 1
date | tee -a ${LOG}

exit 0

date | tee -a ${LOG}
echo 'step 2 : rollupload' | tee -a $LOG || exit 1
${ROLLUPLOAD}/bin/rollupload.sh | tee -a $LOG || exit 1
date | tee -a ${LOG}

date | tee -a ${LOG}
echo 'step 3 : omim_hpoload (OMIM format changes)' | tee -a $LOG || exit 1
${OMIMHPOLOAD}/bin/omim_hpoload.sh | tee -a $LOG || exit 1
date | tee -a ${LOG}

date | tee -a ${LOG}
echo 'step 4 : entrezgeneload' | tee -a $LOG || exit 1
${ENTREZGENELOAD}/loadFiles.csh | tee -a $LOG || exit 1
${ENTREZGENELOAD}/updateIDs.csh | tee -a $LOG || exit 1
${ENTREZGENELOAD}/human/load.csh | tee -a $LOG || exit 1
date | tee -a ${LOG}

date | tee -a ${LOG}
echo 'step 5 : mrkcacheload/mrkdo.csh' | tee -a $LOG || exit 1
${MRKCACHELOAD}/mrkdo.csh | tee -a $LOG || exit 1
date | tee -a ${LOG}

#date | tee -a ${LOG}
#echo 'step 6 : qc reports' | tee -a $LOG || exit 1
#./qcnightly_reports.csh | tee -a $LOG || exit 1
#date | tee -a ${LOG}

#date | tee -a ${LOG}
#echo 'step 7 : MGI_deletePrivateData.csh' | tee -a $LOG || exit 1
#${PG_DBUTILS}/sp/MGI_deletePrivateData.csh | tee -a $LOG || exit 1
#date | tee -a ${LOG}

${PG_MGD_DBSCHEMADIR}/trigger/ALL_Allele_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/trigger/MRK_Marker_create.object | tee -a $LOG || exit 1

# final database check
${PG_DBUTILS}/bin/grantPublicPerms.csh ${PG_DBSERVER} ${PG_DBNAME} mgd | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/objectCounter.sh | tee -a $LOG || exit 1

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG
select * from VOC_Annot where _AnnotType_key in (1005, 1012, 1006, 1016, 1018, 1025, 1026);
select count(*) from VOC_Annot where _AnnotType_key = 1020;
select count(*) from VOC_Annot where _AnnotType_key = 1021;
select count(*) from VOC_Annot where _AnnotType_key = 1022;
select count(*) from VOC_Annot where _AnnotType_key = 1023;
select count(*) from VOC_Annot where _AnnotType_key = 1024;
select count(*) from MRK_DO_Cache;
EOSQL

echo "--- Finished" | tee -a ${LOG}

