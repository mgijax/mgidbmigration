#!/bin/csh -f

#
# Build 37 Tasks - Part 1
#
# This script is run prior to installing the Java Libraries and loads.
#
# This script accomplishes the following tasks:
#  1) Load the mgd/radar databases from production backups (development only)
#  2) Backup the mgd/radar databases (production only)
#  3) Run the database migration script

cd `dirname $0` && source ../Configuration

date
echo "$0"

#
# Load databases (development builds only).
#
if ( ${HOST} != "shire" ) then
    date
    echo 'Load mgd/radar databases'
    ${MGI_DBUTILS}/bin/load_db.csh ${MGD_DBSERVER} ${MGD_DBNAME} /shire/sybase/mgd.backup
    ${MGI_DBUTILS}/bin/load_db.csh ${RADAR_DBSERVER} ${RADAR_DBNAME} /shire/sybase/radar.backup
endif

#
# Backup databases before proceeding (production only).
#
if ( ${HOST} = "shire" ) then
    date
    echo 'Backup mgd/radar databases'
    ${MGI_DBUTILS}/bin/dump_db.csh ${MGD_DBSERVER} ${MGD_DBNAME} /extra1/sybase/mgd.preBuild37.backup
    ${MGI_DBUTILS}/bin/dump_db.csh ${RADAR_DBSERVER} ${RADAR_DBNAME} /extra1/sybase/radar.preBuild37.backup
endif

#
# Run the migration to remove obsolete gene models and curator associations.
#
date
${DBUTILS}/mgidbmigration/BUILD37/MGI.csh

#
# Run extra tasks that are unrelated to Build 37, but are being bundled with
# the Build 37 release.
#
date
${DBUTILS}/mgidbmigration/BUILD37/ExtraTasks.csh

echo 'Completed'
date
