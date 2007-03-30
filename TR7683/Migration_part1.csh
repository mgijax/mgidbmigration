#!/bin/csh -fx

#
# Migration for TR7683
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
load_db.csh ${MGD_DBSERVER} ${MGD_DBNAME} /shire/sybase/mgd.backup | tee -a ${LOG}

# update schema tag
${MGI_DBUTILS}/bin/updatePublicVersion.csh ${MGD_DBSERVER} ${MGD_DBNAME} "MGI 3.52" | tee -a ${LOG}
${MGI_DBUTILS}/bin/updateSchemaVersion.csh ${MGD_DBSERVER} ${MGD_DBNAME} "mgddbschema-3-5-2" | tee -a ${LOG}

date | tee -a  ${LOG}

########################################

./cache.csh | tee -a ${LOG}
./tigr.csh | tee -a ${LOG}
./alleletype.csh | tee -a ${LOG}
./allelenotes.csh | tee -a ${LOG}
./clonelib.csh | tee -a ${LOG}
./dag.csh | tee -a ${LOG}
./vocheader.csh | tee -a ${LOG}

########################################

${MGD_DBSCHEMADIR}/reconfig.csh | tee -a ${LOG}
${MGD_DBPERMSDIR}/all_revoke.csh | tee -a ${LOG}
${MGD_DBPERMSDIR}/all_grant.csh | tee -a ${LOG}

# Clear out the text searching tables for the WI
${RADAR_DBSCHEMADIR}/table/TXT_truncate.logical | tee -a ${LOG}

date | tee -a  ${LOG}
