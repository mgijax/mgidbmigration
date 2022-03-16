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

echo "running pubmed property delete script" | tee -a $LOG 
${PYTHON} "${DBUTILS}/mgidbmigration/wts2-815/prop_delete.py" # >> $LOG

date | tee -a $LOG
