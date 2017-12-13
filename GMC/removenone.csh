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

select c.mgiID, a.authors, a._primary, a.title
from BIB_Refs a, BIB_Citation_Cache c
where a._primary = 'None'
and a._Refs_key = c._Refs_key
;

update BIB_Refs
set authors = null, _primary = null
where _primary = 'None'
;

select c.mgiID, a.authors, a._primary, a.title
from BIB_Refs a, BIB_Citation_Cache c
where a._primary = 'None'
and a._Refs_key = c._Refs_key
;

select c.mgiID, a.authors, a._primary, a.title
from BIB_Refs a, BIB_Citation_Cache c
where a._primary is null
and a._Refs_key = c._Refs_key
;

EOSQL

date |tee -a $LOG

