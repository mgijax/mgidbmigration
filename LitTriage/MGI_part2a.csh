#!/bin/csh -fx

#
# TR12250/Literature Triage
#
# (part 2a - run loads)
#

###----------------------###
###--- initialization ---###
###----------------------###

if ( ${?MGICONFIG} == 0 ) then
        setenv MGICONFIG /usr/local/mgi/live/mgiconfig
endif

source ${MGICONFIG}/master.config.csh

setenv LOG $0.log
rm -rf ${LOG}
touch ${LOG}

date | tee -a ${LOG}
echo '--- starting part 2' | tee -a $LOG

echo 'MGD_DBNAME='$MGD_DBNAME | tee -a $LOG || exit 1
echo 'MGD_DBPASSWORDFILE='$MGD_DBPASSWORDFILE | tee -a $LOG || exit 1
echo 'MGD_DBSERVER='$MGD_DBSERVER | tee -a $LOG || exit 1
echo 'MGD_DBUSER='$MGD_DBUSER | tee -a $LOG || exit 1

#
# jfilescanner/pdfs will be run manually as a separate process
#
date | tee -a ${LOG}
echo 'running jfilescanner3 migration/load BIB_Workflow_Data from /backups/build/BIB_Workflow_Data.dump' | tee -a $LOG
cd jfilescanner
./jfilescanner3.csh | tee -a $LOG || exit 1
cd ..

date | tee -a ${LOG}
echo '--- finished part 2' | tee -a ${LOG}
