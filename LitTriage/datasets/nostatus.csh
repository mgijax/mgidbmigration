#!/bin/csh -f

#
# all Tags should have a Status
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

select r._Refs_key, r.jnumID, r.short_citation
from BIB_Citation_Cache r
where not exists (select 1 from BIB_Workflow_Status s
	where r._Refs_key = s._Refs_key)
;

select count(*) from BIB_Refs;
select count(distinct _Refs_key) from BIB_Workflow_Status ;

EOSQL

