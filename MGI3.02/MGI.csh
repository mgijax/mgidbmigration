#!/bin/csh -f

#
# Migration for 3.02 release (cDNA Load)
#
# updated:
# RADAR User Tables:	18
#

cd `dirname $0` && source ./Configuration

setenv LOG $0.log
rm -rf ${LOG}
touch ${LOG}
 
############################################################
# Establish configuration settings for the MGD database
# and load the database from the production backup.
#
source ${MGDDBSCHEMA}/Configuration
 
echo "" | tee -a ${LOG}
echo "MGD Migration..." | tee -a ${LOG}
echo "" | tee -a ${LOG}

date | tee -a ${LOG}

echo "" | tee -a ${LOG}
echo "Load MGD database from backup..." | tee -a ${LOG}
echo "" | tee -a ${LOG}
${MGIDBUTILS}/bin/load_db.csh ${DBSERVER} ${DBNAME} ${MGD_BACKUP}

date | tee -a ${LOG}

############################################################
# Establish configuration settings for the RADAR database
# and load the database from the production backup.
#
source ${RADARDBSCHEMA}/Configuration
 
echo "" | tee -a ${LOG}
echo "RADAR Migration..." | tee -a ${LOG}
echo "" | tee -a ${LOG}

date | tee -a ${LOG}

echo "" | tee -a ${LOG}
echo "Load RADAR database from backup..." | tee -a ${LOG}
echo "" | tee -a ${LOG}
${MGIDBUTILS}/bin/load_db.csh ${DBSERVER} ${DBNAME} ${RADAR_BACKUP}

date | tee -a ${LOG}

############################################################
# Reload the RIKEN_FANTOM_Clones table.
#
echo "Reload the RIKEN_FANTOM_Clones table" | tee -a ${LOG}
echo "" | tee -a ${LOG}
${RADARDBUTILS}/bin/RIKENClones.csh | tee -a ${LOG}

date | tee -a ${LOG}

############################################################
# Reload the NIA_Parent_Daughter_Clones table.
#
echo "Reload the NIA_Parent_Daughter_Clones table" | tee -a ${LOG}
echo "" | tee -a ${LOG}
${RADARDBUTILS}/bin/NIAParentDaughter.csh | tee -a ${LOG}

date | tee -a ${LOG}

############################################################
# Reload the MGI_CloneLibrary table.
#
echo "Reload the MGI_CloneLibrary table" | tee -a ${LOG}
echo "" | tee -a ${LOG}
${RADARDBUTILS}/bin/CloneLibrary.csh | tee -a ${LOG}

date | tee -a ${LOG}

############################################################
# Drop keys on the APP_JobStream table.
#
echo "Drop keys on the APP_JobStream table" | tee -a ${LOG}
echo "" | tee -a ${LOG}
${RADARDBSCHEMA}/key/APP_JobStream_drop.object | tee -a ${LOG}

date | tee -a ${LOG}

############################################################
# Drop the QC_cDNALoad_MGI_IMAGE_Discrep table.
#
echo "Drop the QC_cDNALoad_MGI_IMAGE_Discrep table" | tee -a ${LOG}
echo "" | tee -a ${LOG}
cat - <<EOSQL | doisql.csh $0 >> ${LOG}
  
use ${DBNAME}
go

drop table QC_cDNALoad_MGI_IMAGE_Discrep
go

checkpoint
go

quit
EOSQL

date | tee -a ${LOG}

############################################################
# Re-build other tables that changed.
#
setenv TABLELIST ""
setenv TABLELIST "${TABLELIST} QC_cDNALoad_CloneID_Missing"
setenv TABLELIST "${TABLELIST} QC_cDNALoad_CloneID_Unknown"
setenv TABLELIST "${TABLELIST} QC_cDNALoad_Library_Missing"
setenv TABLELIST "${TABLELIST} QC_cDNALoad_Library_No_Parent"
setenv TABLELIST "${TABLELIST} GB_EST_Reload"

foreach i (${TABLELIST})
    echo "Re-build the $i table" | tee -a ${LOG}
    echo "" | tee -a ${LOG}
    ${RADARDBSCHEMA}/table/${i}_drop.object | tee -a ${LOG}
    ${RADARDBSCHEMA}/table/${i}_create.object | tee -a ${LOG}
    ${RADARDBSCHEMA}/index/${i}_create.object | tee -a ${LOG}
    ${RADARDBSCHEMA}/key/${i}_create.object | tee -a ${LOG}
    if (${i} != "GB_EST_Reload") then
        ${RADARDBSCHEMA}/default/${i}_bind.object | tee -a ${LOG}
    endif
    ${RADARDBPERMS}/developers/table/${i}_grant.object | tee -a ${LOG}
    ${RADARDBPERMS}/public/table/${i}_grant.object | tee -a ${LOG}
end

############################################################
# Create keys on the APP_JobStream table.
#
echo "Create keys on the APP_JobStream table" | tee -a ${LOG}
echo "" | tee -a ${LOG}
${RADARDBSCHEMA}/key/APP_JobStream_create.object | tee -a ${LOG}

date | tee -a ${LOG}

############################################################
# Add missing components to the RADAR database.
#
echo "Adding missing components to the RADAR database" | tee -a ${LOG}
echo "" | tee -a ${LOG}
${RADARDBSCHEMA}/default/MGI_CloneLoad_Accession_bind.object | tee -a ${LOG}
${RADARDBSCHEMA}/default/QC_cDNALoad_CloneID_Discrep_bind.object | tee -a ${LOG}
${RADARDBSCHEMA}/default/QC_cDNALoad_Library_Discrep_bind.object | tee -a ${LOG}
${RADARDBSCHEMA}/default/QC_CloneLoad_DupClone_bind.object | tee -a ${LOG}
${RADARDBSCHEMA}/default/QC_CloneLoad_DupSeq_bind.object | tee -a ${LOG}
${RADARDBSCHEMA}/default/QC_CloneLoad_MultiClone_bind.object | tee -a ${LOG}
${RADARDBSCHEMA}/default/QC_CloneLoad_NonClone_bind.object | tee -a ${LOG}
${RADARDBSCHEMA}/default/QC_CloneLoad_SeqOnly_bind.object | tee -a ${LOG}
${RADARDBPERMS}/developers/table/WRK_cDNA_Clones_grant.object | tee -a ${LOG}

date | tee -a ${LOG}
