#!/bin/csh -f

#
# obsolete/BIB_DataSet tables
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
drop table mgd.BIB_DataSet_Assoc CASCADE;
drop table mgd.BIB_DataSet CASCADE;
EOSQL

