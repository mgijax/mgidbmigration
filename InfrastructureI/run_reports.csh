#!/bin/csh -fx

#
# Run public reports
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
# run all public reports
#

date | tee -a ${LOG}

echo '---run sybase daily reports' | tee -a ${LOG}
${PUBRPTS}/run_daily_sybase.csh

echo '---run sybase weekly reports' | tee -a ${LOG}
${PUBRPTS}/run_weekly_sybase.csh

echo '---run postgres weekly reports' | tee -a ${LOG}
${PUBRPTS}/run_weekly_postgres.csh

echo '---run on demand reports' | tee -a ${LOG}
${PUBRPTS}/ondemand_reports.csh

echo '---run mgimarkerfeed report' | tee -a ${LOG}
${PUBRPTS}/mgimarkerfeed/mgimarkerfeed_reports.csh

date | tee -a ${LOG}
