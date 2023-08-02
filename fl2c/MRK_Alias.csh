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

select m1.symbol, m2.symbol, a.*
from MRK_Alias a, MRK_Marker m1, MRK_Marker m2
where a._alias_key  = m1._marker_key
and a._marker_key = m2._marker_key
;

EOSQL

date |tee -a $LOG

