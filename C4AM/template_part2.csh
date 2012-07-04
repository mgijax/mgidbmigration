#!/bin/csh -fx

#
# Migration for C4AM -- Sprint ????
# (part 2 running loads)
#

###----------------------###
###--- initialization ---###
###----------------------###

cd `dirname $0` && source ../Configuration
setenv CWD `pwd`        # current working directory
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
echo 'MCV Vocabulary Load' | tee -a ${LOG}
${MCVLOAD}/bin/run_mcv_vocload.sh

date | tee -a ${LOG}
echo 'MCV Annotation Load' | tee -a ${LOG}
${MCVLOAD}/bin/mcvload.sh

date | tee -a ${LOG}
echo 'Marker Coordinate Load' | tee -a ${LOG}
${MRKCOORDLOAD}/bin/mrkcoordload.sh 

date | tee -a ${LOG}
echo 'Run Ensembl Gene Model/Association Load' | tee -a ${LOG}
${GENEMODELLOAD}/bin/genemodelload.sh ensembl

date | tee -a ${LOG}
echo 'Run NCBI Gene Model/Association Load' | tee -a ${LOG}
${GENEMODELLOAD}/bin/genemodelload.sh ncbi

date | tee -a ${LOG}
echo 'Run VEGA Gene Model/Association Load' | tee -a ${LOG}
${GENEMODELLOAD}/bin/genemodelload.sh vega

date | tee -a ${LOG}
echo "Run ALO Marker Association Load" | tee -a ${LOG}
${ALOMRKLOAD}/bin/alomrkload.sh

date | tee -a ${LOG}
echo 'Run SNP Marker Load ' | tee -a ${LOG}
${SNPCACHELOAD}/snpmarker.sh 

exit 0

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

###-----------------------###
###--- final datestamp ---###
###-----------------------###

date | tee -a ${LOG}
echo "--- Finished" | tee -a ${LOG}
