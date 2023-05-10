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
 
cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG
select count(*) from VOC_Evidence_Property;
select max(_EvidenceProperty_key) from VOC_Evidence_Property;
select last_value from voc_evidence_property_seq;
EOSQL

rm -rf VOC_Evidence_Property.bcp
rm -rf VOC_Evidence_Property.sort
rm -rf VOC_Evidence_Property.new

${PG_DBUTILS}/bin/dumpTableData.csh ${MGD_DBSERVER} ${MGD_DBNAME} mgd VOC_Evidence_Property ${MGI_LIVE}/dbutils/mgidbmigration/wts2-1175/VOC_Evidence_Property.bcp "|"
sort VOC_Evidence_Property.bcp > VOC_Evidence_Property.sort

${PYTHON} vocproperty.py | tee -a $LOG

${PG_MGD_DBSCHEMADIR}/table/VOC_Evidence_Property_truncate.object | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/autosequence/VOC_Evidence_Property_drop.object | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/index/VOC_Evidence_Property_drop.object | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/key/VOC_Evidence_Property_drop.object | tee -a $LOG

${PG_DBUTILS}/bin/loadTableData.csh ${MGD_DBSERVER} ${MGD_DBNAME} mgd VOC_Evidence_Property ${MGI_LIVE}/dbutils/mgidbmigration/wts2-1175/VOC_Evidence_Property.new "|"
${PG_MGD_DBSCHEMADIR}/autosequence/VOC_Evidence_Property_create.object | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/index/VOC_Evidence_Property_create.object | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/key/VOC_Evidence_Property_create.object | tee -a $LOG

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG
select count(*) from VOC_Evidence_Property;
select max(_EvidenceProperty_key) from VOC_Evidence_Property;
select last_value from voc_evidence_property_seq;
EOSQL

date |tee -a $LOG

