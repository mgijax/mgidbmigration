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
 
${PG_DBUTILS}/bin/dumpTableData.csh ${MGD_DBSERVER} ${MGD_DBNAME} mgd GXD_GelLaneStructure ${MGI_LIVE}/dbutils/mgidbmigration/tr13204/GXD_GelLaneStructure.bcp "|"
${PG_MGD_DBSCHEMADIR}/index/GXD_GelLaneStructure_drop.object | tee -a $LOG || exit 1

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG
ALTER TABLE mgd.GXD_GelLaneStructure DROP CONSTRAINT GXD_GelLaneStructure_pkey CASCADE;
ALTER TABLE mgd.GXD_GelLaneStructure DROP CONSTRAINT GXD_GelLaneStructure__GelLane_key_fkey CASCADE;
ALTER TABLE mgd.GXD_GelLaneStructure DROP CONSTRAINT GXD_GelLaneStructure__EMAPA_Term_key_fkey CASCADE;
ALTER TABLE mgd.GXD_GelLaneStructure DROP CONSTRAINT GXD_GelLaneStructure__Stage_Term_key_fkey CASCADE;
ALTER TABLE GXD_GelLaneStructure RENAME TO GXD_GelLaneStructure_old;
EOSQL

# new table
${PG_MGD_DBSCHEMADIR}/table/GXD_GelLaneStructure_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/autosequence/GXD_GelLaneStructure_create.object | tee -a $LOG || exit 1

#
# insert data int new table
#
cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG

insert into GXD_GelLaneStructure
select nextval('gxd_gellanestructure_seq'), m._GelLane_key, m._EMAPA_Term_key, m._Stage_key, m.creation_date, m.modification_date
from GXD_GelLaneStructure_old m
;

ALTER TABLE mgd.GXD_GelLaneStructure ADD PRIMARY KEY (_GelLaneStructure_key);

EOSQL

${PG_MGD_DBSCHEMADIR}/index/GXD_GelLaneStructure_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/procedure/GXD_addEMAPASet_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/procedure/GXD_duplicateAssay_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/procedure/GXD_removeBadGelBand_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/view/GXD_GelLaneStructure_View_create.object | tee -a $LOG || exit 1

${PG_MGD_DBSCHEMADIR}/key/GXD_GelLane_drop.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/GXD_GelLaneStructure_drop.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/GXD_TheilerStage_drop.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/VOC_Term_drop.object | tee -a $LOG || exit 1

${PG_MGD_DBSCHEMADIR}/key/GXD_GelLane_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/GXD_GelLaneStructure_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/GXD_TheilerStage_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/VOC_Term_create.object | tee -a $LOG || exit 1

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG

select count(*) from GXD_GelLaneStructure_old;

select count(*) from GXD_GelLaneStructure;

drop table mgd.GXD_GelLaneStructure_old;

EOSQL

date |tee -a $LOG

