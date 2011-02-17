#!/bin/csh -f

#
# TR10584/Permissions for Strains
#

cd `dirname $0` && source ../Configuration

setenv LOG $0.log
rm -rf $LOG
touch $LOG
 
date | tee -a $LOG
 
cat - <<EOSQL | doisql.csh $MGD_DBSERVER $MGD_DBNAME $0 | tee -a $LOG

use $MGD_DBNAME
go

/* drop removed trigger */

drop trigger MLD_Assay_Types_InsUpd
drop trigger MLD_Concordance_InsDel
drop trigger MLD_Concordance_Update
drop trigger MLD_Distance_InsDel
drop trigger MLD_Distance_Update
drop trigger MLD_FISH_Delete
drop trigger MLD_FISH_Region_InsUpdDel
drop trigger MLD_Hybrid_Delete
drop trigger MLD_InSitu_Delete
drop trigger MLD_ISRegion_InsUpdDel
drop trigger MLD_Matrix_InsUpd
drop trigger MLD_MCDataList_InsUpdDel
drop trigger MLD_MC2point_InsDel
drop trigger MLD_MC2point_Update
drop trigger MLD_PhysMap_InsUpdDel
drop trigger MLD_RI2Point_InsDel
drop trigger MLD_RI2Point_Update
drop trigger MLD_RI_InsUpdDel
drop trigger MLD_RIData_InsDel
drop trigger MLD_RIData_Update
drop trigger MLD_Statistics_InsDel
drop trigger MLD_Statistics_Update
drop trigger MLD_Expt_Marker_Delete
drop trigger RI_RISet_InsUpd
go

drop trigger GXD_AntibodyAlias_InsUpdDel
drop trigger GXD_AntibodyClass_InsUpd
drop trigger GXD_AntibodyMarker_InsDel
drop trigger GXD_AntibodyMarker_Update
drop trigger GXD_AntibodyPrep_InsUpd
drop trigger GXD_AntibodyType_InsUpd
drop trigger GXD_AssayType_InsUpd
drop trigger GXD_EmbeddingMethod_InsUpd
drop trigger GXD_Expression_InsDel
drop trigger GXD_Expression_Update
drop trigger GXD_FixationMethod_InsUpd
drop trigger GXD_GelControl_InsUpd
drop trigger GXD_GelBand_InsUpdDel
drop trigger GXD_GelLane_InsUpd
drop trigger GXD_GelLaneStructure_InsUpdDel
drop trigger GXD_GelRNAType_InsUpd
drop trigger GXD_GelUnits_InsUpd
drop trigger GXD_InSituResultImage_InsUpdDe
drop trigger GXD_ISResultStructure_InsUpdDe
drop trigger GXD_Label_InsUpd
drop trigger GXD_Pattern_InsUpd
drop trigger GXD_ProbePrep_InsUpd
drop trigger GXD_ProbeSense_InsUpd
drop trigger GXD_Secondary_InsUpd
drop trigger GXD_Specimen_InsUpd
drop trigger GXD_Strength_InsUpd
drop trigger GXD_TheilerStage_InsUpd
drop trigger GXD_VisualizationMethod_InsUpd
drop trigger GXD_Antibody_Delete
drop trigger GXD_Antigen_Delete
drop trigger GXD_Index_Stages_InsDel
drop trigger GXD_Index_Stages_Update
go

drop trigger HMD_Homology_Assay_InsUpdDel
drop trigger HMD_Homology_InsUpd
drop trigger HMD_Homology_Marker_InsUpdDel
drop trigger HMD_Assay_InsUpd
drop trigger HMD_Class_InsUpd
drop trigger MLC_Marker_InsUpdDel
drop trigger MLC_Reference_InsUpdDel
drop trigger MLC_Text_InsUpd
drop trigger SEQ_Sequence_Assoc_InsUpdDel
drop trigger SEQ_Sequence_Raw_InsUpdDel
drop trigger BIB_ReviewStatus_InsUpd
drop trigger CRS_Cross_Delete
drop trigger CRS_Cross_InsUpd
drop trigger MGI_Translation_Delete
drop trigger MGI_TranslationType_InsUpd


go

checkpoint
go

end

EOSQL

date |tee -a $LOG

