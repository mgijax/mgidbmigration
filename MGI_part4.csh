#!/bin/csh -fx

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

echo 'MGD_DBNAME='$MGD_DBNAME | tee -a $LOG 
echo 'MGD_DBPASSWORDFILE='$MGD_DBPASSWORDFILE | tee -a $LOG 
echo 'MGD_DBSERVER='$MGD_DBSERVER | tee -a $LOG 
echo 'MGD_DBUSER='$MGD_DBUSER | tee -a $LOG 

# remove existing reports
#rm -f ${QCREPORTDIR}/output/* >>& ${LOG}
#rm -f ${PUBREPORTDIR}/output/* >>& ${LOG}

###------------------------------###
###--- MGI Marker feed report ---###
###------------------------------###
date | tee -a ${LOG}
echo 'MGI Marker feed report' | tee -a ${LOG}
${PUBRPTS}/mgimarkerfeed/mgimarkerfeed_reports.csh >>& ${LOG}

###----------------------###
###--- Public reports ---###
###----------------------###
date | tee -a ${LOG}
echo 'Public Reports' | tee -a ${LOG}
${PUBRPTS}/run_daily.csh >>& ${LOG}

###----------------------###
###---   QC reports   ---###
###----------------------###
date | tee -a ${LOG}
echo 'Nightly QC Reports' | tee -a ${LOG}
${QCRPTS}/qcnightly_reports.csh >>& ${LOG}

date | tee -a ${LOG}
echo 'Weekly QC Reports' | tee -a ${LOG}
${QCRPTS}/qcweekly_reports.csh >>& ${LOG}

date | tee -a ${LOG}
echo 'Sunday QC Reports' | tee -a ${LOG}
${QCRPTS}/qcsunday_reports.csh >>& ${LOG}

date | tee -a ${LOG}
echo 'Monthly QC Reports' | tee -a ${LOG}
${QCRPTS}/qcmonthly_reports.csh >>& ${LOG}

date | tee -a ${LOG}
echo '--- finished part 4' | tee -a $LOG
