#!/bin/csh -f

#
# Migration for MGC release
#
# updated:
# MGD User Tables:	1
#
# created:
# RADAR User Tables:	9
#

cd `dirname $0` && source ./Configuration

setenv LOG $0.log
rm -rf ${LOG}
touch ${LOG}
 
############################################################
# Establish configuration settings for the MGD database.
#
source ${MGDDBSCHEMA}/Configuration
 
date | tee -a ${LOG}

############################################################
# Add the MGC logical DB to both clone sets.
#
echo "Add the MGC logical DB to both clone sets" | tee -a ${LOG}
echo "" | tee -a ${LOG}
cat - <<EOSQL | doisql.csh $0 >> ${LOG}

use ${DBNAME}
go

insert into MGI_SetMember values (160086,1021,44,2,${CREATEDBY},${CREATEDBY},getdate(),getdate())
insert into MGI_SetMember values (160097,1022,44,2,${CREATEDBY},${CREATEDBY},getdate(),getdate())
go

checkpoint
go

quit
EOSQL

date | tee -a ${LOG}

############################################################
# Establish configuration settings for the RADAR database.
#
source ${RADARDBSCHEMA}/Configuration
 
date | tee -a ${LOG}

############################################################
# Drop keys on the APP_JobStream table.
#
echo "Drop keys on the APP_JobStream table" | tee -a ${LOG}
echo "" | tee -a ${LOG}
${RADARDBSCHEMA}/key/APP_JobStream_drop.object | tee -a ${LOG}

date | tee -a ${LOG}

############################################################
# Re-build other tables that changed.
#
setenv TABLELIST ""
setenv TABLELIST "${TABLELIST} DP_MGC_Clones"
setenv TABLELIST "${TABLELIST} QC_MGCLoad_IMAGE_Missing"
setenv TABLELIST "${TABLELIST} QC_MGCLoad_MGC_Missing"
setenv TABLELIST "${TABLELIST} QC_MGCLoad_MGC_Duplicate"
setenv TABLELIST "${TABLELIST} QC_MGCLoad_Sequence_Missing"
setenv TABLELIST "${TABLELIST} QC_MGCLoad_Sequence_Duplicate"
setenv TABLELIST "${TABLELIST} MGI_Association"
setenv TABLELIST "${TABLELIST} QC_AssocLoad_Target_Discrep"
setenv TABLELIST "${TABLELIST} QC_AssocLoad_Assoc_Discrep"

foreach i (${TABLELIST})
    echo "Create the $i table" | tee -a ${LOG}
    echo "" | tee -a ${LOG}
    ${RADARDBSCHEMA}/table/${i}_create.object | tee -a ${LOG}
    ${RADARDBSCHEMA}/index/${i}_create.object | tee -a ${LOG}
    ${RADARDBSCHEMA}/key/${i}_create.object | tee -a ${LOG}
    ${RADARDBSCHEMA}/default/${i}_bind.object | tee -a ${LOG}
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
