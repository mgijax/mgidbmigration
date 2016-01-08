#!/bin/csh -fx

#
# Migration for TR12223
#

###----------------------###
###--- initialization ---###
###----------------------###

if ( ${?MGICONFIG} == 0 ) then
	setenv MGICONFIG /usr/local/mgi/live/mgiconfig
endif

source ${MGICONFIG}/master.config.csh

# start a new log file for this migration, and add a datestamp

setenv LOG $0.log
rm -rf ${LOG}
touch ${LOG}

echo 'run qc reports' | tee -a $LOG

${QCRPTS}/qcnightly_reports.csh | tee -a $LOG
${QCRPTS}/qcmonthly_reports.csh | tee -a $LOG
${QCRPTS}/qcweekly_reports.csh | tee -a $LOG
${QCRPTS}/qcsunday_reports.csh | tee -a $LOG

date | tee -a ${LOG}
echo "--- Finished" | tee -a ${LOG}

