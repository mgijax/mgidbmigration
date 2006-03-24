#!/bin/csh -fx

#
# clean up old-style "_fkey" index names
#

cd `dirname $0` && source ./Configuration

setenv LOG $0.log
rm -rf ${LOG}
touch ${LOG}
 
date | tee -a  ${LOG}
 
cat - <<EOSQL | doisql.csh $0 | tee -a ${LOG}

use ${DBNAME}
go

drop index CRS_Cross.idx_maleStrain_fkey
go

drop index CRS_Cross.idx_femaleStrain_fkey
go

drop index CRS_Cross.idx_strainHO_fkey
go

drop index CRS_Cross.idx_strainHT_fkey
go

drop index HMD_Homology_Assay.idx_Homology_fkey
go

drop index HMD_Homology_Marker.idx_Marker_fkey
go

drop index HMD_Homology_Marker.idx_Homology_fkey
go

drop index HMD_Homology.idx_Class_fkey
go

drop index HMD_Homology.idx_Refs_fkey
go

drop index MLD_Expt_Marker.idx_Allele_fkey
go

drop index MLD_FISH.idx_strain_fkey
go

drop index MLD_FISH_Region.idx_Expt_fkey
go

drop index MLD_InSitu.idx_strain_fkey
go

drop index MLD_ISRegion.idx_Expt_fkey
go

drop index MLD_MC2point.idx_Expt_fkey
go

drop index MLD_MCDataList.idx_Expt_fkey
go

drop index MLD_RI2Point.idx_Expt_fkey
go

drop index MRK_Classes.idx_Class_fkey
go

drop index MRK_Classes.idx_Marker_fkey
go

drop index MRK_Current.idx_Current_fkey
go

drop index PRB_Allele.idx_RFLV_fkey
go

drop index PRB_Allele_Strain.idx_Strain_fkey
go

drop index PRB_Allele_Strain.idx_Allele_fkey
go

drop index PRB_RFLV.idx_Reference_fkey
go

drop index RI_Summary.idx_RIset_fkey
go

drop index RI_Summary_Expt_Ref.idx_RISummary_fkey
go

quit

EOSQL

${newmgddbschema}/index/CRS_Cross_drop.object | tee -a ${LOG}
${newmgddbschema}/index/HMD_Homology_Assay_drop.object | tee -a ${LOG}
${newmgddbschema}/index/HMD_Homology_Marker_drop.object | tee -a ${LOG}
${newmgddbschema}/index/HMD_Homology_drop.object | tee -a ${LOG}
${newmgddbschema}/index/MLD_Expt_Marker_drop.object | tee -a ${LOG}
${newmgddbschema}/index/MLD_FISH_drop.object | tee -a ${LOG}
${newmgddbschema}/index/MLD_FISH_Region_drop.object | tee -a ${LOG}
${newmgddbschema}/index/MLD_InSitu_drop.object | tee -a ${LOG}
${newmgddbschema}/index/MLD_ISRegion_drop.object | tee -a ${LOG}
${newmgddbschema}/index/MLD_MC2point_drop.object | tee -a ${LOG}
${newmgddbschema}/index/MLD_MCDataList_drop.object | tee -a ${LOG}
${newmgddbschema}/index/MLD_RI2Point_drop.object | tee -a ${LOG}
${newmgddbschema}/index/MRK_Classes_drop.object | tee -a ${LOG}
${newmgddbschema}/index/MRK_Current_drop.object | tee -a ${LOG}
${newmgddbschema}/index/PRB_Allele_drop.object | tee -a ${LOG}
${newmgddbschema}/index/PRB_Allele_Strain_drop.object | tee -a ${LOG}
${newmgddbschema}/index/PRB_RFLV_drop.object | tee -a ${LOG}
${newmgddbschema}/index/RI_Summary_drop.object | tee -a ${LOG}
${newmgddbschema}/index/RI_Summary_Expt_Ref_drop.object | tee -a ${LOG}

${newmgddbschema}/index/CRS_Cross_create.object | tee -a ${LOG}
${newmgddbschema}/index/HMD_Homology_Assay_create.object | tee -a ${LOG}
${newmgddbschema}/index/HMD_Homology_Marker_create.object | tee -a ${LOG}
${newmgddbschema}/index/HMD_Homology_create.object | tee -a ${LOG}
${newmgddbschema}/index/MLD_Expt_Marker_create.object | tee -a ${LOG}
${newmgddbschema}/index/MLD_FISH_create.object | tee -a ${LOG}
${newmgddbschema}/index/MLD_FISH_Region_create.object | tee -a ${LOG}
${newmgddbschema}/index/MLD_InSitu_create.object | tee -a ${LOG}
${newmgddbschema}/index/MLD_ISRegion_create.object | tee -a ${LOG}
${newmgddbschema}/index/MLD_MC2point_create.object | tee -a ${LOG}
${newmgddbschema}/index/MLD_MCDataList_create.object | tee -a ${LOG}
${newmgddbschema}/index/MLD_RI2Point_create.object | tee -a ${LOG}
${newmgddbschema}/index/MRK_Classes_create.object | tee -a ${LOG}
${newmgddbschema}/index/MRK_Current_create.object | tee -a ${LOG}
${newmgddbschema}/index/PRB_Allele_create.object | tee -a ${LOG}
${newmgddbschema}/index/PRB_Allele_Strain_create.object | tee -a ${LOG}
${newmgddbschema}/index/PRB_RFLV_create.object | tee -a ${LOG}
${newmgddbschema}/index/RI_Summary_create.object | tee -a ${LOG}
${newmgddbschema}/index/RI_Summary_Expt_Ref_create.object | tee -a ${LOG}

date | tee -a  ${LOG}

