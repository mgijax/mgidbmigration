#!/bin/csh -fx

#
# Migration for C4AM --  Sprint ????
# (part 3 running reports)
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

###------------------###
###--- QC reports ---###
###------------------###

date | tee -a ${LOG}
echo 'QC Reports' | tee -a ${LOG}
${QCRPTS}/qcnightly_reports.sh

date | tee -a ${LOG}
echo 'QC Reports' | tee -a ${LOG}
${QCRPTS}/qcweekly_reports.sh

date | tee -a ${LOG}
echo 'QC Reports' | tee -a ${LOG}
${QCRPTS}/qcmonthly_reports.sh

###----------------------###
###--- Public reports ---###
###----------------------###

date | tee -a ${LOG}
echo 'Public Reports' | tee -a ${LOG}
${PUBRPTS}/nightly_reports.sh

date | tee -a ${LOG}
echo 'Public Reports' | tee -a ${LOG}
${PUBRPTS}/weekly_reports.sh

date | tee -a ${LOG}
echo 'Public Reports' | tee -a ${LOG}
${PUBRPTS}/monthly_reports.sh

###-----------------------###
###--- final datestamp ---###
###-----------------------###

date | tee -a ${LOG}
echo "--- Finished" | tee -a ${LOG}
