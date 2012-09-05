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

# 9/5/ - sc Added this temporarily because the backup of part1 is missing the defaults
date | tee -a ${LOG}
echo "--- Bind defaults for MRK_Location_Cache" | tee -a ${LOG}

${MGD_DBSCHEMADIR}/default/MRK_Location_Cache_bind.object

###-------------------------------------------------------------------------###
### Broadcast the build 38 novel genes.  The broadcast script also runs the
### mapping load using the input file created by the initial nomen load.
###-------------------------------------------------------------------------###
date | tee -a ${LOG}
echo 'Running Nomen Broadcast' | tee -a ${LOG}
./broadcast.csh | tee -a ${LOG}

###--------------------------------------------------------------###
###--- run loads                                              ---###
###--------------------------------------------------------------###

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
echo 'EntrezGene Data Provider Load' | tee -a ${LOG}
${ENTREZGENELOAD}/loadFiles.csh

date | tee -a ${LOG}
echo 'Mouse EntrezGene Load' | tee -a ${LOG}
${EGLOAD}/bin/egload.sh

date | tee -a ${LOG}
echo 'UniProt Load' | tee -a ${LOG}
${UNIPROTLOAD}/bin/uniprotload.sh

# QTL load goes here

#date | tee -a ${LOG}
#echo 'Marker Coordinate Load' | tee -a ${LOG}
#${MRKCOORDLOAD}/bin/mrkcoordload.sh

# gene trap  load goes here w/o cacheloads and alomrkload

# Old TIGM migration goes here

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

#date | tee -a ${LOG}
#echo "Run ALO Marker Association Load" | tee -a ${LOG}
#${ALOMRKLOAD}/bin/alomrkload.sh

#date | tee -a ${LOG}
#echo 'Run SNP Marker Load ' | tee -a ${LOG}
#${SNPCACHELOAD}/snpmarker.sh

date | tee -a ${LOG}
echo 'Running C4AM sanity checks' | tee -a ${LOG}
./C4aM_sanity.py /mgi/all/wts_projects/7100/7106/loads/C4AM_Sprint1_input.txt > ./C4aM_sanity.out

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
