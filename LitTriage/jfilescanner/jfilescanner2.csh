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
-- if Peer Reviewed Article (33853681), then "Not Specified" (33853681)
insert into BIB_Workflow_Data
select _Refs_key, 0, 33853681, null, null, 1001, 1001, now(), now()
from BIB_Refs
where _ReferenceType_key = 31576687
;
-- if not Peer Reviewed Article (33853681), then "Db supplement not found" (31576676)
insert into BIB_Workflow_Data
select _Refs_key, 0, 31576676, null, null, 1001, 1001, now(), now()
from BIB_Refs
where _ReferenceType_key != 31576687
;
EOSQL

${PG_MGD_DBSCHEMADIR}/index/BIB_Workflow_Data_create.object | tee -a ${LOG}

date | tee -a ${LOG}
echo 'migrating jfilescanner pdfs and update BIB_Workflow_Data.hasPDF = 1'
setenv LITPARSER ${MGIUTILS}/litparser
./jfilescanner2.py | tee -a $LOG || exit 1

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG
select count(*) from BIB_Workflow_Data;
select count(*) from BIB_Workflow_Data where hasPDF = 0;
select count(*) from BIB_Workflow_Data where hasPDF = 1;
EOSQL

if ( "${PROCESSTYPE}" != "2" ) then
then
cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG
select r.jnumID, r.short_citation 
from BIB_Citation_Cache r, BIB_Workflow_Data d
where r._Refs_key = d._Refs_key
and d.hasPDF = 0
order by r.jnumID
;
EOSQL
endif

