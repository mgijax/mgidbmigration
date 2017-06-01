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

-- should be 0
select r._Refs_key, r.jnumID, r.short_citation, tt.term
from BIB_Citation_Cache r, BIB_Workflow_Tag t, VOC_Term tt
where r._Refs_key = t._Refs_key
and t._Tag_key = tt._Term_key
and not exists (select 1 from BIB_Workflow_Status s
	where t._Refs_key = s._Refs_key)
;

EOSQL

