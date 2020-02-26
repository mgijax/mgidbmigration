#!/bin/csh -fx

#
# (part 2 - run loads)
#
# BEFORE adding a call to a load:
# . Delete any "lastrun" files that may exist in the "input" directory
# . Copy any new /data/downloads files OR run mirror_wget package, if necessary
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
echo '--- starting test_rnaseq.csh' | tee -a $LOG

echo 'MGD_DBNAME='$MGD_DBNAME | tee -a $LOG || exit 1
echo 'MGD_DBPASSWORDFILE='$MGD_DBPASSWORDFILE | tee -a $LOG || exit 1
echo 'MGD_DBSERVER='$MGD_DBSERVER | tee -a $LOG || exit 1
echo 'MGD_DBUSER='$MGD_DBUSER | tee -a $LOG || exit 1

date | tee -a ${LOG}
echo 'Run RNA Seq load Prep Script' | tee -a $LOG
./test_rnaseqPrep.csh | tee -a $LOG  || exit 1

date | tee -a ${LOG}
echo 'RNA Seq load' | tee -a $LOG
${RNASEQLOAD}/bin/test_rnaseqload.sh | tee -a $LOG

date | tee -a ${LOG}
echo '--- finished test_rnaseq.csh' | tee -a ${LOG}
