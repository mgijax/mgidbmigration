#!/bin/csh -f

#
# Migration for RADAR
#
# Tables:     35
# Triggers:   1
# Procedures: 2
# Views:
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
# changed tables; we can drop and re-create them
#
${newrdrdbschema}/table/MGI_CloneLibrary_drop.object | tee -a ${LOG}
${newrdrdbschema}/table/QC_cDNALoad_MGI_IMAGE_Discrep_drop.object | tee -a ${LOG}
${newrdrdbschema}/table/MGI_CloneLibrary_create.object | tee -a ${LOG}
${newrdrdbschema}/table/QC_cDNALoad_MGI_IMAGE_Discrep_create.object | tee -a ${LOG}
${newrdrdbschema}/index/MGI_CloneLibrary_create.object | tee -a ${LOG}
${newrdrdbschema}/index/QC_cDNALoad_MGI_IMAGE_Discrep_create.object | tee -a ${LOG}
${newrdrdbschema}/key/MGI_CloneLibrary_create.object | tee -a ${LOG}
${newrdrdbschema}/key/QC_cDNALoad_MGI_IMAGE_Discrep_create.object | tee -a ${LOG}

#
# Use new schema product to create new table
#
${newrdrdbschema}/table/GB_EST_Reload_create.object | tee -a ${LOG}
${newrdrdbschema}/table/QC_cDNALoad_CloneID_Discrep_create.object | tee -a ${LOG}
${newrdrdbschema}/table/QC_cDNALoad_CloneID_Missing_create.object | tee -a ${LOG}
${newrdrdbschema}/table/QC_cDNALoad_CloneID_Unknown_create.object | tee -a ${LOG}
${newrdrdbschema}/table/QC_cDNALoad_Library_Discrep_create.object | tee -a ${LOG}
${newrdrdbschema}/table/QC_cDNALoad_Library_Missing_create.object | tee -a ${LOG}
${newrdrdbschema}/table/QC_cDNALoad_Library_No_Parent_create.object | tee -a ${LOG}
${newrdrdbschema}/table/RIKEN_FANTOM_Clones_create.object | tee -a ${LOG}
${newrdrdbschema}/table/WRK_cDNA_Clones_create.object | tee -a ${LOG}
${newrdrdbschema}/table/QC_MS_AttrEdit_create.object | tee -a ${LOG}
${newrdrdbschema}/table/QC_MS_InvalidLibrary_create.object | tee -a ${LOG}
${newrdrdbschema}/table/QC_MS_InvalidStrain_create.object | tee -a ${LOG}
${newrdrdbschema}/table/QC_MS_InvalidTissue_create.object | tee -a ${LOG}
${newrdrdbschema}/table/QC_MS_InvalidCellLine_create.object | tee -a ${LOG}
${newrdrdbschema}/table/QC_MS_InvalidGender_create.object | tee -a ${LOG}
${newrdrdbschema}/table/QC_MS_NameConflict_create.object | tee -a ${LOG}
${newrdrdbschema}/table/QC_SEQ_Merged_create.object | tee -a ${LOG}
${newrdrdbschema}/table/QC_SEQ_OldRef_create.object | tee -a ${LOG}
${newrdrdbschema}/table/QC_SEQ_RawSourceConflict_create.object | tee -a ${LOG}

