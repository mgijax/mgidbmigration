#!/bin/csh -f

#
# Notes with sequenceNum
#
# 1. if necessary, merge sequenceNum > 1 into sequenceNum = 1
# 1. delete 'sequenceNum' field
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
# GXD_AssayNote
# merge sequenceNum > 1 into sequenceNum = 1
#
./notes.py
psql -h ${MGD_DBSERVER} -U ${MGD_DBUSER} -d ${MGD_DBNAME} -e -f GXD_AssayNote.sql | tee -a ${LOG}

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG

select count(*) from MLD_Expt_Notes where sequenceNum > 1;
select count(*) from MLD_Notes where sequenceNum > 1;
select count(*) from PRB_Ref_Notes where sequenceNum > 1;
select count(*) from PRB_Notes where sequenceNum > 1;
select count(*) from BIB_Notes where sequenceNum > 1;
select count(*) from MRK_Notes where sequenceNum > 1;
select count(*) from GXD_AssayNote where sequenceNum > 1;
select count(*) from VOC_Text where sequenceNum > 1;

select count(*) from MLD_Expt_Notes;
select count(*) from MLD_Notes;
select count(*) from PRB_Ref_Notes;
select count(*) from PRB_Notes;
select count(*) from BIB_Notes;
select count(*) from MRK_Notes;
select count(*) from GXD_AssayNote;
select count(*) from VOC_Text;

EOSQL

${PG_MGD_DBSCHEMADIR}/key/MLD_Expt_Notes_drop.object | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/key/MLD_Notes_drop.object | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/key/PRB_Ref_Notes_drop.object | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/key/PRB_Notes_drop.object | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/key/BIB_Notes_drop.object | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/key/MRK_Notes_drop.object | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/key/GXD_AssayNote_drop.object | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/key/VOC_Text_drop.object | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/view/VOC_Text_View_drop.object | tee -a $LOG

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG
ALTER TABLE MLD_Expt_Notes DROP COLUMN sequenceNum;
ALTER TABLE MLD_Notes DROP COLUMN sequenceNum;
ALTER TABLE PRB_Ref_Notes DROP COLUMN sequenceNum;
ALTER TABLE PRB_Notes DROP COLUMN sequenceNum;
ALTER TABLE BIB_Notes DROP COLUMN sequenceNum;
ALTER TABLE MRK_Notes DROP COLUMN sequenceNum;
ALTER TABLE GXD_AssayNote DROP COLUMN sequenceNum;
ALTER TABLE VOC_Text DROP COLUMN sequenceNum;
select count(*) from MLD_Expt_Notes;
select count(*) from MLD_Notes;
select count(*) from PRB_Ref_Notes;
select count(*) from PRB_Notes;
select count(*) from BIB_Notes;
select count(*) from MRK_Notes;
select count(*) from GXD_AssayNote;
select count(*) from VOC_Text;
EOSQL

${PG_MGD_DBSCHEMADIR}/key/MLD_Expt_Notes_create.object | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/key/MLD_Notes_create.object | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/key/PRB_Ref_Notes_create.object | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/key/PRB_Notes_create.object | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/key/BIB_Notes_create.object | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/key/MRK_Notes_create.object | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/key/GXD_AssayNote_create.object | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/key/VOC_Text_create.object | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/view/VOC_Text_View_create.object | tee -a $LOG

date |tee -a $LOG

