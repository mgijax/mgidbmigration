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

select * from acc_logicaldb where _logicaldb_key = 168;
select count(*) from acc_accession where _logicaldb_key = 168;
select * from acc_accession where _logicaldb_key = 168;

delete from acc_accession where _logicaldb_key = 168;
delete from acc_logicaldb where _logicaldb_key = 168;

EOSQL

date |tee -a $LOG