${newrdrdbschema}/index/GB_EST_Reload_create.object | tee -a ${LOG}
${newrdrdbschema}/index/QC_cDNALoad_CloneID_Discrep_create.object | tee -a ${LOG}
${newrdrdbschema}/index/QC_cDNALoad_CloneID_Missing_create.object | tee -a ${LOG}
${newrdrdbschema}/index/QC_cDNALoad_CloneID_Unknown_create.object | tee -a ${LOG}
${newrdrdbschema}/index/QC_cDNALoad_Library_Discrep_create.object | tee -a ${LOG}
${newrdrdbschema}/index/QC_cDNALoad_Library_Missing_create.object | tee -a ${LOG}
${newrdrdbschema}/index/QC_cDNALoad_Library_No_Parent_create.object | tee -a ${LOG}
${newrdrdbschema}/index/RIKEN_FANTOM_Clones_create.object | tee -a ${LOG}
${newrdrdbschema}/index/WRK_cDNA_Clones_create.object | tee -a ${LOG}
${newrdrdbschema}/index/QC_MS_AttrEdit_create.object | tee -a ${LOG}
${newrdrdbschema}/index/QC_MS_InvalidLibrary_create.object | tee -a ${LOG}
${newrdrdbschema}/index/QC_MS_InvalidStrain_create.object | tee -a ${LOG}
${newrdrdbschema}/index/QC_MS_InvalidTissue_create.object | tee -a ${LOG}
${newrdrdbschema}/index/QC_MS_InvalidCellLine_create.object | tee -a ${LOG}
${newrdrdbschema}/index/QC_MS_InvalidGender_create.object | tee -a ${LOG}
${newrdrdbschema}/index/QC_MS_NameConflict_create.object | tee -a ${LOG}
${newrdrdbschema}/index/QC_SEQ_Merged_create.object | tee -a ${LOG}
${newrdrdbschema}/index/QC_SEQ_OldRef_create.object | tee -a ${LOG}
${newrdrdbschema}/index/QC_SEQ_RawSourceConflict_create.object | tee -a ${LOG}

${newrdrdbschema}/key/GB_EST_Reload_create.object | tee -a ${LOG}
${newrdrdbschema}/key/QC_cDNALoad_CloneID_Discrep_create.object | tee -a ${LOG}
${newrdrdbschema}/key/QC_cDNALoad_CloneID_Missing_create.object | tee -a ${LOG}
${newrdrdbschema}/key/QC_cDNALoad_CloneID_Unknown_create.object | tee -a ${LOG}
${newrdrdbschema}/key/QC_cDNALoad_Library_Discrep_create.object | tee -a ${LOG}
${newrdrdbschema}/key/QC_cDNALoad_Library_Missing_create.object | tee -a ${LOG}
${newrdrdbschema}/key/QC_cDNALoad_Library_No_Parent_create.object | tee -a ${LOG}
${newrdrdbschema}/key/RIKEN_FANTOM_Clones_create.object | tee -a ${LOG}
${newrdrdbschema}/key/WRK_cDNA_Clones_create.object | tee -a ${LOG}
${newrdrdbschema}/key/QC_MS_AttrEdit_create.object | tee -a ${LOG}
${newrdrdbschema}/key/QC_MS_InvalidLibrary_create.object | tee -a ${LOG}
${newrdrdbschema}/key/QC_MS_InvalidStrain_create.object | tee -a ${LOG}
${newrdrdbschema}/key/QC_MS_InvalidTissue_create.object | tee -a ${LOG}
${newrdrdbschema}/key/QC_MS_InvalidCellLine_create.object | tee -a ${LOG}
${newrdrdbschema}/key/QC_MS_InvalidGender_create.object | tee -a ${LOG}
${newrdrdbschema}/key/QC_MS_NameConflict_create.object | tee -a ${LOG}
${newrdrdbschema}/key/QC_SEQ_Merged_create.object | tee -a ${LOG}
${newrdrdbschema}/key/QC_SEQ_OldRef_create.object | tee -a ${LOG}
${newrdrdbschema}/key/QC_SEQ_RawSourceConflict_create.object | tee -a ${LOG}

#
# update APP_JobStream keys
#
${newrdrdbschema}/key/APP_JobStream_drop.object | tee -a ${LOG}
${newrdrdbschema}/key/APP_JobStream_create.object | tee -a ${LOG}

${newrdrdbperms}/developers/table/perm_grant.csh | tee -a ${LOG}
${newrdrdbperms}/public/table/perm_grant.csh | tee -a ${LOG}

cat - <<EOSQL | doisql.csh $0 >> $LOG
  
use ${DBNAME}
go

drop table DP_cDNA_Clones
go

drop table QC_cDNALoad_IMAGE_NoID
go

drop table QC_cDNALoad_IMAGE_NoLib
go

drop table QC_cDNALoad_Lib_Discrep
go

drop table QC_cDNALoad_NIA_NoLib
go

checkpoint
go

quit
 
EOSQL

date | tee -a ${LOG}

