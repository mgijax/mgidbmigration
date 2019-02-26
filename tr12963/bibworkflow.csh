#!/bin/csh -f

#
# has tr12963 branch:
# littriageload
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
# BIB_Workflow_Data : add new field extractedTextWithRef
#
${PG_MGD_DBSCHEMADIR}/index/BIB_Workflow_Data_drop.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/BIB_Workflow_Data_drop.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/trigger/BIB_Refs_drop.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/procedure/ACC_assignJ_drop.object | tee -a $LOG || exit 1

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG
ALTER TABLE mgd.BIB_Workflow_Data DROP CONSTRAINT BIB_Workflow_Data__Refs_key_fkey CASCADE;
ALTER TABLE mgd.BIB_Workflow_Data DROP CONSTRAINT BIB_Workflow_Data_pkey CASCADE;
ALTER TABLE mgd.BIB_Workflow_Data DROP CONSTRAINT BIB_Workflow_Data__Supplemental_key_fkey CASCADE;
ALTER TABLE BIB_Workflow_Data RENAME TO BIB_Workflow_Data_old;
ALTER TABLE mgd.BIB_Workflow_Data_old DROP CONSTRAINT BIB_Workflow_Data_pkey CASCADE;
EOSQL

# new table
${PG_MGD_DBSCHEMADIR}/table/BIB_Workflow_Data_create.object | tee -a $LOG || exit 1

#
# insert data int new table
#
cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG

insert into BIB_Workflow_Data
select d._refs_key, d.hasPDF, d._supplemental_key, d.linkSupplemental, d.extractedText, null,
d._createdBy_key, d._modifiedBy_key, d.creation_date, d.modification_date
from BIB_Workflow_Data_old d
;

ALTER TABLE mgd.BIB_Workflow_Data ADD FOREIGN KEY (_Refs_key) REFERENCES mgd.BIB_Refs ON DELETE CASCADE DEFERRABLE;
ALTER TABLE mgd.BIB_Workflow_Data ADD PRIMARY KEY (_Refs_key);
ALTER TABLE mgd.BIB_Workflow_Data ADD FOREIGN KEY (_Supplemental_key) REFERENCES mgd.VOC_Term DEFERRABLE;

EOSQL

${PG_MGD_DBSCHEMADIR}/key/BIB_Workflow_Data_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/index/BIB_Workflow_Data_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/trigger/BIB_Refs_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/procedure/ACC_assignJ_create.object | tee -a $LOG || exit 1

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG

select count(*) from BIB_Workflow_Data_old;

select count(*) from BIB_Workflow_Data;

--drop table mgd.BIB_Workflow_Data_old;

EOSQL

date |tee -a $LOG

