#!/bin/csh -fx

#
# Migration for TR12349
#
# mgidbmigration : cvs/trunk
# pgmgddbschema : branch
# goload : branch
# proisoformload : trunk
# reports_db : branch
# qcreports_db : trunk : GO_GPI_verify.py
# ei : trunk
# lib_py_report : cvs/trunk
#
# obsolete:
# gaf_fprocessor
# vocload : remove ECO config/etc.
#
# loadadmin
# keep: prod/dailytasks.csh:${MGICACHELOAD}/go_annot_extensions_display_load.csh
# keep: prod/dailytasks.csh:${MGICACHELOAD}/go_isoforms_display_load.csh
# remove as these are now called from goload/go.sh
# remove :prod/sundaytasks.csh:${MGICACHELOAD}/go_annot_extensions_display_load.csh
# remove :prod/sundaytasks.csh:${MGICACHELOAD}/go_isoforms_display_load.csh
#
# mirror_wget : ftp.geneontology.org.goload : remove goa_human
# change
# /data/downloads/goa -> ./ftp.ebi.ac.uk/pub/databases/GO/goa/MOUSE
# to
# /data/downloads/goa -> ./ftp.ebi.ac.uk/pub/databases/GO/goa
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

#
# update schema-version and public-version
#
date | tee -a ${LOG}
cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG
update MGI_dbinfo set schema_version = '6-0-6', public_version = 'MGI 6.06';
delete from VOC_Vocab where _Vocab_key = 111;
delete from ACC_LogicalDB where _LogicalDB_key = 182;
EOSQL
date | tee -a ${LOG}

#date | tee -a ${LOG}
#echo 'step 1 : run mirror_wget downloads' | tee -a $LOG || exit 1
${MIRROR_WGET}/download_package ftp.pir.georgetown.edu.proisoform | tee -a $LOG || exit 1
${MIRROR_WGET}/download_package pir.georgetown.edu.proisoform | tee -a $LOG || exit 1
${MIRROR_WGET}/download_package build.berkeleybop.org.goload | tee -a $LOG || exit 1
${MIRROR_WGET}/download_package ftp.ebi.ac.uk.goload | tee -a $LOG || exit 1
${MIRROR_WGET}/download_package ftp.geneontology.org.goload | tee -a $LOG || exit 1

date | tee -a ${LOG}
echo 'step 2 : orc ids' | tee -a $LOG || exit 1
./orcids.csh | tee -a $LOG || exit 1
date | tee -a ${LOG}

# do all schema/stored procedure changes before the loads are run
${PG_MGD_DBSCHEMADIR}/procedure/VOC_deleteGOGAFRed_create.object | tee -a $LOG || exit 1
${PG_DBUTILS}/bin/grantPublicPerms.csh ${PG_DBSERVER} ${PG_DBNAME} mgd | tee -a $LOG || exit 1

date | tee -a ${LOG}
echo 'step 3 : proisoformload' | tee -a $LOG || exit 1
${PROISOFORMLOAD}/bin/proisoform.sh | tee -a $LOG || exit 1
date | tee -a ${LOG}

date | tee -a ${LOG}
echo 'step 4 : goload (goamousenoctua)' | tee -a $LOG || exit 1
${GOLOAD}/go.sh | tee -a $LOG || exit 1
date | tee -a ${LOG}

date | tee -a ${LOG}
echo 'step 5 : voc_cache_markers' | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/table/VOC_Marker_Cache_drop.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/table/VOC_Marker_Cache_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/MRK_Marker_drop.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/VOC_Marker_Cache_drop.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/VOC_Term_drop.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/MRK_Marker_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/VOC_Marker_Cache_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/VOC_Term_create.object | tee -a $LOG || exit 1
${PG_DBUTILS}/sp/VOC_Cache_Markers.csh ${PG_DBSERVER} ${PG_DBNAME} 0| tee -a $LOG || exit 1
date | tee -a ${LOG}

date | tee -a ${LOG}
echo 'step 6 : qc reports' | tee -a $LOG || exit 1
./qcnightly_reports.csh | tee -a $LOG || exit 1
date | tee -a ${LOG}

# final database check
${PG_MGD_DBSCHEMADIR}/objectCounter.sh | tee -a $LOG || exit 1

date | tee -a ${LOG}
echo "--- Finished" | tee -a ${LOG}

