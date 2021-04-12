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
${ROLLUPLOAD}/bin/rollupload.sh

date | tee -a ${LOG}
echo 'Load Sequence Cache tables' | tee -a ${LOG}
${SEQCACHELOAD}/seqcoord.csh
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
${MRKCACHELOAD}/mrkdo.csh
${ALLCACHELOAD}/allstrain.csh
${ALLCACHELOAD}/allelecrecache.csh
${MGICACHELOAD}/bibcitation.csh

date | tee -a ${LOG}
echo 'Load SNP/Marker Cache table' | tee -a ${LOG}
# This is running in out of sync mode - we need to remove this
# before Alpha as this generally is run from the public data
# generation pipeline
# REMOVE PRIOR TO ALPHA
${SNPCACHELOAD}/snpmarker.sh

date | tee -a ${LOG}
echo '--- finished part 3' | tee -a $LOG
