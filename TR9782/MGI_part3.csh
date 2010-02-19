#!/bin/csh -fx

#
# Migration part 3 for TR9782 -- MGI 4.33
#

###----------------------###
###--- initialization ---###
###----------------------###

source ../Configuration

# start a new log file for this migration, and add a datestamp

setenv LOG $0.log.$$
rm -rf ${LOG}
touch ${LOG}

###------------------------------###
###--- MGI Marker feed report ---###
###------------------------------###

date | tee -a ${LOG}
echo 'MGI Marker feed report' | tee -a ${LOG}
${PUBRPTS}/mgimarkerfeed_reports.sh

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

###---------------------------###
###--- database statistics ---###
###---------------------------###
date | tee -a ${LOG}
echo 'Database statistics update' | tee -a ${LOG}
./gtlfStats.csh

###-----------------------###
###--- final datestamp ---###
###-----------------------###

date | tee -a ${LOG}
echo "--- Finished" | tee -a ${LOG}
