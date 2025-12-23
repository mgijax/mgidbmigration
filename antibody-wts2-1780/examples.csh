#!/bin/csh -f

#
# Template
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

-- antibody with > 5 references
WITH refs AS (
select _object_key from mgi_reference_assoc where _mgitype_key = 6 group by _object_key having count(*) > 5
)
select a.antibodyName
from gxd_antibody a, refs b
where b._object_key = a._antibody_key
order by a.antibodyName
;

-- antibody with > 5 aliases
WITH alias AS (
select _antibody_key from gxd_antibodyalias group by _antibody_key having count(*) > 4
)
select a.antibodyName
from gxd_antibody a, alias b
where b._antibody_key = a._antibody_key
order by a.antibodyName
;

EOSQL

date |tee -a $LOG

