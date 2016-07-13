#!/bin/csh -fx

#
# Migration for TR12349
#
# mgidbmigration
# pgmgddbschema
# goload
# proisoformload
# reports_db
# vocload : remove ECO config/etc.
# obsolete:
# gaf_fprocessor
#
# loadadmin
# keep: prod/dailytasks.csh:${MGICACHELOAD}/go_annot_extensions_display_load.csh
# keep: prod/dailytasks.csh:${MGICACHELOAD}/go_isoforms_display_load.csh
# remove as these are now called from goload/go.sh
# remove :prod/sundaytasks.csh:${MGICACHELOAD}/go_annot_extensions_display_load.csh
# remove :prod/sundaytasks.csh:${MGICACHELOAD}/go_isoforms_display_load.csh
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
EOSQL
date | tee -a ${LOG}

#date | tee -a ${LOG}
#echo 'step 1 : run mirror_wget downloads' | tee -a $LOG || exit 1
#${MIRROR_WGET}/download_package ftp.pir.georgetown.edu.proisoform | tee -a $LOG || exit 1
#${MIRROR_WGET}/download_package pir.georgetown.edu.proisoform | tee -a $LOG || exit 1
#${MIRROR_WGET}/download_package build.berkeleybop.org.goload | tee -a $LOG || exit 1
#${MIRROR_WGET}/download_package ftp.ebi.ac.uk.goload | tee -a $LOG || exit 1
#${MIRROR_WGET}/download_package ftp.geneontology.org.goload | tee -a $LOG || exit 1

date | tee -a ${LOG}
echo 'step 2 : orc ids' | tee -a $LOG || exit 1
./orcids.csh | tee -a $LOG || exit 1
date | tee -a ${LOG}

# do all schema/stored procedure changes before the loads are run
${PG_MGD_DBSCHEMADIR}/procedure/VOC_deleteGOGAFRed_create.object | tee -a $LOG || exit 1
${PG_DBUTILS}/bin/grantPublicPerms.csh ${PG_DBSERVER} ${PG_DBNAME} mgd | tee -a $LOG || exit 1

#date | tee -a ${LOG}
#echo 'step 3 : load ECO ontology (vocload)' | tee -a $LOG || exit 1
#${VOCLOAD}/runOBOFullLoad.sh ECO.config | tee -a $LOG || exit 1
#date | tee -a ${LOG}

date | tee -a ${LOG}
echo 'step 4 : goload (goamousenoctua)' | tee -a $LOG || exit 1
${GOLOAD}/go.sh | tee -a $LOG || exit 1
date | tee -a ${LOG}

date | tee -a ${LOG}
echo 'step 5 : proisoformload' | tee -a $LOG || exit 1
${PROISOFORMLOAD}/bin/proisoform.sh | tee -a $LOG || exit 1
date | tee -a ${LOG}

date | tee -a ${LOG}
echo 'step 6 : qc reports' | tee -a $LOG || exit 1
./qcnightly_reports.csh | tee -a $LOG || exit 1
date | tee -a ${LOG}

# final database check
${PG_MGD_DBSCHEMADIR}/objectCounter.sh | tee -a $LOG || exit 1

date | tee -a ${LOG}
echo "--- Finished" | tee -a ${LOG}

