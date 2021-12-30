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
    delete from acc_accession where _logicaldb_key = 178 and _mgitype_key = 2
    ;
    delete from MGI_Association where _JobStream_key in (select _JobStream_key from APP_JobStream where jobStreamName = 'genesummaryload')
    ;
    delete from MGI_User where _User_key in (1553, 1554)
    ;
    delete from ACC_ActualDB where _LogicalDB_key = 178
    ;
    delete from ACC_LogicalDB where _LogicalDB_key = 178
    ;

EOSQL

date |tee -a $LOG

