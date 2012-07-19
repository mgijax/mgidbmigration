#!/bin/csh -fx

#
# Migration for C4AM -- Sprint 1
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
echo 'Marker Coordinate Load' | tee -a ${LOG}
${MRKCOORDLOAD}/bin/mrkcoordload.sh 

date | tee -a ${LOG}
echo "Run ALO Marker Association Load" | tee -a ${LOG}
${ALOMRKLOAD}/bin/alomrkload.sh

date | tee -a ${LOG}
echo 'Run SNP Marker Load ' | tee -a ${LOG}
${SNPCACHELOAD}/snpmarker.sh 

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

date | tee -a ${LOG}
echo 'Load Genetic Map Tables' | tee -a ${LOG}
# depends on mrklocation cache having been run. This script
# then runs mrklocationi cache again to pick up new cM positions
${GENMAPLOAD}/bin/genmapload.sh

date | tee -a ${LOG}
echo 'Running C4AM sanity checks' | tee -a ${LOG}
./C4aM_sanity.py /mgi/all/wts_projects/7100/7106/loads/C4AM_Sprint1_input.txt > ./C4aM_sanity.out

date | tee -a ${LOG}

###-----------------------###
###--- final datestamp ---###
###-----------------------###

date | tee -a ${LOG}
echo "--- Finished" | tee -a ${LOG}
