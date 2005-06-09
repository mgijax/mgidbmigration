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
#load_db.csh ${DBSERVER} ${DBNAME} /shire/sybase/mgd.backup
#load_db.csh ${DBSERVER} ${DBNAME} /extra2/sybase/mgd322.backup

# update schema tag
${DBUTILSBINDIR}/updatePublicVersion.csh ${DBSERVER} ${DBNAME} "${PUBLIC_VERSION}" | tee -a ${LOG}
${DBUTILSBINDIR}/updateSchemaVersion.csh ${DBSERVER} ${DBNAME} ${SCHEMA_TAG} | tee -a ${LOG}

date | tee -a  ${LOG}

########################################

# 3.22 stuff
${newmgddbschema}/procedure/ALL_processAlleleCombination_drop.object | tee -a ${LOG}
${newmgddbschema}/procedure/ALL_processAlleleCombination_create.object | tee -a ${LOG}
${newmgddbschema}/procedure/ALL_convertAllele_drop.object | tee -a ${LOG}
${newmgddbschema}/procedure/ALL_convertAllele_create.object | tee -a ${LOG}
${newmgddbperms}/curatorial/procedure/ALL_convertAllele_grant.object | tee -a ${LOG}
${newmgddbperms}/curatorial/procedure/ALL_processAlleleCombination_grant.object | tee -a ${LOG}

# 3.3 stuff

${newmgddbschema}/table/MRK_OMIM_Cache_create.object | tee -a ${LOG}
${newmgddbschema}/index/MRK_OMIM_Cache_create.object | tee -a ${LOG}

${newmgddbschema}/key/key_drop.csh | tee -a ${LOG}
${newmgddbschema}/key/key_create.csh | tee -a ${LOG}

#${newmgddbperms}/curatorial/table/MRK_OMIM_Cache_grant.object | tee -a ${LOG}
${newmgddbperms}/public/table/MRK_OMIM_Cache_grant.object | tee -a ${LOG}

${CACHELOAD}/mrkomim.csh | tee -a ${LOG}
./mgiimage.csh | tee -a ${LOG}

date | tee -a  ${LOG}
