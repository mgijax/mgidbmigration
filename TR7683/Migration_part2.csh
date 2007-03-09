#!/bin/csh -fx

#
# Migration for TR7683
#
# This part of the migration is run AFTER the Java libraries and loads
# are installed.
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
 
${VOCLOAD}/runOBOIncLoad.sh ${VOCLOAD}/GO.config
${TREEFAMLOAD}/treefam.sh | tee -a ${LOG}
${PIRSFLOAD}/bin/pirsfload.sh | tee -a ${LOG}
${MRKCACHELOAD}/mrkref.csh | tee -a ${LOG}
cd ${NOTELOAD}
${NOTELOAD}/mginoteload.csh ${NOTELOAD}/gotext.config | tee -a ${LOG}

date | tee -a  ${LOG}

# run QC reports

${QCRPTS}/qcnightly_reports.sh
${QCRPTS}/qcweekly_reports.sh
${QCRPTS}/qcmonthly_reports.sh

# run public reports

${PUBRPTS}/nightly_reports.sh
${PUBRPTS}/weekly_reports.sh
${PUBRPTS}/monthly_reports.sh

date | tee -a  ${LOG}
