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

date | tee -a ${LOG}
echo "--- Run IMPC Rollup Load ---" | tee -a ${LOG}
${ROLLUPLOAD}/bin/rollupload.sh

echo "--- Done running Rollup Load ---" | tee -a ${LOG}

###--------------------------------------------------------------###
###--- run cache loads       	      	                      ---###
###--------------------------------------------------------------###
date | tee -a ${LOG}
echo 'Allele combination cache' | tee -a ${LOG}
${ALLCACHELOAD}/allelecombination.csh

###-----------------------###
###--- final datestamp ---###
###-----------------------###

date | tee -a ${LOG}
echo "--- Finished" | tee -a ${LOG}
