#!/bin/csh -f

#
# migration of jfilescanner, BIB_Workflow_Data
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

${PG_MGD_DBSCHEMADIR}/table/BIB_Workflow_Data_truncate.object | tee -a ${LOG}
${PG_MGD_DBSCHEMADIR}/index/BIB_Workflow_Data_drop.object | tee -a ${LOG}

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG
-- add BIB_Workflow_Data records for all references
insert into BIB_Workflow_Data
select _Refs_key, 0, 31576677, null, null, 1001, 1001, now(), now()
from BIB_Refs
;
EOSQL

${PG_MGD_DBSCHEMADIR}/index/BIB_Workflow_Data_create.object | tee -a ${LOG}

date | tee -a ${LOG}
echo 'migrating jfilescanner pdfs and update BIB_Workflow_Data.hasPDF = 1'
./jfilescanner.py | tee -a $LOG || exit 1

