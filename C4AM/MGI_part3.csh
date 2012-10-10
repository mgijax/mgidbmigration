#!/bin/csh -fx

#
# Migration for C4AM/B38
# (part 3 running cache loads & additional loads)
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

# removed genmapload

date | tee -a ${LOG}
echo "Run ALO Marker Association Load" | tee -a ${LOG}
${ALOMRKLOAD}/bin/alomrkload.sh

date | tee -a ${LOG}
echo 'Run SNP Marker Load ' | tee -a ${LOG}
${SNPCACHELOAD}/snpmarker.sh

date | tee -a ${LOG}
echo 'Running C4AM sanity checks' | tee -a ${LOG}
./C4aM_sanity.py /mgi/all/wts_projects/7100/7106/loads/C4AM_input.txt > ./C4aM_sanity.out

# run mini  home page measurements here

#
# Backup databases.
#
date | tee -a ${LOG}
echo 'Backup mgd/radar databases'
${MGI_DBUTILS}/bin/mgi_backup_to_disk.csh ${MGD_DBSERVER} "${MGD_DBNAME} ${RADAR_DBNAME}" Build38

###-----------------------###
###--- final datestamp ---###
###-----------------------###

date | tee -a ${LOG}
echo "--- Finished" | tee -a ${LOG}
