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

select a._Antibody_key, 
        a.antibodyName,
        b.antigenName
from GXD_Antibody a, GXD_Antigen b
where a._Antigen_key = b._Antigen_key
order by a.antibodyName
;

EOSQL

