#!/bin/csh -fx

#
# Migration part 2 for TR7493 -- gene trap LF
#

###----------------------###
###--- initialization ---###
###----------------------###

# start a new log file for this migration, and add a datestamp

setenv LOG $0.log.$$
rm -rf ${LOG}
touch ${LOG}

###--------------------------------------------------------------###
###--- run genetrapload, this runs gtcoordload and alomrkload ---###
###--------------------------------------------------------------###
date | tee -a ${LOG}
echo 'Running Gene Trap Load' | tee -a ${LOG}
${GENETRAPLOAD}/bin/genetrapload.sh

###--------------------------------------------------------------###
###--- run all the cacheloads			              ---###
###--------------------------------------------------------------###
date | tee -a ${LOG}
echo 'Create Dummy Sequences' | tee -a ${LOG}
${SEQCACHELOAD}/seqdummy.csh

date | tee -a ${LOG}
echo 'Load Sequence Cache tables' | tee -a ${LOG}
${SEQCACHELOAD}/seqcoord.csh
${SEQCACHELOAD}/seqmarker.csh
${SEQCACHELOAD}/seqprobe.csh
${SEQCACHELOAD}/seqdescription.csh

date | tee -a ${LOG}
echo 'Load Marker Cache tables' | tee -a ${LOG}
${MRKCACHELOAD}/mrklabel.csh
${MRKCACHELOAD}/mrkref.csh
${MRKCACHELOAD}/mrkhomology.csh
${MRKCACHELOAD}/mrklocation.csh
${MRKCACHELOAD}/mrkomim.csh
${MRKCACHELOAD}/mrkprobe.csh

date | tee -a ${LOG}
echo 'Load Allele Cache tables' | tee -a ${LOG}
${ALLCACHELOAD}/alllabel.csh
${ALLCACHELOAD}/allelecombination.csh

date | tee -a ${LOG}
echo 'Load Image Cache table' | tee -a ${LOG}
${MGICACHELOAD}/imgcache.csh

date | tee -a ${LOG}
echo 'Load Voc Cache tables' | tee -a ${LOG}
${MGICACHELOAD}/voccounts.csh
${MGICACHELOAD}/vocmarker.csh

###-----------------------###
###--- final datestamp ---###
###-----------------------###

date | tee -a ${LOG}
echo "--- Finished" | tee -a ${LOG}
