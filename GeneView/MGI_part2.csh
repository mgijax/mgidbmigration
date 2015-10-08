#!/bin/csh -fx

#
# Migration for GeneView project
# (part 2 - run loads)
#
# Products:
#

###----------------------###
###--- initialization ---###
###----------------------###

cd `dirname $0` && source ../Configuration
setenv CWD `pwd`	# current working directory
echo "Server: ${MGD_DBSERVER}"
echo "Database: ${MGD_DBNAME}"

# start a new log file for this migration, and add a datestamp

setenv LOG $0.log.$$
rm -rf ${LOG}
touch ${LOG}
date | tee -a ${LOG}
echo "--- Starting in ${CWD}..." | tee -a ${LOG}

date | tee -a ${LOG}
echo "--- Run EMAP Slim Load ---" | tee -a ${LOG}
${VOCABBREVLOAD}/bin/vaload.sh emapslimload.config
date | tee -a ${LOG}
echo "--- Run GO Slim Load ---" | tee -a ${LOG}
${VOCABBREVLOAD}/bin/vaload.sh goslimload.config

date | tee -a ${LOG}
