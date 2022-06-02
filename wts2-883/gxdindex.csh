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
 
${PG_DBUTILS}/bin/dumpTableData.csh ${MGD_DBSERVER} ${MGD_DBNAME} mgd GXD_Index_Stages ${MGI_LIVE}/dbutils/mgidbmigration/cre2022/GXD_Index_Stages.bcp "|"

${PG_MGD_DBSCHEMADIR}/index/GXD_Index_Stages_drop.object | tee -a $LOG 
${PG_MGD_DBSCHEMADIR}/key/GXD_Index_Stages_drop.object | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/key/GXD_Index_drop.object | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/key/MGI_User_drop.object | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/key/VOC_Term_drop.object | tee -a $LOG

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG
ALTER TABLE GXD_Index_Stages RENAME TO GXD_Index_Stages_old;
EOSQL

# new table
${PG_MGD_DBSCHEMADIR}/table/GXD_Index_Stages_create.object | tee -a $LOG 
${PG_MGD_DBSCHEMADIR}/autosequence/GXD_Index_create.object | tee -a $LOG 
${PG_MGD_DBSCHEMADIR}/autosequence/GXD_Index_Stages_create.object | tee -a $LOG 
${PG_MGD_DBSCHEMADIR}/procedure/MRK_updateKeys_create.object | tee -a $LOG

#
# insert data int new table
#
cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG

insert into GXD_Index_Stages
select nextval('gxd_indexstage_seq'), _index_key, _indexassay_key, _stageid_key, _createdby_key, _modifiedby_key, creation_date , modification_date
from GXD_Index_Stages_old
;

EOSQL

${PG_MGD_DBSCHEMADIR}/index/GXD_Index_Stages_create.object | tee -a $LOG 
${PG_MGD_DBSCHEMADIR}/key/GXD_Index_Stages_create.object | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/key/GXD_Index_create.object | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/key/MGI_User_create.object | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/key/VOC_Term_create.object | tee -a $LOG

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG
select count(*) from GXD_Index_Stages_old;
select count(*) from GXD_Index_Stages;
EOSQL

date |tee -a $LOG

