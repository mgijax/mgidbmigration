#!/bin/csh -f

#
# migrates existing bib_refs to new bib_refs table
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
# new workflow tables
#
${PG_MGD_DBSCHEMADIR}/table/BIB_Workflow_Data_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/table/BIB_Workflow_Status_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/table/BIB_Workflow_Tag_create.object | tee -a $LOG || exit 1

#
# BIB_Refs changes
#
cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG
ALTER TABLE BIB_Refs RENAME TO BIB_Refs_old;
ALTER TABLE mgd.BIB_Refs_old DROP CONSTRAINT BIB_Refs_pkey CASCADE;
EOSQL

# new table
${PG_MGD_DBSCHEMADIR}/table/BIB_Refs_create.object | tee -a $LOG || exit 1

#
# insert data into new table using "Not Specified"
# OR
# use rules to translate to correct Reference Type
#
cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG

insert into BIB_Refs
select _Refs_key, 
(select t._Term_key from VOC_Term t, VOC_Vocab v 
	where v.name = 'Reference Type' and v._Vocab_key = t._Vocab_key and t.term = 'Not Specified'),
authors, _primary, title, journal, vol, issue, date, year, pgs, abstract, isReviewArticle,
_CreatedBy_key, _ModifiedBy_key, creation_date, modification_date  
from BIB_Refs_old
where not exists (select 1 from BIB_Books where BIB_Refs_old._Refs_key = BIB_Books._Refs_key)
;

insert into BIB_Refs
select _Refs_key, 
(select t._Term_key from VOC_Term t, VOC_Vocab v 
	where v.name = 'Reference Type' and v._Vocab_key = t._Vocab_key and t.term = 'Book'),
authors, _primary, title, journal, vol, issue, date, year, pgs, abstract, isReviewArticle,
_CreatedBy_key, _ModifiedBy_key, creation_date, modification_date  
from BIB_Refs_old
where exists (select 1 from BIB_Books where BIB_Refs_old._Refs_key = BIB_Books._Refs_key)
;

EOSQL

# new table
${PG_MGD_DBSCHEMADIR}/table/BIB_Citation_Cache_drop.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/table/BIB_Citation_Cache_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/BIB_drop.logical | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/BIB_create.logical | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/VOC_drop.logical | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/VOC_create.logical | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/index/BIB_drop.logical | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/index/BIB_create.logical | tee -a $LOG || exit 1

# done in MGI_part1.csh
#${PG_MGD_DBSCHEMADIR}/view/view_drop.logical | tee -a $LOG || exit 1
#${PG_MGD_DBSCHEMADIR}/view/view_create.logical | tee -a $LOG || exit 1
#${PG_MGD_DBSCHEMADIR}/procedure/procedure_drop.logical | tee -a $LOG || exit 1
#${PG_MGD_DBSCHEMADIR}/procedure/procedure_create.logical | tee -a $LOG || exit 1

#
# turn on when ready to remove BIB_DataSet* tables
cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG
drop table mgd.BIB_Refs_old;
drop table mgd.BIB_ReviewStatus;
--after migration, this term can be deleted
--delete from VOC_Term t using VOC_Vocab v where v.name = 'Reference Type' and v._Vocab_key = t._Vocab_key and t.term = 'Not Specified';
--drop table mgd.BIB_DataSet_Assoc;
--drop table mgd.BIB_DataSet;
EOSQL

