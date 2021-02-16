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

WITH jr AS (
select _object_key from acc_accession where _mgitype_key = 10 and _logicaldb_key = 22 group by _object_key having count(*) > 1
)
select s._strain_key, s.strain, a.accID, a.creation_date
from jr, prb_strain s, acc_accession a
where jr._object_key = s._strain_key
and jr._object_key = a._object_key
and a._mgitype_key = 10
and a._logicaldb_key = 22
;

WITH mmrrc AS (
select _object_key from acc_accession where _mgitype_key = 10 and _logicaldb_key = 38 group by _object_key having count(*) > 1
)
select s._strain_key, s.strain, a.accID, a.creation_date
from mmrrc, prb_strain s, acc_accession a
where mmrrc._object_key = s._strain_key
and mmrrc._object_key = a._object_key
and a._mgitype_key = 10
and a._logicaldb_key = 38
;

EOSQL

date |tee -a $LOG

