#!/bin/csh -f

#
# Migration for: PRB_Probe
#

cd `dirname $0` && source ./Configuration

setenv LOG $0.log
rm -rf ${LOG}
touch ${LOG}
 
date >> ${LOG}
echo "PRB_Probe Migration..." | tee -a ${LOG}

cat - <<EOSQL | doisql.csh $0 >> ${LOG}

use ${DBNAME}
go

sp_rename PRB_Probe, PRB_Probe_Old
go

sp_rename PRB_Reference, PRB_Reference_Old
go

end

EOSQL

#
# create new tables
#
${newmgddbschema}/table/PRB_Probe_create.object >> ${LOG}
${newmgddbschema}/default/PRB_Probe_bind.object >> ${LOG}
${newmgddbschema}/table/PRB_Reference_create.object >> ${LOG}
${newmgddbschema}/default/PRB_Reference_bind.object >> ${LOG}

cat - <<EOSQL | doisql.csh $0 >> ${LOG}

use ${DBNAME}
go

insert into PRB_Probe
select _Probe_key, name, derivedFrom, 
_Source_key, _Vector_key, _SegmentType_key,
primer1Sequence, primer2Sequence, regionCovered, insertSite, insertSize, productSize,
_CreatedBy_key, _ModifiedBy_key, creation_date, modification_date
from PRB_Probe_Old
go

insert into PRB_Reference
select _Reference_key, _Probe_key, _Refs_key, hasRmap, hasSequence, 
_CreatedBy_key, _ModifiedBy_key, creation_date, modification_date
from PRB_Reference_Old
go

checkpoint
go

quit

EOSQL

${newmgddbschema}/partition/PRB_Probe_create.object >> ${LOG}
${newmgddbschema}/index/PRB_Probe_create.object >> ${LOG}
${newmgddbschema}/index/PRB_Reference_create.object >> ${LOG}

${newmgddbschema}/key/BIB_Refs_drop.object >> ${LOG}
${newmgddbschema}/key/BIB_Refs_create.object >> ${LOG}
${newmgddbschema}/key/GXD_ProbePrep_drop.object >> ${LOG}
${newmgddbschema}/key/GXD_ProbePrep_create.object >> ${LOG}
${newmgddbschema}/key/MGI_User_drop.object >> ${LOG}
${newmgddbschema}/key/MGI_User_create.object >> ${LOG}
${newmgddbschema}/key/MLD_ContigProbe_drop.object >> ${LOG}
${newmgddbschema}/key/MLD_ContigProbe_create.object >> ${LOG}
${newmgddbschema}/key/MLD_Hit_drop.object >> ${LOG}
${newmgddbschema}/key/MLD_Hit_create.object >> ${LOG}
${newmgddbschema}/key/PRB_Marker_drop.object >> ${LOG}
${newmgddbschema}/key/PRB_Marker_create.object >> ${LOG}
${newmgddbschema}/key/PRB_Notes_drop.object >> ${LOG}
${newmgddbschema}/key/PRB_Notes_create.object >> ${LOG}
${newmgddbschema}/key/PRB_Probe_drop.object >> ${LOG}
${newmgddbschema}/key/PRB_Probe_create.object >> ${LOG}
${newmgddbschema}/key/PRB_Reference_drop.object >> ${LOG}
${newmgddbschema}/key/PRB_Reference_create.object >> ${LOG}
${newmgddbschema}/key/PRB_Source_drop.object >> ${LOG}
${newmgddbschema}/key/PRB_Source_create.object >> ${LOG}
${newmgddbschema}/key/SEQ_Probe_Cache_drop.object >> ${LOG}
${newmgddbschema}/key/SEQ_Probe_Cache_create.object >> ${LOG}
${newmgddbschema}/key/VOC_Term_drop.object >> ${LOG}
${newmgddbschema}/key/VOC_Term_create.object >> ${LOG}

${newmgddbschema}/trigger/BIB_Refs_drop.object >> ${LOG}
${newmgddbschema}/trigger/BIB_Refs_create.object >> ${LOG}
${newmgddbschema}/trigger/PRB_Marker_drop.object >> ${LOG}
${newmgddbschema}/trigger/PRB_Marker_create.object >> ${LOG}
${newmgddbschema}/trigger/PRB_Probe_drop.object >> ${LOG}
${newmgddbschema}/trigger/PRB_Probe_create.object >> ${LOG}
${newmgddbschema}/trigger/PRB_Reference_drop.object >> ${LOG}
${newmgddbschema}/trigger/PRB_Reference_create.object >> ${LOG}
${newmgddbschema}/trigger/PRB_Source_drop.object >> ${LOG}
${newmgddbschema}/trigger/PRB_Source_create.object >> ${LOG}
${newmgddbschema}/trigger/VOC_Term_drop.object >> ${LOG}
${newmgddbschema}/trigger/VOC_Term_create.object >> ${LOG}

${newmgddbschema}/procedure/ACC_verifySequenceAnnotation_drop.object >> ${LOG}
${newmgddbschema}/procedure/ACC_verifySequenceAnnotation_create.object >> ${LOG}
${newmgddbschema}/procedure/BIB_PRB_Exists_drop.object >> ${LOG}
${newmgddbschema}/procedure/BIB_PRB_Exists_create.object >> ${LOG}
${newmgddbschema}/procedure/MLP_mergeStrain_drop.object >> ${LOG}
${newmgddbschema}/procedure/MLP_mergeStrain_create.object >> ${LOG}
${newmgddbschema}/procedure/MRK_deleteIMAGESeqAssoc_drop.object >> ${LOG}
${newmgddbschema}/procedure/MRK_deleteIMAGESeqAssoc_create.object >> ${LOG}
${newmgddbschema}/procedure/MRK_updateIMAGESeqAssoc_drop.object >> ${LOG}
${newmgddbschema}/procedure/MRK_updateIMAGESeqAssoc_create.object >> ${LOG}
${newmgddbschema}/procedure/MRK_reloadReference_drop.object >> ${LOG}
${newmgddbschema}/procedure/MRK_reloadReference_create.object >> ${LOG}
${newmgddbschema}/procedure/PRB_drop.logical >> ${LOG}
${newmgddbschema}/procedure/PRB_create.logical >> ${LOG}
${newmgddbschema}/procedure/SEQ_createDummy_drop.object >> ${LOG}
${newmgddbschema}/procedure/SEQ_createDummy_create.object >> ${LOG}
${newmgddbschema}/procedure/SEQ_deleteObsoleteDummy_drop.object >> ${LOG}
${newmgddbschema}/procedure/SEQ_deleteObsoleteDummy_create.object >> ${LOG}

${newmgddbschema}/view/GXD_ProbePrep_View_drop.object >> ${LOG}
${newmgddbschema}/view/GXD_ProbePrep_View_create.object >> ${LOG}
${newmgddbschema}/view/MLD_Hit_View_drop.object >> ${LOG}
${newmgddbschema}/view/MLD_Hit_View_create.object >> ${LOG}
${newmgddbschema}/view/PRB_drop.logical >> ${LOG}
${newmgddbschema}/view/PRB_create.logical >> ${LOG}
${newmgddbschema}/view/SEQ_Probe_Cache_View_drop.object >> ${LOG}
${newmgddbschema}/view/SEQ_Probe_Cache_View_create.object >> ${LOG}

date >> ${LOG}

