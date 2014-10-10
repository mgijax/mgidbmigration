#!/bin/csh -fx

#
# Migration for HDP-2 project
# (part 2 - run loads)
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

date | tee -a ${LOG}
echo "--- Run IMPC HTMP Load ---" | tee -a ${LOG}

${HTMPLOAD}/bin/htmpload.sh ${HTMPLOAD}/impcmpload.config ${HTMPLOAD}/annotload.config

date | tee -a ${LOG}
echo "--- Run Sanger HTMP Load ---" | tee -a ${LOG}
${HTMPLOAD}/bin/htmpload.sh ${HTMPLOAD}/sangermpload.config ${HTMPLOAD}/annotload.config

date | tee -a ${LOG}
echo "--- Done running HTMP Loads  ---" | tee -a ${LOG}

date | tee -a ${LOG}
