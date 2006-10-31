#!/bin/csh -fx

#
# Migration for TR7683
#
# Defaults:       6
# Procedures:   108
# Rules:          5
# Triggers:     158
# User Tables:  186
# Views:        213
#

source ../Configuration

setenv LOG $0.log
rm -rf ${LOG}
touch ${LOG}
 
date | tee -a  ${LOG}
 
# load a backup
#load_db.csh ${MGD_DBSERVER} ${MGD_DBNAME} /shire/sybase/mgd.backup | tee -a ${LOG}

# update schema tag
${MGI_DBUTILS}/bin/updatePublicVersion.csh ${MGD_DBSERVER} ${MGD_DBNAME} "${PUBLIC_VERSION}" | tee -a ${LOG}
${MGI_DBUTILS}/bin/updateSchemaVersion.csh ${MGD_DBSERVER} ${MGD_DBNAME} ${MGD_SCHEMA_TAG} | tee -a ${LOG}

date | tee -a  ${LOG}

########################################

./images.csh | tee -a ${LOG}

########################################

${MGD_DBSCHEMADIR}/reconfig.csh | tee -a ${LOG}
${MGD_DBPERMSDIR}/all_revoke.csh | tee -a ${LOG}
${MGD_DBPERMSDIR}/all_grant.csh | tee -a ${LOG}

date | tee -a  ${LOG}

