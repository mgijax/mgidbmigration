#!/bin/csh -f

#
# migration of PWI_Report.bcp
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
delete from PWI_Report where id >= 12;
EOSQL

setenv COLDELIM "|"
setenv LINEDELIM  "\n"

${PG_DBUTILS}/bin/bcpin.csh ${PG_DBSERVER} ${PG_DBNAME} PWI_Report ${DBUTILS}/mgidbmigration/LitTriage/pwireport PWI_Report.bcp ${COLDELIM} ${LINEDELIM} mgd | tee -a ${LOG}

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG
select * from PWI_Report where id >= 12;
EOSQL
