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
${PG_MGD_DBSCHEMADIR}/table/BIB_Citation_Cache_drop.object | tee -a $LOG || exit 1

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG
ALTER TABLE BIB_Refs RENAME TO BIB_Refs_old;
EOSQL

# new table
${PG_MGD_DBSCHEMADIR}/table/BIB_Refs_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/table/BIB_Workflow_Relevance_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/table/BIB_Citation_Cache_create.object | tee -a $LOG || exit 1

${PG_MGD_DBSCHEMADIR}/procedure/BIB_reloadCache_create.object | tee -a $LOG || exit 1

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG

-- insert new BIB_Refs table (isDiscard removed)
insert into BIB_Refs
select m._Refs_key, m._ReferenceType_key, m.authors, m._primary, m.title,
m.journal, m.vol, m.issue, m.date, m.year, m.pgs, m.abstract, m.isReviewArticle,
m._CreatedBy_key, m._ModifiedBy_key, m.creation_date, m.modification_date
from BIB_Refs_old m
;

select count(*) from BIB_Refs_old;
select count(*) from BIB_Refs;

--drop table mgd.BIB_Refs_old;

EOSQL

${PG_MGD_DBSCHEMADIR}/index/BIB_Refs_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/index/BIB_Workflow_Relevance_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/index/BIB_Citation_Cache_create.object | tee -a $LOG || exit 1

./bibrelevance.csh | tee -a $LOG

date |tee -a $LOG

