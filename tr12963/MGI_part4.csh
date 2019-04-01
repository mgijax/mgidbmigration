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

echo 'MGD_DBNAME='$MGD_DBNAME | tee -a $LOG || exit 1
echo 'MGD_DBPASSWORDFILE='$MGD_DBPASSWORDFILE | tee -a $LOG || exit 1
echo 'MGD_DBSERVER='$MGD_DBSERVER | tee -a $LOG || exit 1
echo 'MGD_DBUSER='$MGD_DBUSER | tee -a $LOG || exit 1

# remove reports
#date | tee -a ${LOG}
#echo 'remove existing report outputs' | tee -a ${LOG}
#rm -rf ${PUBREPORTDIR}/output/* | tee -a ${LOG}
#rm -rf ${QCREPORTDIR}/output/* | tee -a ${LOG}

###------------------------------###
###--- MGI Marker feed report ---###
###------------------------------###
#date | tee -a ${LOG}
#echo 'MGI Marker feed report' | tee -a ${LOG}
#${PUBRPTS}/mgimarkerfeed/mgimarkerfeed_reports.csh

###----------------------###
###--- Public reports ---###
###----------------------###
#date | tee -a ${LOG}
#echo 'Public Reports' | tee -a ${LOG}
#${PUBRPTS}/run_daily.csh

###----------------------###
###---   QC reports   ---###
###----------------------###
#date | tee -a ${LOG}
#echo 'Nightly QC Reports' | tee -a ${LOG}
#${QCRPTS}/qcnightly_reports.csh

#date | tee -a ${LOG}
#echo 'Weekly QC Reports' | tee -a ${LOG}
#${QCRPTS}/qcweekly_reports.csh

#date | tee -a ${LOG}
#echo 'Sunday QC Reports' | tee -a ${LOG}
#${QCRPTS}/qcsunday_reports.csh

#date | tee -a ${LOG}
#echo 'Monthly QC Reports' | tee -a ${LOG}
#${QCRPTS}/qcmonthly_reports.csh

date | tee -a ${LOG}
echo 'QC Reports' | tee -a ${LOG}
#obsolete reports
rm -rf ${QCREPORTDIR}/output/WF_AP_NewAlleleNomenTag.rpt | tee -a ${LOG}
rm -rf ${QCREPORTDIR}/output/GXD_EarlyPapers.rpt | tee -a ${LOG}
cd ${QCRPTS}
source ./Configuration
rm -rf ${QCREPORTDIR}/output/WF_AP_NewDiseaseModelTag.rpt
cd mgd
./WF_AP_NewAlleleNomenTag.py    | tee -a ${LOG}
./WF_AP_Routed.py               | tee -a ${LOG}
./WF_SupplementalData.py        | tee -a ${LOG}
cd ../monthly
./WF_AP_Discard.py        	| tee -a ${LOG}
${QCRPTS}/reports.csh BIB_MissingPDFs.sql ${QCOUTPUTDIR}/BIB_MissingPDFs.rpt ${PG_DBSERVER} ${PG_DBNAME}
cd ../weekly
./WF_GXD_secondary.py     	| tee -a ${LOG}
${QCRPTS}/reports.csh GXD_References.sql ${QCOUTPUTDIR}/GXD_References.rpt ${PG_DBSERVER} ${PG_DBNAME}
${QCRPTS}/reports.csh GXD_Triage.sql ${QCOUTPUTDIR}/GXD_Triage.rpt ${PG_DBSERVER} ${PG_DBNAME}

date | tee -a ${LOG}
echo '--- finished part 4' | tee -a $LOG
