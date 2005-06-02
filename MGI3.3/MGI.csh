#!/bin/csh -f

#
# Migration for 3.3 (OMIM, Images)
#
# Defaults:       6
# Procedures:   122
# Rules:          5
# Triggers:     156
# User Tables:  181
# Views:        226

cd `dirname $0` && source ./Configuration

setenv LOG $0.log
rm -rf ${LOG}
touch ${LOG}
 
date | tee -a  ${LOG}
 
${DBUTILSBINDIR}/turnonbulkcopy.csh ${DBSERVER} ${DBNAME} | tee -a ${LOG}

# load a backup
load_db.csh ${DBSERVER} ${DBNAME} /shire/sybase/mgd.backup

# update schema tag
${DBUTILSBINDIR}/updatePublicVersion.csh ${DBSERVER} ${DBNAME} "${PUBLIC_VERSION}" | tee -a ${LOG}
${DBUTILSBINDIR}/updateSchemaVersion.csh ${DBSERVER} ${DBNAME} ${SCHEMA_TAG} | tee -a ${LOG}

date | tee -a  ${LOG}

########################################

${newmgddbschema}/table/MRK_OMIM_Cache_create.object | tee -a ${LOG}
${newmgddbschema}/index/MRK_OMIM_Cache_create.object | tee -a ${LOG}
${CACHELOAD}/mrkomim.csh | tee -a ${LOG}

${newmgddbschema}/reconfig.csh | tee -a ${LOG}
${newmgddbperms}/all_revoke.csh | tee -a ${LOG}
${newmgddbperms}/all_grant.csh | tee -a ${LOG}

date | tee -a  ${LOG}
