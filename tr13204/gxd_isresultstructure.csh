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
 
${PG_DBUTILS}/bin/dumpTableData.csh ${MGD_DBSERVER} ${MGD_DBNAME} mgd GXD_ISResultStructure ${MGI_LIVE}/dbutils/mgidbmigration/tr13204/GXD_ISResultStructure.bcp "|"
${PG_MGD_DBSCHEMADIR}/index/GXD_ISResultStructure_drop.object | tee -a $LOG || exit 1

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG
ALTER TABLE mgd.GXD_ISResultStructure DROP CONSTRAINT GXD_ISResultStructure_pkey CASCADE;
ALTER TABLE mgd.GXD_ISResultStructure DROP CONSTRAINT GXD_ISResultStructure__Result_key_fkey CASCADE;
ALTER TABLE mgd.GXD_ISResultStructure DROP CONSTRAINT GXD_ISResultStructure__EMAPA_Term_key_fkey CASCADE;
ALTER TABLE mgd.GXD_ISResultStructure DROP CONSTRAINT GXD_ISResultStructure__Stage_Term_key_fkey CASCADE;
ALTER TABLE GXD_ISResultStructure RENAME TO GXD_ISResultStructure_old;
EOSQL

# new table
${PG_MGD_DBSCHEMADIR}/table/GXD_ISResultStructure_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/autosequence/GXD_ISResultStructure_create.object | tee -a $LOG || exit 1

#
# insert data int new table
#
cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG

insert into GXD_ISResultStructure
select nextval('gxd_isresultstructure_seq'), m._Result_key, m._EMAPA_Term_key, m._Stage_key, m.creation_date, m.modification_date
from GXD_ISResultStructure_old m
;

ALTER TABLE mgd.GXD_ISResultStructure ADD PRIMARY KEY (_ISResultStructure_key);

EOSQL

${PG_MGD_DBSCHEMADIR}/index/GXD_ISResultStructure_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/procedure/GXD_addEMAPASet_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/procedure/GXD_duplicateAssay_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/view/GXD_ISResultImage_View_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/view/GXD_ISResultStructure_View_create.object | tee -a $LOG || exit 1

${PG_MGD_DBSCHEMADIR}/key/GXD_InSituResult_drop.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/GXD_ISResultStructure_drop.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/GXD_TheilerStage_drop.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/VOC_Term_drop.object | tee -a $LOG || exit 1

${PG_MGD_DBSCHEMADIR}/key/GXD_InSituResult_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/GXD_ISResultStructure_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/GXD_TheilerStage_create.object | tee -a $LOG || exit 1
${PG_MGD_DBSCHEMADIR}/key/VOC_Term_create.object | tee -a $LOG || exit 1

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG

select count(*) from GXD_ISResultStructure_old;

select count(*) from GXD_ISResultStructure;

drop table mgd.GXD_ISResultStructure_old;

EOSQL

date |tee -a $LOG

