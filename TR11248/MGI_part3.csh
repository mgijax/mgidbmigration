#!/bin/csh -fx

#
# Migration for TR11248
# (part 3 running reports)
#
# 1. run qc/public reports
#

###----------------------###
###--- initialization ---###
###----------------------###

if ( ${?MGICONFIG} == 0 ) then
        setenv MGICONFIG /usr/local/mgi/test/mgiconfig
endif

source ${MGICONFIG}/master.config.csh

# start a new log file for this migration, and add a datestamp

setenv LOG $0.log.$$
rm -rf ${LOG}
touch ${LOG}

date | tee -a ${LOG}

date | tee -a ${LOG}
echo 'QC Reports' | tee -a ${LOG}
${QCRPTS}/qcnightly_reports.csh

date | tee -a ${LOG}
echo 'QC Reports' | tee -a ${LOG}
${QCRPTS}/qcmonthly_reports.csh

# this must run before the generateGIAAssoc.csh script
# which depends on GIA_???.py reports
date | tee -a ${LOG}
echo 'QC Reports' | tee -a ${LOG}
${QCRPTS}/qcweekly_reports.csh

date | tee -a ${LOG}
echo 'Daily Public Reports' | tee -a ${LOG}
${PUBRPTS}/nightly_reports.csh

date | tee -a ${LOG}
echo 'Weekly Public Reports' | tee -a ${LOG}
${PUBRPTS}/weekly_reports.csh

###-----------------------###
###--- final datestamp ---###
###-----------------------###
date | tee -a ${LOG}
echo "--- Finished" | tee -a ${LOG}

