#!/bin/csh -f

#
# Migration for RADAR
#

cd `dirname $0` && source ./Configuration

setenv LOG $0.log
rm -rf ${LOG}
touch ${LOG}
 
date | tee -a ${LOG}
echo "RADAR Migration..." | tee -a ${LOG}
 
source ${newrdrdbschema}/Configuration

# for development only
load_dev1db.csh ${DBNAME} radar.backup | tee -a ${LOG}

echo "Update RADAR DB Info..." | tee -a  ${LOG}
${DBUTILSBINDIR}/updatePublicVersion.csh ${DBSERVER} ${DBNAME} ${PUBLIC_VERSION} | tee -a ${LOG}
${DBUTILSBINDIR}/updateSchemaVersion.csh ${DBSERVER} ${DBNAME} ${RADAR_SCHEMA_TAG} | tee -a ${LOG}

#
# Use new schema product to create new table
#
${newrdrdbschema}/table/QC_MS_AttrEdit_create.object | tee -a ${LOG}
${newrdrdbschema}/table/QC_MS_InvalidLibrary_create.object | tee -a ${LOG}
${newrdrdbschema}/table/QC_MS_InvalidStrain_create.object | tee -a ${LOG}
${newrdrdbschema}/table/QC_MS_InvalidTissue_create.object | tee -a ${LOG}
${newrdrdbschema}/table/QC_MS_InvalidCellLine_create.object | tee -a ${LOG}
${newrdrdbschema}/table/QC_MS_InvalidGender_create.object | tee -a ${LOG}
${newrdrdbschema}/table/QC_MS_NameConflict_create.object | tee -a ${LOG}
${newrdrdbschema}/table/QC_SEQ_OldRef_create.object | tee -a ${LOG}
${newrdrdbschema}/table/QC_SEQ_RawSourceConflict_create.object | tee -a ${LOG}
${newrdrdbschema}/index/QC_MS_AttrEdit_create.object | tee -a ${LOG}
${newrdrdbschema}/index/QC_MS_InvalidLibrary_create.object | tee -a ${LOG}
${newrdrdbschema}/index/QC_MS_InvalidStrain_create.object | tee -a ${LOG}
${newrdrdbschema}/index/QC_MS_InvalidTissue_create.object | tee -a ${LOG}
${newrdrdbschema}/index/QC_MS_InvalidCellLine_create.object | tee -a ${LOG}
${newrdrdbschema}/index/QC_MS_InvalidGender_create.object | tee -a ${LOG}
${newrdrdbschema}/index/QC_MS_NameConflict_create.object | tee -a ${LOG}
${newrdrdbschema}/index/QC_SEQ_OldRef_create.object | tee -a ${LOG}
${newrdrdbschema}/index/QC_SEQ_RawSourceConflict_create.object | tee -a ${LOG}
${newrdrdbschema}/key/QC_MS_AttrEdit_create.object | tee -a ${LOG}
${newrdrdbschema}/key/QC_MS_InvalidLibrary_create.object | tee -a ${LOG}
${newrdrdbschema}/key/QC_MS_InvalidStrain_create.object | tee -a ${LOG}
${newrdrdbschema}/key/QC_MS_InvalidTissue_create.object | tee -a ${LOG}
${newrdrdbschema}/key/QC_MS_InvalidCellLine_create.object | tee -a ${LOG}
${newrdrdbschema}/key/QC_MS_InvalidGender_create.object | tee -a ${LOG}
${newrdrdbschema}/key/QC_MS_NameConflict_create.object | tee -a ${LOG}
${newrdrdbschema}/key/QC_SEQ_OldRef_create.object | tee -a ${LOG}
${newrdrdbschema}/key/QC_SEQ_RawSourceConflict_create.object | tee -a ${LOG}
${newrdrdbschema}/key/APP_JobStream_drop.object | tee -a ${LOG}
${newrdrdbschema}/key/APP_JobStream_create.object | tee -a ${LOG}

${newrdrdbperms}/developers/table/QC_grant.logical | tee -a ${LOG}
${newrdrdbperms}/public/table/QC_grant.logical | tee -a ${LOG}

date | tee -a ${LOG}

