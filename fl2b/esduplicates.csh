#!/bin/csh -f

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

WITH markers AS (
select _organism_key, symbol 
from MRK_Marker 
where _organism_key = 2
group by _organism_key, symbol having count(*) > 1
)
select m._marker_key, m._organism_key, m.symbol, a.accid, m.creation_date, m.modification_date
from MRK_Marker m, markers mm, ACC_Accession a
where mm.symbol = m.symbol
and mm._organism_key = m._organism_key
and m._marker_key = a._object_key
and a._mgitype_key = 2
and a._logicaldb_key = 55
order by _organism_key, symbol, _marker_key
;

EOSQL

