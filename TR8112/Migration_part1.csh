#!/bin/csh -fx

#
# Migration for TR8112 - MGI3.53
#
# Note: there are no schema changes for this release
#
# This part of the migration is run BEFORE the Java libraries and loads
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
 
# load a backup
if ( ${HOST} != "shire" ) then
    load_db.csh ${MGD_DBSERVER} ${MGD_DBNAME} /shire/sybase/mgd.backup | tee -a ${LOG}
endif

# update schema tag
${MGI_DBUTILS}/bin/updatePublicVersion.csh ${MGD_DBSERVER} ${MGD_DBNAME} "MGI 3.53" | tee -a ${LOG}

date | tee -a  ${LOG}

########################################

# Clear out the text searching tables for the WI
${RADAR_DBSCHEMADIR}/table/TXT_truncate.logical | tee -a ${LOG}

date | tee -a  ${LOG}
