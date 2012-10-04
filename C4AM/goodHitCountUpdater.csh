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

echo 'running good hit count updater' | tee -a $LOG
${DBUTILS}/mgidbmigration/C4AM/goodHitCountUpdater.py | tee -a $LOG

date |tee -a $LOG

