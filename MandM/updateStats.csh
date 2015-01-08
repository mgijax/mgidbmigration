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

echo 'running homology statistic updater' | tee -a $LOG
${DBUTILS}/mgidbmigration/MandM/updateStats.py | tee -a $LOG

date |tee -a $LOG

