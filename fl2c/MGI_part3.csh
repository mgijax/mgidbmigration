#!/bin/csh -fx

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

echo 'MGD_DBNAME='$MGD_DBNAME | tee -a $LOG 
echo 'MGD_DBPASSWORDFILE='$MGD_DBPASSWORDFILE | tee -a $LOG 
echo 'MGD_DBSERVER='$MGD_DBSERVER | tee -a $LOG 
echo 'MGD_DBUSER='$MGD_DBUSER | tee -a $LOG 

###--------------------------------------------------------------###
###--- run cache loads       	      	                      ---###
###--------------------------------------------------------------###
#
# comment out if not needed
#
date | tee -a ${LOG}
echo 'Run Rollup Load' | tee -a ${LOG}
${ROLLUPLOAD}/bin/rollupload.sh >>& ${LOG}

date | tee -a ${LOG}
echo 'Load Sequence Cache tables' | tee -a ${LOG}
${SEQCACHELOAD}/seqcoord.csh >>& ${LOG}
${SEQCACHELOAD}/seqdummy.csh >>& ${LOG}
${SEQCACHELOAD}/seqmarker.csh >>& ${LOG}
${SEQCACHELOAD}/seqprobe.csh >>& ${LOG}

date | tee -a ${LOG}
echo 'Load Marker/Allele Cache tables' | tee -a ${LOG}
${MRKCACHELOAD}/mrklabel.csh >>& ${LOG}
${MRKCACHELOAD}/mrkref.csh >>& ${LOG}
${MRKCACHELOAD}/mrklocation.csh >>& ${LOG}
${MRKCACHELOAD}/mrkprobe.csh >>& ${LOG}
${MRKCACHELOAD}/mrkmcv.csh >>& ${LOG}
${ALOMRKLOAD}/bin/alomrkload.sh >>& ${LOG}
${ALLCACHELOAD}/alllabel.csh >>& ${LOG}
${ALLCACHELOAD}/allelecombination.csh >>& ${LOG}
${MRKCACHELOAD}/mrkdo.csh >>& ${LOG}
${ALLCACHELOAD}/allstrain.csh >>& ${LOG}
${ALLCACHELOAD}/allelecrecache.csh >>& ${LOG}
${MGICACHELOAD}/bibcitation.csh >>& ${LOG}

date | tee -a ${LOG}
echo '--- finished part 3' | tee -a $LOG
