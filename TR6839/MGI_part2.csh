#!/bin/csh -fx

#
# Migration part 2 for TR6839
#

###----------------------###
###--- initialization ---###
###----------------------###

source ../Configuration

# start a new log file for this migration, and add a datestamp

setenv LOG $0.log.$$
rm -rf ${LOG}
touch ${LOG}

###---------------------------------###
###--- run all Sunday cacheloads ---###
###---------------------------------###
date | tee -a ${LOG}
echo 'Load Marker Cache tables' | tee -a ${LOG}
${MRKCACHELOAD}/mrklabel.csh
${MRKCACHELOAD}/mrkref.csh
${MRKCACHELOAD}/mrkhomology.csh
${MRKCACHELOAD}/mrklocation.csh
${MRKCACHELOAD}/mrkomim.csh
${MRKCACHELOAD}/mrkprobe.csh

date | tee -a ${LOG}
echo 'Load Voc Cache tables' | tee -a ${LOG}
${MGICACHELOAD}/voccounts.csh
${MGICACHELOAD}/vocmarker.csh

date | tee -a ${LOG}
echo 'Run ALO load' | tee -a ${LOG}
${ALOMRKLOAD}/bin/alomrkload.sh

###-----------------------###
###--- final datestamp ---###
###-----------------------###

date | tee -a ${LOG}
echo "--- Finished" | tee -a ${LOG}
