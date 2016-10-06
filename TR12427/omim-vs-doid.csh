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

select a2.accID
from ACC_Accession a1, ACC_Accession a2
where a1._MGIType_key = 13
and a1._LogicalDB_key = 191
and a1._Object_key = a2._Object_key
and a1.preferred = 1
and a2._LogicalDB_key = 15
group by a2.accID having count(*) > 1
order by a2.accID
;

EOSQL

date |tee -a $LOG

