#!/bin/csh -f

#
# move VOC_Text.note to VOC_Term
# remove VOC_Text
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
 
cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG
ALTER TABLE VOC_Term RENAME TO VOC_Term_old;
ALTER TABLE mgd.VOC_Term_old DROP CONSTRAINT VOC_Term_pkey CASCADE;
ALTER TABLE mgd.VOC_Term DROP CONSTRAINT VOC_Term__ModifiedBy_key_fkey CASCADE;
ALTER TABLE mgd.VOC_Term DROP CONSTRAINT VOC_Term__CreatedBy_key_fkey CASCADE;
EOSQL

${PG_MGD_DBSCHEMADIR}/view/view_drop.sh | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/key/VOC_Term_drop.object | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/key/VOC_Vocab_drop.object | tee -a $LOG

# new table
${PG_MGD_DBSCHEMADIR}/table/VOC_Term_create.object | tee -a $LOG || exit 1

# insert data into new table
cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG
insert into VOC_Term
select t._Term_key, t._Vocab_key, t.term, t.abbreviation, null, t.sequenceNum, t.isObsolete,
t._Createdby_key, t._Modifiedby_key, t.creation_date, t.modification_date
from VOC_Term_old t
where not exists (select 1 from VOC_Text n where t._Term_key = n._Term_key)
;
insert into VOC_Term
select t._Term_key, t._Vocab_key, t.term, t.abbreviation, n.note, t.sequenceNum, t.isObsolete,
t._Createdby_key, t._Modifiedby_key, t.creation_date, t.modification_date
from VOC_Term_old t, VOC_Text n
where t._Term_key = n._Term_key
;

select count(*) from VOC_Term_old;
select count(*) from VOC_Term;

EOSQL

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG

drop view VOC_Text_View;
drop table mgd.VOC_Term_old;
drop table mgd.VOC_Text;

ALTER TABLE mgd.VOC_Term ADD FOREIGN KEY (_CreatedBy_key) REFERENCES mgd.MGI_User DEFERRABLE;
ALTER TABLE mgd.VOC_Term ADD FOREIGN KEY (_ModifiedBy_key) REFERENCES mgd.MGI_User DEFERRABLE;

EOSQL

${PG_MGD_DBSCHEMADIR}/key/VOC_Term_create.object | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/key/VOC_Vocab_create.object | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/index/VOC_Term_create.object | tee -a $LOG

# done in part1
#${PG_MGD_DBSCHEMADIR}/view/view_create.sh | tee -a $LOG

date |tee -a $LOG

