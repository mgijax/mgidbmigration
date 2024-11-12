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

update mgi_user set _userstatus_key = 316351 where _user_key = 1014;
update mgi_user set _userstatus_key = 316351 where _user_key = 1069;

select * from mgi_user order by name limit 1;

select _user_key, _usertype_key, _userstatus_key, name from mgi_user order by _userstatus_key, _usertype_key, name;

EOSQL

date |tee -a $LOG

