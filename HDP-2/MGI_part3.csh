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
echo 'Allele combination cache' | tee -a ${LOG}
${ALLCACHELOAD}/allelecombination.csh

echo 'Updates to statistics' | tee -a ${LOG}
./updateStats.csh

date | tee -a ${LOG}
echo 'Add New Measurements' | tee -a ${LOG}
${MGI_DBUTILS}/bin/addMeasurements.csh

###-----------------------###
###--- final datestamp ---###
###-----------------------###

date | tee -a ${LOG}
echo "--- Finished" | tee -a ${LOG}
