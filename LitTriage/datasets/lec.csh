#!/bin/csh -f

#
# sto38/analysis of existing data sets for migration to new workflow schema
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

select r.*
into temp table tumor
from BIB_Refs r
where not exists (select 1 from BIB_Workflow_Status s
	where s._Group_key = 31576667
	and r._Refs_key = s._Refs_key)
;

select count(*) from tumor;

EOSQL

date |tee -a $LOG
