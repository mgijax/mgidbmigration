#!/bin/csh -fx

#
# Migration for HIPPO project
# (part 2b - run IMPC htmpload, to pick up new 3i data)
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

#
# must have trunk of htmpload installed to run this load
#
date | tee -a ${LOG}
echo "--- Run IMPC load  ---"  | tee -a ${LOG}
${HTMPLOAD}/bin/htmpload.sh ${HTMPLOAD}/impcmpload.config ${HTMPLOAD}/annotload.config

echo "--- Done running IMPC HTMP Load  ---" | tee -a ${LOG}

date | tee -a ${LOG}
