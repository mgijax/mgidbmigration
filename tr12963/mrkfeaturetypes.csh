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
 
# turn trigger off: VOC_Evidence or VOC_Annot records will also get deleted
#${PG_MGD_DBSCHEMADIR}/trigger/VOC_Evidence_drop.object | tee -a $LOG

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG

--select e.*
--from VOC_Evidence e
--where exists (select 1 from VOC_Annot a where a._Annottype_key = 1011 and a._Annot_key = e._Annot_key)
--;

--delete from MGI_Note n
--using VOC_Annot a, VOC_Evidence e
--where a._Annottype_key = 1011 
--and a._Annot_key = e._Annot_key
--and e._AnnotEvidence_key = n._Object_key
--and n._MGIType_key = 25
--;

delete from VOC_Evidence e
using VOC_Annot a
where a._Annottype_key = 1011 
and a._Annot_key = e._Annot_key
;

EOSQL

# turn trigger back on : VOC_Evidence
#${PG_MGD_DBSCHEMADIR}/trigger/VOC_Evidence_create.object | tee -a $LOG

date |tee -a $LOG

