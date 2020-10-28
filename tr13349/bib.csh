#!/bin/csh -f

if ( ${?MGICONFIG} == 0 ) then
        setenv MGICONFIG /usr/local/mgi/live/mgiconfig
endif

source ${MGICONFIG}/master.config.csh

cd `dirname $0`

setenv LOG $0.log
rm -rf $LOG
touch $LOG
 
date | tee -a $LOG
 
${PG_DBUTILS}/bin/dumpTableData.csh ${MGD_DBSERVER} ${MGD_DBNAME} mgd BIB_Refs ${MGI_LIVE}/dbutils/mgidbmigration/tr13349/BIB_Refs.bcp "|"

${PG_MGD_DBSCHEMADIR}/index/BIB_Refs_drop.object | tee -a $LOG || exit 1

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG
ALTER TABLE mgd.BIB_Refs DROP CONSTRAINT BIB_Refs__ModifiedBy_key_fkey CASCADE;
ALTER TABLE mgd.BIB_Refs DROP CONSTRAINT BIB_Refs__CreatedBy_key_fkey CASCADE;
ALTER TABLE mgd.BIB_Refs DROP CONSTRAINT BIB_Refs__ReferenceType_key_fkey CASCADE;
ALTER TABLE BIB_Refs RENAME TO BIB_Refs_old;
EOSQL

# new table
${PG_MGD_DBSCHEMADIR}/table/BIB_Refs_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/table/BIB_Workflow_Relevance_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/table/BIB_Citation_Cache_drop.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/table/BIB_Citation_Cache_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/autosequence/BIB_Refs_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/autosequence/BIB_Workflow_Relevance_create.object | tee -a $LOG || exit 1

${PG_MGD_DBSCHEMADIR}/key/BIB_Workflow_Relevance_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/BIB_Citation_Cache_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/VOC_Term_drop.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/VOC_Term_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/index/BIB_Refs_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/index/BIB_Workflow_Relevance_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/procedure/BIB_reloadCache_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/procedure/BIB_getCopyright_create.object | tee -a $LOG || exit 1

#./bibrelevance.csh | tee -a $LOG

#cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG

#select  * from BIB_reloadCache();
#
#select count(*) from BIB_Refs_old;
#select count(*) from BIB_Refs;
#select count(*) from BIB_Workflow_Relevance;
#select count(*) from BIB_Citation_Cache;
#
#select count(*) from BIB_Refs_old where isdiscard = 0;
#select count(*) from BIB_Workflow_Relevance where _relevance_key = 70594667;
#
#select count(*) from BIB_Refs_old where isdiscard = 1;
#select count(*) from BIB_Workflow_Relevance where _relevance_key = 70594666;
#
#--drop table mgd.BIB_Refs_old;
#
#EOSQL
#
#${PG_MGD_DBSCHEMADIR}/index/BIB_Citation_Cache_create.object | tee -a $LOG || exit 1

date |tee -a $LOG

