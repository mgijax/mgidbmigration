#!/bin/csh -fx

#
# Migration for HDP-2
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
echo "--- Run Roll Up cache load ---" | tee -a ${LOG}
${ROLLUPLOAD}/bin/rollupload.sh

date | tee -a ${LOG}
echo "--- Run Marker Label cache ---" | tee -a ${LOG}
${MRKCACHELOAD}/mrklabel.csh

date | tee -a ${LOG}
echo "--- Run Marker Reference cache ---" | tee -a ${LOG}
${MRKCACHELOAD}/mrkref.csh

date | tee -a ${LOG}
echo "--- Run Marker OMIM cache ---" | tee -a ${LOG}
${MRKCACHELOAD}/mrkomim.csh

date | tee -a ${LOG}
echo "--- Inferred From cache ---" | tee -a ${LOG}
${MGICACHELOAD}/inferredrom.csh

###-----------------------###
###--- final datestamp ---###
###-----------------------###

date | tee -a ${LOG}
echo "--- Finished" | tee -a ${LOG}
