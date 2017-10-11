#!/bin/csh -fx

#
#
# TR12250/Literature Triage
#
# (part 1 running schema changes)
#
# pgmgddbschema
# pgdbutilities
# ei
# reports_db
# qcrepoerts_db
# mgicacheload
# lib_py_littriage
# littriageload
# mgidbmigration
#
# obsolete:
# jfilescanner?
# pgdbutilities/bin/ei/nlm.py
# pgdbutilities/bin/measurements? jon
# lib_py_postgres/stats_pg.py? jon
#
# For CutOver:
#
# new tag : 6-0-11-1
#
# 1. on bhmgiapp01:  after littriageload is installeld:
# 	ln -s /mgi/all/Triage/PDF_files/Master_Needs_Review needs_review
# 2. make sure littriageload/littriageload.config:CUTOVER=1
# 3. update datasets/MTB  (/mgi/all/wts_projects/12200/12250/DebbieK)
# 4. after cutover, set CUTOVER=0
#
# Tasks:
# 
# . Data Sets (BIB_DataSet/BIB_DataSet_Assoc):
# 	. remove from pgmgddbschema/drop tables
#	. ei/remove Reference module
#	. remove pgdbutiliites/bin/ei/nlm*
# 
# . Run on test/DEV, production the night before the migration:
# 	jfilescanner/jfilescannerpdf.csh
#	this will run *only* the PDF piece
#
# . Dave : add 'littriageload/bin/littriageload.csh' to daily tasks?
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
rm -rf */${LOG}

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
EOSQL
date | tee -a ${LOG}

#
# drop before running other migration scripts
#
${PG_MGD_DBSCHEMADIR}/trigger/trigger_drop.sh | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/view/view_drop.sh | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/procedure/procedure_drop.sh | tee -a $LOG

#
# add _Group_key to MGI_User
#
date | tee -a ${LOG}
echo 'running mgi_user change' | tee -a $LOG
./mgiuser.csh | tee -a $LOG || exit 1

#
# add new workflow tables & changes to bib_refs
#
date | tee -a ${LOG}
echo 'running new workflow/bib_refs changes' | tee -a $LOG
./bib.csh | tee -a $LOG || exit 1

cd referencetype
./bibreftype.csh | tee -a $LOG || exit 1
cd ..

#
# TR12083/ACC varchar-to-text 
# the accession.csh wrapper will drop/create procedure/view/triggers
# so don't need to add an extra call to procedure/view/triggers from this wrapper
# done on production 07/05
#
#date | tee -a ${LOG}
#echo 'running varchar-to-tee for ACC tables' | tee -a $LOG
#./accession.csh | tee -a $LOG || exit 1

#
# rebuild some things before continuing...
#
${PG_MGD_DBSCHEMADIR}/table/MGI_APILog_Event_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/table/MGI_APILog_Object_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/MGI_APILog_Event_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/MGI_APILog_Object_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/index/MGI_APILog_Event_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/index/MGI_APILog_Object_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/ACC_MGIType_drop.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/ACC_MGIType_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/BIB_drop.logical | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/BIB_create.logical | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/VOC_drop.logical | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/VOC_create.logical | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/MGI_UserRole_drop.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/MGI_User_drop.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/MGI_UserRole_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/MGI_User_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/index/BIB_drop.logical | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/index/BIB_create.logical | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/index/MGI_User_drop.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/index/MGI_User_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/trigger/trigger_create.sh | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/view/view_create.sh | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/procedure/procedure_create.sh | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/comments/comments.sh | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/objectCounter.sh | tee -a $LOG
#${PG_DBUTILS}/bin/vacuumDB.csh ${PG_DBSERVER} ${PG_DBNAME} | tee -a $LOG || exit 1
${PG_DBUTILS}/bin/analyzeDB.csh ${PG_DBSERVER} ${PG_DBNAME} | tee -a $LOG || exit 1

#
# EI depends on this cache
# and needed by the dataset migration
#
${MGICACHELOAD}/bibcitation.csh | tee -a $LOG || exit 1

#
# vocabularies : done on produciton 06/06/2017
#
#date | tee -a ${LOG}
#echo 'adding vocabularies' | tee -a $LOG
#cd vocabulary
#./vocabulary.csh | tee -a $LOG || exit 1
#cd ..

#
# datasets
#
date | tee -a ${LOG}
echo 'running data sets migration' | tee -a $LOG
cd datasets
./datasets.csh | tee -a $LOG || exit 1
cd ..

#
# pwireport
#
date | tee -a ${LOG}
echo 'running pwi/report migration' | tee -a $LOG
cd pwireport
./pwireport.csh | tee -a $LOG || exit 1
cd ..

#
# reconfig.sh: already done
#
date | tee -a ${LOG}
echo 'step ??: running triggers, procedures, views, comments' | tee -a $LOG
#${PG_MGD_DBSCHEMADIR}/reconfig.csh | tee -a $LOG || exit 1
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

date | tee -a ${LOG}
echo '--- finished part 1' | tee -a ${LOG}

