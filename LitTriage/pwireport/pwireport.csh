#!/bin/csh -f

#
# migration of PWI_Report.bcp
# dumpTableData.csh mgi-testdb4 scrumdog mgd PWI_Report /home/lec/mgi/dbutils/mgidbmigration/LitTriage/pwireport/PWI_Report.bcp "|"
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

${PG_MGD_DBSCHEMADIR}/table/PWI_Report_drop.object | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/table/PWI_Report_create.object | tee -a $LOG

setenv COLDELIM "|"
setenv LINEDELIM  "\n"

${PG_DBUTILS}/bin/bcpin.csh ${PG_DBSERVER} ${PG_DBNAME} PWI_Report ${DBUTILS}/mgidbmigration/LitTriage/pwireport PWI_Report.bcp ${COLDELIM} ${LINEDELIM} mgd | tee -a ${LOG}

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG
ALTER TABLE PWI_Report ALTER id SET DEFAULT NEXTVAL('pwi_report_id_seq');
select * from PWI_Report;
EOSQL

${PG_MGD_DBSCHEMADIR}/key/PWI_drop.logical | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/key/PWI_create.logical | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/index/PWI_drop.logical | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/index/PWI_create.logical | tee -a $LOG

