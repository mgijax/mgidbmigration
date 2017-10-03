#!/bin/csh -fx

#
# TR12250/Literature Triage
#
# (part 5 - run littriageload, pub2geneload, qc reports)
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
echo '--- starting part 2' | tee -a $LOG

echo 'MGD_DBNAME='$MGD_DBNAME | tee -a $LOG || exit 1
echo 'MGD_DBPASSWORDFILE='$MGD_DBPASSWORDFILE | tee -a $LOG || exit 1
echo 'MGD_DBSERVER='$MGD_DBSERVER | tee -a $LOG || exit 1
echo 'MGD_DBUSER='$MGD_DBUSER | tee -a $LOG || exit 1

#
# littriageload
#
date | tee -a ${LOG}
echo 'running littriageload' | tee -a $LOG
${LITTRIAGELOAD}/bin/littriageload.sh | tee -a $LOG || exit 1

#
# pubmed2geneload
#
date | tee -a ${LOG}
echo 'running pubmed2geneload' | tee -a $LOG
${PUBMED2GENELOAD}/bin/pubmed2geneload.sh | tee -a $LOG || exit 1

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
echo '--- finished part 5' | tee -a ${LOG}
