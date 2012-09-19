#!/bin/csh -fx

#
# Migration for C4AM -- 
# (part 2 running loads)
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
###--- run loads                                              ---###
###--------------------------------------------------------------###

date | tee -a ${LOG}
echo 'Load MCV Annotations' | tee -a ${LOG}
${MCVLOAD}/bin/mcvload.sh

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
${MGI_DBUTILS}/bin/mgi_backup_to_disk.csh ${MGD_DBSERVER} "${MGD_DBNAME} ${RADAR_DBNAME}" sprint6_US154


###-----------------------###
###--- final datestamp ---###
###-----------------------###

date | tee -a ${LOG}
echo "--- Finished" | tee -a ${LOG}
