#!/bin/csh -fx

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

date | tee -a ${LOG}
echo 'VEGA Gene Model Load' | tee -a ${LOG}
${GENEMODELLOAD}/bin/genemodelload.sh vega

date | tee -a ${LOG}
echo 'Ensembl Gene Model Load' | tee -a ${LOG}
${GENEMODELLOAD}/bin/genemodelload.sh ncbi

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

#
# Backup databases.
#
date | tee -a ${LOG}
echo 'Backup mgd/radar databases'
${MGI_DBUTILS}/bin/mgi_backup_to_disk.csh ${MGD_DBSERVER} "${MGD_DBNAME} ${RADAR_DBNAME}" sprint6_US160_US159

###-----------------------###
###--- final datestamp ---###
###-----------------------###

date | tee -a ${LOG}
echo "--- Finished" | tee -a ${LOG}
