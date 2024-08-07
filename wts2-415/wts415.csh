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
 
#${PG_DBUTILS}/bin/dumpTableData.csh ${MGD_DBSERVER} ${MGD_DBNAME} mgd GXD_Genotype ${DBUTILS}/mgidbmigration/wts2-415/GXD_Genotype.bcp "|"

${PYTHON} case1.py | tee -a $LOG
${PYTHON} case2.py | tee -a $LOG
${PYTHON} case3.py | tee -a $LOG

${VOCLOAD}/runOBOIncLoad.sh MP.config | tee -a $LOG
${ROLLUPLOAD}/bin/rollupload.sh | tee -a $LOG

date |tee -a $LOG

