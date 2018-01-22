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
 
cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG
select count(*) from MLD_Expt_Notes where sequenceNum > 1;
select count(*) from MLD_Notes where sequenceNum > 1;
select count(*) from PRB_Ref_Notes where sequenceNum > 1;
select count(*) from PRB_Notes where sequenceNum > 1;
select count(*) from BIB_Notes where sequenceNum > 1;
select count(*) from GXD_AssayNote where sequenceNum > 1;
select count(*) from MRK_Notes where sequenceNum > 1;
select count(*) from MLD_Expt_Notes;
select count(*) from MLD_Notes;
select count(*) from PRB_Ref_Notes;
select count(*) from PRB_Notes;
select count(*) from BIB_Notes;
select count(*) from MRK_Notes;
EOSQL

${PG_MGD_DBSCHEMADIR}/key/MLD_Expt_Notes_drop.object | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/key/MLD_Notes_drop.object | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/key/PRB_Ref_Notes_drop.object | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/key/PRB_Notes_drop.object | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/key/BIB_Notes_drop.object | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/key/MRK_Notes_drop.object | tee -a $LOG

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG
ALTER TABLE MLD_Expt_Notes DROP COLUMN sequenceNum;
ALTER TABLE MLD_Notes DROP COLUMN sequenceNum;
ALTER TABLE PRB_Ref_Notes DROP COLUMN sequenceNum;
ALTER TABLE PRB_Notes DROP COLUMN sequenceNum;
ALTER TABLE BIB_Ref_Notes DROP COLUMN sequenceNum;
ALTER TABLE MRK_Ref_Notes DROP COLUMN sequenceNum;
select count(*) from MLD_Expt_Notes;
select count(*) from MLD_Notes;
select count(*) from PRB_Ref_Notes;
select count(*) from PRB_Notes;
select count(*) from BIB_Notes;
select count(*) from MRK_Notes;
EOSQL

${PG_MGD_DBSCHEMADIR}/key/MLD_Expt_Notes_create.object | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/key/MLD_Notes_create.object | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/key/PRB_Ref_Notes_create.object | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/key/PRB_Notes_create.object | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/key/BIB_Notes_create.object | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/key/MRK_Notes_create.object | tee -a $LOG

date |tee -a $LOG

