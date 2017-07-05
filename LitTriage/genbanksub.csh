#!/bin/csh -f

#
# migrates bib_refs._referencetype_key
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

-- delete GenBank Submission 
--delete from BIB_Refs where journal = 'GenBank Submission';

select distinct r.jnumID, m.symbol, r.short_citation
from BIB_Citation_Cache r, MRK_History a, MRK_Marker m
where r.journal = 'GenBank Submission'
and r._Refs_key = a._Refs_key
and a._Marker_key = m._Marker_key
order by m.symbol
;

EOSQL

