#!/bin/csh -f

#
# Template
#


if ( ${?MGICONFIG} == 0 ) then
        setenv MGICONFIG /usr/local/mgi/live/mgiconfig
endif

source ${MGICONFIG}/master.config.csh

cd `dirname $0`

setenv LOG $0.log
rm -rf $LOG
touch $LOG
 
date | tee -a $LOG

#
# if running standalone...turn this on...else see MGI_part1.csh
#
${PG_MGD_DBSCHEMADIR}/trigger/trigger_drop.sh | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/view/view_drop.sh | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/procedure/procedure_drop.sh | tee -a $LOG

${PG_MGD_DBSCHEMADIR}/index/ACC_drop.logical | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/key/ACC_drop.logical | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/key/BIB_drop.logical | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/key/MGI_User_drop.object | tee -a $LOG

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG

DROP FUNCTION IF EXISTS ACCRef_process(int,int,int,varchar,int,varchar,int,int);
DROP FUNCTION IF EXISTS ACC_assignMGI(int,int,varchar,varchar,int);
DROP FUNCTION IF EXISTS ACC_insertNoChecks(int,int,varchar,int,varchar,int,int,int,int);
DROP FUNCTION IF EXISTS ACC_setMax(int,varchar);
DROP FUNCTION IF EXISTS ACC_split(varchar);
DROP FUNCTION IF EXISTS ACC_update(int,int,varchar,int,int);
DROP FUNCTION IF EXISTS SEQ_merge(varchar,varchar);
DROP FUNCTION IF EXISTS SEQ_split(varchar,text);

ALTER TABLE ACC_AccessionMax ALTER COLUMN prefixPart TYPE text;
ALTER TABLE ACC_Accession ALTER COLUMN accID TYPE text;
ALTER TABLE ACC_Accession ALTER COLUMN prefixPart TYPE text;
ALTER TABLE ACC_ActualDB ALTER COLUMN name TYPE text;
ALTER TABLE ACC_LogicalDB ALTER COLUMN name TYPE text;
ALTER TABLE ACC_MGIType ALTER COLUMN name TYPE text;
ALTER TABLE ACC_MGIType ALTER COLUMN tableName TYPE text;
ALTER TABLE ACC_MGIType ALTER COLUMN primaryKeyName TYPE text;
ALTER TABLE ACC_MGIType ALTER COLUMN identityColumnName TYPE text;
ALTER TABLE ACC_MGIType ALTER COLUMN dbView TYPE text;

EOSQL

${PG_MGD_DBSCHEMADIR}/key/ACC_create.logical | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/key/BIB_create.logical | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/key/MGI_User_create.object | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/index/ACC_create.logical | tee -a $LOG

#
# if running standalone...turn this on...else see MGI_part1.csh
#
${PG_MGD_DBSCHEMADIR}/trigger/trigger_create.sh | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/view/view_create.sh | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/procedure/procedure_create.sh | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/comments/comments_create.sh | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/objectCounter.sh | tee -a $LOG
#
# rebuild the java dla, if needed due to schema changes
#
## done in MGI_part1.csh
${MGI_JAVALIB}/lib_java_dbsmgd/Install | tee -a $LOG
${MGI_JAVALIB}/lib_java_dla/Install | tee -a $LOG
#
# cache tables
#
#${DBUTILS}/mgidbmigration/MGI_part3.csh | tee -a $LOG
#
# end running standalone
#

#cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG
#select count(*) from ALL_Cre_Cache;
#select count(*) from ALL_Knockout_Cache;
#select count(*) from BIB_Citation_Cache;
#select count(*) from MRK_DO_Cache;
#select count(*) from MRK_Location_Cache;
#select count(*) from MRK_MCV_Cache;
#select count(*) from MRK_MCV_Count_Cache;
#select count(*) from SEQ_Coord_Cache;
#select count(*) from SEQ_Marker_Cache;
#select count(*) from SEQ_Probe_Cache;
#EOSQL

${PG_DBUTILS}/bin/analyzeDB.csh ${PG_DBSERVER} ${PG_DBNAME} | tee -a $LOG

date |tee -a $LOG

