#!/bin/csh -fx

#
# TR12550/Literature Triage
#
# (part 4 running reports)
#

###----------------------###
###--- initialization ---###
###----------------------###

if ( ${?MGICONFIG} == 0 ) then
        setenv MGICONFIG /usr/local/mgi/live/mgiconfig
endif

source ${MGICONFIG}/master.config.csh

setenv LOG $0.log
rm -rf ${LOG}
touch ${LOG}

date | tee -a ${LOG}
echo '--- starting part 4' | tee -a $LOG

echo 'MGD_DBNAME='$MGD_DBNAME | text -a $LOG || exit 1
echo 'MGD_DBPASSWORDFILE='$MGD_DBPASSWORDFILE | text -a $LOG || exit 1
echo 'MGD_DBSERVER='$MGD_DBSERVER | text -a $LOG || exit 1
echo 'MGD_DBUSER='$MGD_DBUSER | text -a $LOG || exit 1

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
${PUBRPTS}/run_daily.csh

###----------------------###
###---   QC reports   ---###
###----------------------###
date | tee -a ${LOG}
echo 'Nightly QC Reports' | tee -a ${LOG}
${QCRPTS}/qcnightly_reports.csh

date | tee -a ${LOG}
echo 'Weekly QC Reports' | tee -a ${LOG}
${QCRPTS}/qcweekly_reports.csh

date | tee -a ${LOG}
echo 'Sunday QC Reports' | tee -a ${LOG}
${QCRPTS}/qcsunday_reports.csh

date | tee -a ${LOG}
echo 'Monthly QC Reports' | tee -a ${LOG}
${QCRPTS}/qcmonthly_reports.csh

date | tee -a ${LOG}
echo '--- finished part 4' | tee -a $LOG
