#!/bin/csh -fx

#
# Migration for N2MO
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

###-----------------###
###--- run loads ---###
###-----------------###

date | tee -a ${LOG}
echo 'Load Human Coordinates' | tee -a ${LOG}
${MAPVIEWLOAD}/bin/mapviewload.sh true

# NOTE THIS IS DUMMY DATA FOR TESTING geneticVsGenomic only
# MUST BE REMOVED PRIOR TO RELEASE
date | tee -a ${LOG}
echo 'Marker Coordinate Load' | tee -a ${LOG}
${MRKCOORDLOAD}/bin/mrkcoordload.sh

###-----------------------###
###--- final datestamp ---###
###-----------------------###

date | tee -a ${LOG}
echo "--- Finished" | tee -a ${LOG}
