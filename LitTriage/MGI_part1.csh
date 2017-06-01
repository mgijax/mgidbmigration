#!/bin/csh -fx

#
#
# TR12250/Literature Triage
#
# (part 1 running schema changes)
#
# pgmgddbschema-tr12250
# pgdbutilities-tr12250
# ei-tr12250
# mgipython-tr12250
# pwi-tr12250
# reports_db-tr12250
# qcrepoerts_db-tr12250
# mgicacheload-tr12250
# femover-tr12250
#
# obsolete:
# jfilescanner?
# pgdbutilities/bin/ei/nlm.py
# pgdbutilities/bin/measurements
# lib_py_postgres/stats_pg.py
# 

###----------------------###
###--- initialization ---###
###----------------------###

if ( ${?MGICONFIG} == 0 ) then
	setenv MGICONFIG /usr/local/mgi/live/mgiconfig
endif

source ${MGICONFIG}/master.config.csh

setenv LOG $0.log
rm -rf ${LOG}
touch ${LOG}

date | tee -a ${LOG}
echo '--- starting part 1' | tee -a $LOG

echo 'MGD_DBNAME='$MGD_DBNAME | tee -a $LOG || exit 1
echo 'MGD_DBPASSWORDFILE='$MGD_DBPASSWORDFILE | tee -a $LOG || exit 1
echo 'MGD_DBSERVER='$MGD_DBSERVER | tee -a $LOG || exit 1
echo 'MGD_DBUSER='$MGD_DBUSER | tee -a $LOG || exit 1

#${PG_DBUTILS}/bin/loadDB.csh mgi-testdb4 lec radar /bhmgidevdb01/dump/radar.dump
#${PG_DBUTILS}/bin/loadDB.csh mgi-testdb4 lec mgd /bhmgidevdb01/dump/mgd.dump
${PG_MGD_DBSCHEMADIR}/objectCounter.sh | tee -a $LOG || exit 1

#
# update schema-version and public-version
#
date | tee -a ${LOG}
cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG
update MGI_dbinfo set schema_version = '6-0-11', public_version = 'MGI 6.11';
EsOSQL
date | tee -a ${LOG}

#
# add new tables
#
${PG_MGD_DBSCHEMADIR}/table/BIB_Workflow_Data_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/table/BIB_Workflow_Status_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/table/BIB_Workflow_Tag_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/table/BIB_Citation_Cache_drop.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/table/BIB_Citation_Cache_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/BIB_drop.logical | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/BIB_create.logical | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/VOC_drop.logical | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/VOC_create.logical | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/index/BIB_drop.logical | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/index/BIB_create.logical | tee -a $LOG || exit 1

#
# TR12083/ACC varchar-to-text 
# the accession.csh wrapper will drop/create procedure/view/triggers
# so don't need to add an extra call to procedure/view/triggers from this wrapper
#
date | tee -a ${LOG}
echo 'running varchar-to-tee for ACC tables' | tee -a $LOG
./accession.csh | tee -a $LOG || exit 1

#
# vocabularies
#
date | tee -a ${LOG}
echo 'adding vocabularies' | tee -a $LOG
cd vocabulary
./vocabulary.csh | tee -a $LOG || exit 1

#
# EI depends on this cache
# and needed by the dataset migration
#
${MGICACHELOAD}/bibcitation.csh | tee -a $LOG || exit 1

#
# datasets
#
date | tee -a ${LOG}
echo 'running data sets migration' | tee -a $LOG
cd datasets
./datasets.csh | tee -a $LOG || exit 1

#
# reconfig.sh:
# Drop and re-create database triggers, stored procedures, views and comments
# always a good idea to do to make sure that nothing was missed with schema changes
#
date | tee -a ${LOG}
echo 'step ??: running triggers, procedures, views, comments' | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/comments/comments_create.sh | tee -a $LOG || exit 1
#${PG_MGD_DBSCHEMADIR}/reconfig.sh | tee -a $LOG || exit 1
${PG_DBUTILS}/bin/grantPublicPerms.csh ${PG_DBSERVER} ${PG_DBNAME} mgd | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/objectCounter.sh | tee -a $LOG || exit 1

#
# cleanobjects.sh : removing stray mgi_notes
#
date | tee -a ${LOG}
echo 'data cleanup' | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/test/cleanobjects.sh | tee -a $LOG || exit 1

#
# rebuild the java dla, if needed due to schema changes
#
${MGI_JAVALIB}/lib_java_dbsmgd/Install | tee -a $LOG
${MGI_JAVALIB}/lib_java_dla/Install | tee -a $LOG

#
# run the measurements for are later used for the front-end
#
#date | tee -a ${LOG}
#echo 'step ??: run statistics' | tee -a $LOG
#${PG_DBUTILS}/bin/measurements/addMeasurements.csh | tee -a $LOG || exit 1

date | tee -a ${LOG}
echo '--- finished part 1' | tee -a ${LOG}

