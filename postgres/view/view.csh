#!/bin/csh -fx

# clean up views
# remove views that are no longer useD
#
# Views  244
#	- 26
#	----
#	 218
#
# mgddbschema-4-4-1-54
#	- must 'cvs remove the views below, then tag
#
# do *NOT* remove:
#
# ACC_ActualDB_Summary_View                                                        
# ALL_Type_Summary_View                                                            
# ALL_Derivation_Summary_View                                                      
# GXD_Genotype_Summary_View                                                        
# MGI_Organism_Summary_View                                                        
# MGI_Statistic_View                                                               
# MRK_Summary_View                                                                 
# MRK_Types_Summary_View    
# PRB_Source_Summary_View                                                          
# PRB_Strain_Summary_View                                                          
# PRB_Tissue_Summary_View                                                          
# VOC_Term_Summary_View                                                            
# VOC_Term_Summary_View                                                            
#

cd `dirname $0` && source ./Configuration

echo "Server: ${MGD_DBSERVER}"
echo "Database: ${MGD_DBNAME}"

setenv LOG $0.log.$$
rm -rf ${LOG}
touch ${LOG}
date | tee -a ${LOG}

# load a backup

if ("${1}" == "dev") then
    echo "--- Loading new database into ${MGD_DBSERVER}..${MGD_DBNAME}" | tee -a ${LOG}
    load_db.csh ${MGD_DBSERVER} ${MGD_DBNAME} /lindon/sybase/mgd.backup | tee -a ${LOG}
    date | tee -a ${LOG}
else
    echo "--- Working on existing database: ${MGD_DBSERVER}..${MGD_DBNAME}" | tee -a ${LOG}
endif

date | tee -a ${LOG}
echo "--- Updating version numbers in db..." | tee -a ${LOG}

echo "--- views ---"

cat - <<EOSQL | ${MGI_DBUTILS}/bin/doisql.csh ${MGD_DBSERVER} ${MGD_DBNAME} $0

use ${MGD_DBNAME}
go

drop view VOC_Term_ALLCompound_View
drop view VOC_Term_ALLMolMutation_View
drop view VOC_Term_ALLType_View
go

drop view VOC_Term_GOProperty_View
go

drop view VOC_Term_IMGClass_View
drop view VOC_Term_IMGType_View
drop view VOC_Term_NeedsReview_View
go

drop view VOC_Term_SequenceProvider_View
drop view VOC_Term_SequenceQuality_View
drop view VOC_Term_SequenceStatus_View
drop view VOC_Term_SequenceType_View
drop view VOC_Term_SegVectorType_View
go

drop view VOC_Term_StrainGenoQual_View
drop view VOC_Term_StrainType_View
drop view VOC_Term_StrainAttribute_View
go

drop view VOC_Term_UserRole_View
drop view VOC_Term_UserTask_View
go

drop view VOC_Term_ALLTransmission_View
drop view VOC_Term_ALLStatus_View
drop view VOC_Term_ALLPairState_View
drop view VOC_Term_ALLInheritMode_View
go

/* 11, 12, 13, 14 */
drop view VOC_Term_GXDIndexCondMut_View
drop view VOC_Term_GXDIndexPriority_View
drop view VOC_Term_GXDIndexAssay_View
drop view VOC_Term_GXDIndexStage_View
drop view VOC_Term_GXDReporterGene_View
go

/* rules */

exec sp_unbindrule "BIB_Refs.NLMstatus"
exec sp_unbindrule "GXD_GelLane.sex"
exec sp_unbindrule "GXD_ProbePrep.type"
exec sp_unbindrule "GXD_Specimen.sex"
exec sp_unbindrule "GXD_Specimen.hybridization"
exec sp_unbindrule "PRB_Marker.relationship"
go

drop rule check_Hybridization
drop rule check_NLM_status
drop rule check_NucleicAcidType
drop rule check_Relationship
drop rule check_Sex
go

/* defaults */

exec sp_unbindefault "MLC_Text.userID"
go

checkpoin
go

quit

EOSQL

date | tee -a ${LOG}
echo "--- view ---"
${MGD_DBSCHEMADIR}/view/view_drop.csh | tee -a ${LOG}
${MGD_DBSCHEMADIR}/view/view_create.csh | tee -a ${LOG}

date | tee -a ${LOG}
echo "--- Re-setting permissions/schema ---"
#${MGD_DBSCHEMADIR}/reconfig.csh | tee -a ${LOG}
${MGD_DBSCHEMADIR}/all_perms.csh | tee -a ${LOG}


