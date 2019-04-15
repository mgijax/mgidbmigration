#!/bin/csh -f

#
# delete marker feature types VOC_Evidence
# 
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
 
#${PG_DBUTILS}/bin/loadTableData.csh ${MGD_DBSERVER} ${MGD_DBNAME} mgd VOC_Annot ${MGI_LIVE}/dbutils/mgidbmigration/tr12963/VOC_Annot.bcp "|"

${PG_DBUTILS}/bin/dumpTableData.csh ${MGD_DBSERVER} ${MGD_DBNAME} mgd VOC_Annot ${MGI_LIVE}/dbutils/mgidbmigration/tr12963/VOC_Annot.bcp "|"
${PG_DBUTILS}/bin/dumpTableData.csh ${MGD_DBSERVER} ${MGD_DBNAME} mgd VOC_Evidence ${MGI_LIVE}/dbutils/mgidbmigration/tr12963/VOC_Evidence.bcp "|"

# turn trigger off: VOC_Evidence or VOC_Annot records will also get deleted
${PG_MGD_DBSCHEMADIR}/trigger/VOC_Evidence_drop.object | tee -a $LOG

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG

select count(*) from voc_annot where _annottype_key = 1011
;

delete from MGI_Note n
using VOC_Annot a, VOC_Evidence e
where a._Annottype_key = 1011 
and a._Annot_key = e._Annot_key
and e._AnnotEvidence_key = n._Object_key
and n._MGIType_key = 25
;

delete from VOC_Evidence e
using VOC_Annot a
where a._Annottype_key = 1011 
and a._Annot_key = e._Annot_key
;

select count(*) from voc_annot where _annottype_key = 1011
;

EOSQL

# turn trigger back on : VOC_Evidence
${PG_MGD_DBSCHEMADIR}/trigger/VOC_Evidence_create.object | tee -a $LOG

date |tee -a $LOG

