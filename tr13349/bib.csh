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

${PG_MGD_DBSCHEMADIR}/index/BIB_Refs_drop.object | tee -a $LOG 
${PG_MGD_DBSCHEMADIR}/autosequence/BIB_Refs_drop.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/index/BIB_Refs_drop.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/BIB_Refs_drop.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/trigger/BIB_Refs_drop.object | tee -a $LOG || exit 1

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

#
# insert data int new table
#
cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG

insert into BIB_Refs
select m._Refs_key, m._ReferenceType_key, m.authors, m._primary, m.title,
m.journal, m.vol, m.issue, m.date, m.year, m.pgs, m.abstract, m.isReviewArticle,
m._CreatedBy_key, m._ModifiedBy_key, m.creation_date, m.modification_date
from BIB_Refs_old m
;

insert into BIB_Workflow_Relevance
select nextval('bib_workflow_relevance_seq'), m._Refs_key, 70594666, 1, null,
m._CreatedBy_key, m._ModifiedBy_key, m.creation_date, m.modification_date
from BIB_Refs_old m
where m.isDiscard = 1
;

-- _releance_key = Not Specified, confidence = null
insert into BIB_Workflow_Relevance
select nextval('bib_workflow_relevance_seq'), m._Refs_key, 70594667, 1, null,
m._CreatedBy_key, m._ModifiedBy_key, m.creation_date, m.modification_date
from BIB_Refs_old m
where m.isDiscard = 0
;

EOSQL

${PG_MGD_DBSCHEMADIR}/key/BIB_Refs_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/BIB_Workflow_Relevance_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/BIB_Citation_Cache_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/VOC_Term_drop.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/VOC_Term_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/index/BIB_Refs_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/index/BIB_Workflow_Relevance_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/procedure/BIB_reloadCache_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/procedure/BIB_getCopyright_create.object | tee -a $LOG || exit 1

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG

select  * from BIB_reloadCache();

select count(*) from BIB_Refs_old;
select count(*) from BIB_Refs;
select count(*) from BIB_Workflow_Relevance;
select count(*) from BIB_Citation_Cache;

drop table mgd.BIB_Refs_old;

EOSQL

${PG_MGD_DBSCHEMADIR}/index/BIB_Citation_Cache_create.object | tee -a $LOG || exit 1

#done in MGI_part1.csh
#${PG_MGD_DBSCHEMADIR}/trigger/BIB_Refs_create.object | tee -a $LOG || exit 1
#${PG_MGD_DBSCHEMADIR}/trigger/ACC_Accession_create.object | tee -a $LOG || exit 1
#${PG_MGD_DBSCHEMADIR}/view/BIB_Refs_View_create.object | tee -a $LOG || exit 1

date |tee -a $LOG

