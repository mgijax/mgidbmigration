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

-- duplicate non-mouse that are also in MGI_Relationship EC (1004)
WITH markers AS (
select _organism_key, symbol 
from MRK_Marker 
where _organism_key in (10,11,13,40,63,84,94,95)
group by _organism_key, symbol having count(*) > 1
)
select m._marker_key, m._organism_key, m.symbol, a.accid, m.creation_date, m.modification_date
from markers mm, 
        MRK_Marker m left outer join ACC_Accession a on (
        m._marker_key = a._object_key
        and a._mgitype_key = 2
        and a._logicaldb_key = 55
        )
where mm.symbol = m.symbol
and mm._organism_key = m._organism_key
--and exists (select 1 from MGI_Relationship r where r._category_key = 1004 and r._Object_key_2 = m._Marker_key)
order by _organism_key, symbol, _marker_key
;

WITH markers AS (
select m._organism_key, m.symbol, o.commonname
from MRK_Marker m, MGI_Organism o
where m._organism_key in (10,11,13,40,63,84,94,95)
and m._organism_key = o._organism_key
group by m._organism_key, m.symbol, o.commonname having count(*) > 1
)
select mm._organism_key, mm.commonname, m.symbol, a.accid
from markers mm, 
        MRK_Marker m left outer join ACC_Accession a on (
        m._marker_key = a._object_key
        and a._mgitype_key = 2
        and a._logicaldb_key = 55
        )
where mm.symbol = m.symbol
and mm._organism_key = m._organism_key
group by mm._organism_key, mm.commonname, m.symbol, a.accid having count(*) > 1
order by _organism_key, symbol
;

EOSQL

