#!/bin/csh -f

#
# Build 37 Tasks - Part 3
#
# This script is run after the snp database has been loaded.
#
# This script accomplishes the following tasks:
#  1) Load gene trap lite associations
#  2) Load all cache tables
#  3) Add a new set of measurements
#  4) Backup the mgd/radar databases

cd `dirname $0` && source ../Configuration

date
echo "$0"

#
# Load gene trap lite associations (delete/reload mode).  Depends on
# gtlitepipeline having been run on hobbiton.
#
echo 'Creating gene trap cell line id to marker associations'
${ASSOCLOAD}/bin/AssocLoadDP.sh ${ASSOCLOAD}/DP.config.genetrap

#
# Load all cache tables.
#
date
echo 'Load Sequence Cache tables'
${SEQCACHELOAD}/seqcoord.csh
${SEQCACHELOAD}/seqmarker.csh
${SEQCACHELOAD}/seqdescription.csh

date
echo 'Load Marker Cache tables'
${MRKCACHELOAD}/mrklabel.csh
${MRKCACHELOAD}/mrkref.csh
${MRKCACHELOAD}/mrklocation.csh

#
# Add a new set of measurements.
#
date
echo 'Add New Measurements'
${MGI_DBUTILS}/bin/addMeasurements.csh

#
# Backup databases.
#
date
echo 'Backup mgd/radar databases'
${MGI_DBUTILS}/bin/mgi_backup_to_disk.csh ${MGD_DBSERVER} "${MGD_DBNAME} ${RADAR_DBNAME}" Build37

echo 'Completed'
date
