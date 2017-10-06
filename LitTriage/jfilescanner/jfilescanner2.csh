#!/bin/csh -f

#
# migration of jfilescanner, BIB_Workflow_Data
# 
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

date | tee -a ${LOG}
echo 'migrating jfilescanner pdfs and update BIB_Workflow_Data.hasPDF = 1'
setenv LITPARSER ${MGIUTILS}/litparser
./jfilescanner2.py | tee -a $LOG || exit 1
date | tee -a $LOG

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG
select count(*) from BIB_Workflow_Data;
select count(*) from BIB_Workflow_Data where hasPDF = 0;
select count(*) from BIB_Workflow_Data where hasPDF = 1;
EOSQL
date | tee -a $LOG

#cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG
#select r.jnumID, r.short_citation 
#from BIB_Citation_Cache r, BIB_Workflow_Data d
#where r._Refs_key = d._Refs_key
#and d.hasPDF = 0
#order by r.jnumID
#;
#EOSQL
#date | tee -a $LOG

