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

select wfg.term, wfs.term, r.jnumID, r.short_citation, r._Refs_key
from BIB_Citation_Cache r, BIB_Workflow_Status s, VOC_Term wfg, VOC_Term wfs
where r._Refs_key = s._Refs_key
and s._Group_key = wfg._Term_key
and s._Status_key = wfs._Term_key
and wfg.term = 'Expression'
order by wfg.term, wfs.term, r.short_citation
;

EOSQL

