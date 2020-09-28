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
 
${PG_DBUTILS}/bin/dumpTableData.csh ${MGD_DBSERVER} ${MGD_DBNAME} mgd GXD_AssayNote ${MGI_LIVE}/dbutils/mgidbmigration/tr13204/GXD_AssayNote.bcp "|"

${PG_MGD_DBSCHEMADIR}/index/GXD_AntibodyMarker_drop.object | tee -a $LOG 
${PG_MGD_DBSCHEMADIR}/index/GXD_AssayNote_drop.object | tee -a $LOG 
${PG_MGD_DBSCHEMADIR}/index/GXD_GelLaneStructure_drop.object | tee -a $LOG 
${PG_MGD_DBSCHEMADIR}/index/GXD_InSituResultImage_drop.object | tee -a $LOG 
${PG_MGD_DBSCHEMADIR}/index/GXD_ISResultStructure_drop.object | tee -a $LOG 

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG
ALTER TABLE mgd.GXD_AssayNote DROP CONSTRAINT GXD_AssayNote_pkey CASCADE;
ALTER TABLE mgd.GXD_AssayNote DROP CONSTRAINT GXD_AssayNote__Assay_key_fkey CASCADE;
ALTER TABLE GXD_AssayNote RENAME TO GXD_AssayNote_old;
ALTER TABLE mgd.GXD_AssayNote ADD PRIMARY KEY (_AssayNote_key);
ALTER TABLE mgd.GXD_AssayNote ADD FOREIGN KEY (_Assay_key) REFERENCES mgd.GXD_Assay ON DELETE CASCADE DEFERRABLE;
EOSQL

# new table
${PG_MGD_DBSCHEMADIR}/table/GXD_AssayNote_create.object | tee -a $LOG || exit 1

# autosequence
${PG_MGD_DBSCHEMADIR}/autosequence/GXD_AssayNote_create.object | tee -a $LOG || exit 1

#
# insert data int new table
#
cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG

drop index gxd_assaynote_idx_assay_key;

insert into GXD_AssayNote
select nextval('gxd_assaynote_seq'), m._Assay_key, m.assayNote, m.creation_date, m.modification_date
from GXD_AssayNote_old m
;

ALTER TABLE mgd.GXD_AssayNote ADD PRIMARY KEY (_AssayNote_key);
ALTER TABLE mgd.GXD_AssayNote ADD FOREIGN KEY (_Assay_key) REFERENCES mgd.GXD_Assay ON DELETE CASCADE DEFERRABLE;

EOSQL

${PG_MGD_DBSCHEMADIR}/index/GXD_AssayNote_create.object | tee -a $LOG || exit 1

${PG_MGD_DBSCHEMADIR}/key/GXD_AssayNote_drop.object | tee -a $LOG || exit 1

${PG_MGD_DBSCHEMADIR}/key/GXD_AssayNote_create.object | tee -a $LOG || exit 1

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG

select count(*) from GXD_AssayNote_old;
select count(*) from GXD_AssayNote;

drop table mgd.GXD_AssayNote_old;

EOSQL

date |tee -a $LOG

