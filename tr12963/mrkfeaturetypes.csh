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
 
cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG
select e.*
from VOC_Evidence e
where exists (select 1 from VOC_Annot a where a._Annottype_key = 1011 and a._Annot_key = e._Annot_key)
;
delete 
from VOC_Evidence e
where exists (select 1 from VOC_Annot a where a._Annottype_key = 1011 and a._Annot_key = e._Annot_key)
;
EOSQL

date |tee -a $LOG

