#!/bin/csh -fx

#
# Migration for N2MO
# (part 3 running cache loads )
#

###----------------------###
###--- initialization ---###
###----------------------###

cd `dirname $0` && source ../Configuration
echo "Server: ${MGD_DBSERVER}"
echo "Database: ${MGD_DBNAME}"

# start a new log file for this migration, and add a datestamp

setenv LOG $0.log.$$
rm -rf ${LOG}
touch ${LOG}

###--------------------------------------------------------------###
###--- run cache loads       	      	                      ---###
###--------------------------------------------------------------###
date | tee -a ${LOG}
echo 'Load Sequence Cache tables' | tee -a ${LOG}
${SEQCACHELOAD}/seqdummy.csh
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
${MRKCACHELOAD}/mrkprobe.csh
${MRKCACHELOAD}/mrkmcv.csh
${MRKCACHELOAD}/mrkomim.csh

date | tee -a ${LOG}
echo 'Load Voc/Count Cache Table' | tee -a ${LOG}
${MGICACHELOAD}/voccounts.csh

echo 'Load Voc/Marker Cache Table' | tee -a ${LOG}
${MGICACHELOAD}/vocmarker.csh

echo 'Load Voc/Allele Cache Table' | tee -a ${LOG}
${MGICACHELOAD}/vocallele.csh

echo 'Updates to statistics' | tee -a ${LOG
./updateStats.csh

date | tee -a ${LOG}
echo 'Add New Measurements' | tee -a ${LOG}
${MGI_DBUTILS}/bin/addMeasurements.csh

###-----------------------###
###--- final datestamp ---###
###-----------------------###

date | tee -a ${LOG}
echo "--- Finished" | tee -a ${LOG}
