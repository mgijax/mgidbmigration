#!/bin/csh -fx

# clean up views
# remove views that are no longer useD
#
# Views  244
#	- 29
#	----
#	 215
#
# ei-
# reports_db-
# qcreports_db-
# lib_py_dataload
# seqcacheload-
#	- VOC_Term_RepQualifier_View
# mgddbschema-
#	- must 'cvs remove the views below, then tag
#

cd `dirname $0` && source ../Configuration

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
drop view VOC_Term_GOProperty_View
drop view VOC_Term_GXDIndexCondMut_View
drop view VOC_Term_IMGClass_View
drop view VOC_Term_IMGType_View
drop view VOC_Term_NeedsReview_View
drop view VOC_Term_NomenStatus_View
drop view VOC_Term_SequenceProvider_View
drop view VOC_Term_SequenceQuality_View
drop view VOC_Term_SequenceStatus_View
drop view VOC_Term_SequenceType_View
drop view VOC_Term_SegVectorType_View
drop view VOC_Term_StrainAllele_View
drop view VOC_Term_StrainGenoQual_View
drop view VOC_Term_StrainSpecies_View
drop view VOC_Term_StrainType_View
drop view VOC_Term_UserRole_View
drop view VOC_Term_UserTask_View
drop view VOC_Term_StrainAttribute_View
drop view VOC_Term_ALLTransmission_View
drop view VOC_Term_ALLStatus_View
drop view VOC_Term_ALLPairState_View
drop view VOC_Term_ALLInheritMode_View
go

/* 11, 12, 13, 14 */
drop view VOC_Term_GXDIndexPriority_View
drop view VOC_Term_GXDIndexAssay_View
drop view VOC_Term_GXDIndexStage_View
drop view VOC_Term_GXDReporterGene_View
go

checkpoint
go

quit

EOSQL

date | tee -a ${LOG}
echo "--- Re-setting permissions/schema ---"
#${MGD_DBSCHEMADIR}/reconfig.csh | tee -a ${LOG}
${MGD_DBSCHEMADIR}/all_perms.csh | tee -a ${LOG}


