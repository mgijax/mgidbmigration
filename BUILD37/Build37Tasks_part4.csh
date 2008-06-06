#!/bin/csh -f

#
# Build 37 Tasks - Part 4
#
# This script is run after the snp database has been loaded.
#
# This script accomplishes the following tasks:
#  1) Run all QC and public reports
#  2) Generate GBrowse reports

cd `dirname $0` && source ../Configuration

date
echo "$0"

#
# Run QC and public reports.
#
# NOTE: mgd/SEQ_RepTransGenomic.py is needed for building GBrowse.
date
echo 'QC Reports'
${QCRPTS}/qcnightly_reports.sh
${QCRPTS}/qcweekly_reports.sh
${QCRPTS}/qcmonthly_reports.sh

date
echo 'Public Reports'
${PUBRPTS}/nightly_reports.sh
${PUBRPTS}/weekly_reports.sh
${PUBRPTS}/monthly_reports.sh

#
# Run GBrowse utilities.
#
date
echo 'GBrowse Utilities'
${GBROWSEUTILS}/bin/generateReports.sh

echo 'Completed'
date
