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

select authors, _primary, title
from BIB_Refs
where _primary = 'None'
;

update BIB_Refs
set authors = null, _primary = null
where _primary = 'None'
;

select authors, _primary, title
from BIB_Refs
where _primary = 'None'
;

select authors, _primary, title
from BIB_Refs
where _primary is null
;

EOSQL

date |tee -a $LOG

