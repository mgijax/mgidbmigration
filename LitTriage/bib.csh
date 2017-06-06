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
insert into VOC_Vocab values((select max(_Vocab_key) + 1 from VOC_Vocab),22864,-1,1,0,'Reference Type',now(),now());
EOSQL

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG
insert into VOC_Term values(
(select max(_Term_key) + 1 from VOC_Term),
(select _Vocab_key from VOC_Vocab where name = 'Reference Type'), 
'Annual Report/Bulletin',null,1,0,1001,1001,now(),now());
insert into VOC_Term values(
(select max(_Term_key) + 1 from VOC_Term),
(select _Vocab_key from VOC_Vocab where name = 'Reference Type'), 
'Book',null,2,0,1001,1001,now(),now());
insert into VOC_Term values(
(select max(_Term_key) + 1 from VOC_Term),
(select _Vocab_key from VOC_Vocab where name = 'Reference Type'), 
'Conference Proceedings/Abstracts',null,3,0,1001,1001,now(),now());
insert into VOC_Term values(
(select max(_Term_key) + 1 from VOC_Term),
(select _Vocab_key from VOC_Vocab where name = 'Reference Type'), 
'MGI Data Load',null,4,0,1001,1001,now(),now());
insert into VOC_Term values(
(select max(_Term_key) + 1 from VOC_Term),
(select _Vocab_key from VOC_Vocab where name = 'Reference Type'), 
'MGI Direct Data Submission',null,5,0,1001,1001,now(),now());
insert into VOC_Term values(
(select max(_Term_key) + 1 from VOC_Term),
(select _Vocab_key from VOC_Vocab where name = 'Reference Type'), 
'Dissertation/Thesis',null,6,0,1001,1001,now(),now());
insert into VOC_Term values(
(select max(_Term_key) + 1 from VOC_Term),
(select _Vocab_key from VOC_Vocab where name = 'Reference Type'), 
'External Resource',null,7,0,1001,1001,now(),now());
insert into VOC_Term values(
(select max(_Term_key) + 1 from VOC_Term),
(select _Vocab_key from VOC_Vocab where name = 'Reference Type'), 
'JAX Notes',null,8,0,1001,1001,now(),now());
insert into VOC_Term values(
(select max(_Term_key) + 1 from VOC_Term),
(select _Vocab_key from VOC_Vocab where name = 'Reference Type'), 
'MGI Curation Record',null,9,0,1001,1001,now(),now());
insert into VOC_Term values(
(select max(_Term_key) + 1 from VOC_Term),
(select _Vocab_key from VOC_Vocab where name = 'Reference Type'), 
'Peer Reviewed Article',null,10,0,1001,1001,now(),now());
insert into VOC_Term values(
(select max(_Term_key) + 1 from VOC_Term),
(select _Vocab_key from VOC_Vocab where name = 'Reference Type'), 
'Personal Communication',null,11,0,1001,1001,now(),now());
insert into VOC_Term values(
(select max(_Term_key) + 1 from VOC_Term),
(select _Vocab_key from VOC_Vocab where name = 'Reference Type'), 
'Unreviewed Article',null,12,0,1001,1001,now(),now());
insert into VOC_Term values(
(select max(_Term_key) + 1 from VOC_Term),
(select _Vocab_key from VOC_Vocab where name = 'Reference Type'), 
'Newsletter',null,13,0,1001,1001,now(),now());
insert into VOC_Term values(
(select max(_Term_key) + 1 from VOC_Term),
(select _Vocab_key from VOC_Vocab where name = 'Reference Type'), 
'Not Specified',null,14,0,1001,1001,now(),now());

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
EOSQL

