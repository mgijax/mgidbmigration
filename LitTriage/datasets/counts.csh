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

select wfg.term, wfs.term, count(*)
from BIB_Citation_Cache r, BIB_Workflow_Status s, VOC_Term wfg, VOC_Term wfs
where r._Refs_key = s._Refs_key
and s._Group_key = wfg._Term_key
and s._Status_key = wfs._Term_key
group by wfg.term, wfs.term
order by wfg.term
;

select wft.term, count(*)
from BIB_Citation_Cache r, BIB_Workflow_Tag t, VOC_Term wft
where r._Refs_key = t._Refs_key
and t._Tag_key = wft._Term_key
group by wft.term
order by wft.term
;

EOSQL

