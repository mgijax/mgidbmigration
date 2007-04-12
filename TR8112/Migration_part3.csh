#!/bin/csh -fx

#
# Migration for TR8112 - MGI3.53
#
#
# Defaults:       6
# Procedures:   111
# Rules:          5
# Triggers:     158
# User Tables:  187
# Views:        215
#

cd `dirname $0` && source ../Configuration

setenv LOG `pwd`/$0.log
rm -rf ${LOG}
touch ${LOG}
 
date | tee -a  ${LOG}

# run QC reports
echo "running ${QCRPTS}" | tee -a  ${LOG}

${QCRPTS}/qcnightly_reports.sh
${QCRPTS}/qcweekly_reports.sh
${QCRPTS}/qcmonthly_reports.sh

# run public reports
echo "running ${PUBRPTS}" | tee -a  ${LOG}

${PUBRPTS}/nightly_reports.sh
${PUBRPTS}/weekly_reports.sh
${PUBRPTS}/monthly_reports.sh

date | tee -a  ${LOG}
