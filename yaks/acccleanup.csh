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

elect distinct a._mgitype_key, a._logicaldb_key, l.name, a.private
from acc_accession a, acc_logicaldb l
where a._logicaldb_key = l._logicaldb_key
and a.private = 0
and exists (select 1 from acc_accession b where a._mgitype_key = b._mgitype_key and a._logicaldb_key = b._logicaldb_key and b.private = 1)
order by a._mgitype_key, a._logicaldb_key
;


-- 4  | RatMap
-- 47 | Rat Genome Database
update acc_accession set private = 0 where _logicaldb_key in (4,47) and private = 1;
update acc_accession set private = 0 where _logicaldb_key in (9) and private = 1;
-- 13 27 11 12 13 20 28

EOSQL

date |tee -a $LOG

