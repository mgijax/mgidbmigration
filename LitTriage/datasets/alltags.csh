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

select wft.term, r.jnumID, r.short_citation, r._Refs_key
from BIB_Citation_Cache r, BIB_Workflow_Tag s, VOC_Term wft
where r._Refs_key = s._Refs_key
and s._Tag_key = wft._Term_key
and wft.term in ('AP:Incomplete', 'AP:strains', 'GXD:Loads')
order by wft.term, r.short_citation
;

EOSQL

