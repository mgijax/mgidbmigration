#!/bin/csh -fx

#
# Migration part 2 for TR10805
#

###----------------------###
###--- initialization ---###
###----------------------###

source ../Configuration

# start a new log file for this migration, and add a datestamp

setenv LOG $0.log.$$
rm -rf ${LOG}
touch ${LOG}

date | tee -a ${LOG}
echo 'Map View load (will run marker location cache)' | tee -a ${LOG}
${MAPVIEWLOAD}/bin/mapviewload.sh true

date | tee -a ${LOG}
echo 'ALO Marker load' | tee -a ${LOG}
${ALOMRKLOAD}/bin/alomrkload.sh

date | tee -a ${LOG}
echo 'GOA/Mouse load' | tee -a ${LOG}
${GOALOAD}/bin/goa.csh

date | tee -a ${LOG}
echo 'DOI update' | tee -a ${LOG}
/mgi/all/wts_projects/10700/10725/doiload.sh

date | tee -a ${LOG}
echo 'GO Stats' | tee -a ${LOG}
source ${QCRPTS}/Configuration
cd ${QCRPTS}/mgd
./GO_stats.py

#date | tee -a ${LOG}
#echo 'SNP Cache load' | tee -a ${LOG}
#${SNPCACHELOAD}/snpmarker.sh

###-----------------------###
###--- final datestamp ---###
###-----------------------###

date | tee -a ${LOG}
echo "--- Finished" | tee -a ${LOG}
