#!/bin/csh -fx

#
# TR12250/Literature Triage
#
# (part 3 running cache loads)
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
echo '--- starting part 3' | tee -a $LOG

echo 'MGD_DBNAME='$MGD_DBNAME | tee -a $LOG || exit 1
echo 'MGD_DBPASSWORDFILE='$MGD_DBPASSWORDFILE | tee -a $LOG || exit 1
echo 'MGD_DBSERVER='$MGD_DBSERVER | tee -a $LOG || exit 1
echo 'MGD_DBUSER='$MGD_DBUSER | tee -a $LOG || exit 1

###--------------------------------------------------------------###
###--- run cache loads       	      	                      ---###
###--------------------------------------------------------------###
#
# comment out if not needed
#
date | tee -a ${LOG}
echo 'Run Rollup Load' | tee -a ${LOG}
${ROLLUPLOAD}/bin/rollupload.sh

date | tee -a ${LOG}
echo 'Load Sequence Cache tables' | tee -a ${LOG}
${SEQCACHELOAD}/seqdummy.csh
${SEQCACHELOAD}/seqmarker.csh
${SEQCACHELOAD}/seqprobe.csh

date | tee -a ${LOG}
echo 'Load Marker/Allele Cache tables' | tee -a ${LOG}
${MRKCACHELOAD}/mrklabel.csh
${MRKCACHELOAD}/mrkref.csh
${MRKCACHELOAD}/mrklocation.csh
${MRKCACHELOAD}/mrkprobe.csh
${MRKCACHELOAD}/mrkmcv.csh
${ALOMRKLOAD}/bin/alomrkload.sh
${ALLCACHELOAD}/alllabel.csh
${ALLCACHELOAD}/allelecombination.csh
${MRKCACHELOAD}/mrkomim.csh
${ALLCACHELOAD}/allstrain.csh
${ALLCACHELOAD}/allelecrecache.csh
${MGICACHELOAD}/bibcitation.csh

date | tee -a ${LOG}
echo '--- finished part 3' | tee -a $LOG
