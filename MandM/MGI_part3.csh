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
echo "--- Run Marker Label cache ---" | tee -a ${LOG}
${MRKCACHELOAD}/mrklabel.csh

###-----------------------###
###--- final datestamp ---###
###-----------------------###

date | tee -a ${LOG}
echo "--- Finished" | tee -a ${LOG}
