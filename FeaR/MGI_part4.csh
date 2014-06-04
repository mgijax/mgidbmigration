#!/bin/csh -fx

#
# Migration for  FeaR
# (part 4 running reports)
#

###----------------------###
###--- initialization ---###
###----------------------###

cd `dirname $0` && source ../Configuration
setenv CWD `pwd`        # current working directory
echo "Server: ${MGD_DBSERVER}"
echo "Database: ${MGD_DBNAME}"

# start a new log file for this migration, and add a datestamp

setenv LOG $0.log.$$
rm -rf ${LOG}
touch ${LOG}

###------------------------------###
###--- MGI Marker feed report ---###
###------------------------------###

date | tee -a ${LOG}
echo 'MGI Marker feed report' | tee -a ${LOG}
${PUBRPTS}/mgimarkerfeed/mgimarkerfeed_reports.csh

###----------------------###
###--- Public reports ---###
###----------------------###

date | tee -a ${LOG}
echo 'Public Reports' | tee -a ${LOG}
${PUBRPTS}/run_daily_sybase.csh

date | tee -a ${LOG}
echo 'Public Reports' | tee -a ${LOG}
${PUBRPTS}/run_weekly_sybase.csh

date | tee -a ${LOG}
echo 'Public Reports' | tee -a ${LOG}
${PUBRPTS}/run_weekly_postgres.csh >>& ${LOG}

###-----------------------###
###--- final datestamp ---###
###-----------------------###

date | tee -a ${LOG}
echo "--- Finished" | tee -a ${LOG}
