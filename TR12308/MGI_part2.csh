#!/bin/csh -fx

#
# Migration for Feature Relationship (FeaR) project
# (part 2 - run fear loads)
#
# Products:
# fearload
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

#date | tee -a ${LOG}
#echo "--- Run mgp load  ---"  | tee -a ${LOG}
#${HTMPLOAD}/bin/htmpload.sh ${HTMPLOAD}/impcmgpload.config  ${HTMPLOAD}/annotload.config

date | tee -a ${LOG}
echo "--- Run europhenome load  ---"  | tee -a ${LOG}
${HTMPLOAD}/bin/htmpload.sh ${HTMPLOAD}/impceurompload.config ${HTMPLOAD}/annotload.config

echo "--- Done running HTMP Loads  ---" | tee -a ${LOG}

date | tee -a ${LOG}
