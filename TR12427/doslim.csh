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

\echo ''
\echo '--DO_MGI_slim'
\echo ''

select t.term as DOterm, s.label as slimLabel
from MGI_SetMember s, VOC_Term t
where s._Set_key = 1048
and s._object_key = t._Term_key
order by DOterm
;

EOSQL

date |tee -a $LOG

