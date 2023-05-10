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
select count(*) from acc_accession where _logicaldb_key = 38;
EOSQL

${PYTHON} mmrrc.py | tee -a $LOG

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG

select count(*) from acc_accession where _logicaldb_key = 38 and accid like 'MMRRC:%-%';

select s.strain, a.accid 
from acc_accession a, prb_strain s
where a._logicaldb_key = 38 and a.accid not like 'MMRRC:%-%'
and a._object_key = s._strain_key
order by a.accid
;

EOSQL

date |tee -a $LOG

