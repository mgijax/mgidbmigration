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
 
./sto106_tag.py | tee -a $LOG
./sto106_status.py | tee -a $LOG

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG
select * from BIB_Workflow_Status where _assoc_key >= 1186911;
select * from BIB_Workflow_Tag where _assoc_key >= 414211;
EOSQL

date |tee -a $LOG

