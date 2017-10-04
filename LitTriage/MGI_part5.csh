#!/bin/csh -fx

#
# TR12250/Literature Triage
#
# (part 5 - run pdfdownload
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
# pdfdownload
#
date | tee -a ${LOG}
echo 'running littriageload' | tee -a $LOG
${PDFDOWNLOAD}/download_plos.sh | tee -a $LOG || exit 1

date | tee -a ${LOG}
echo '--- finished part 5' | tee -a ${LOG}
