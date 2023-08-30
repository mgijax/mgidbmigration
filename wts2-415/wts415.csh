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
 
#$PG_DBUTILS/bin/dumpTableData.csh $PG_DBSERVER $PG_DBNAME mgd MGI_Reference_Assoc $DBUTILS/mgidbmigration/wts2-415/MGI_Reference_Assoc.bcp "|"
#$PG_DBUTILS/bin/dumpTableData.csh $PG_DBSERVER $PG_DBNAME mgd BIB_Workflow_Tag $DBUTILS/mgidbmigration/wts2-415/BIB_Workflow_Tag.bcp "|"

$PYTHON case1.py | tee -a $LOG
$PYTHON case2.py | tee -a $LOG
$PYTHON case3.py | tee -a $LOG

date |tee -a $LOG

