#!/bin/csh -f

#
# Migration for: Alleles (TR 5750)
#

cd `dirname $0` && source ./Configuration

setenv LOG $0.log
rm -rf ${LOG}
touch ${LOG}
 
date >> ${LOG}
echo 'Set Migration...' | tee -a ${LOG}

cat - <<EOSQL | doisql.csh $0 >> ${LOG}

use ${DBNAME}
go

sp_rename MGI_Set, MGI_Set_Old
go

end

EOSQL

${newmgddbschema}/table/MGI_Set_create.object | tee -a ${LOG}

${newmgddbschema}/key/MGI_Set_create.object | tee -a ${LOG}
${newmgddbschema}/key/MGI_SetMember_drop.object | tee -a ${LOG}
${newmgddbschema}/key/MGI_SetMember_create.object | tee -a ${LOG}
${newmgddbschema}/key/MGI_User_drop.object | tee -a ${LOG}
${newmgddbschema}/key/MGI_User_create.object | tee -a ${LOG}

${newmgddbschema}/index/MGI_Set_create.object | tee -a ${LOG}

${newmgddbschema}/trigger/MGI_Set_drop.object | tee -a ${LOG}
${newmgddbschema}/trigger/MGI_Set_create.object | tee -a ${LOG}
${newmgddbschema}/trigger/PRB_Probe_drop.object | tee -a ${LOG}
${newmgddbschema}/trigger/PRB_Probe_create.object | tee -a ${LOG}
${newmgddbschema}/trigger/PRB_Source_drop.object | tee -a ${LOG}
${newmgddbschema}/trigger/PRB_Source_create.object | tee -a ${LOG}
${newmgddbschema}/trigger/SEQ_Sequence_drop.object | tee -a ${LOG}
${newmgddbschema}/trigger/SEQ_Sequence_create.object | tee -a ${LOG}

${newmgddbschema}/view/MGI_Set_CloneLibrary_View_drop.object | tee -a ${LOG}
${newmgddbschema}/view/MGI_Set_CloneLibrary_View_create.object | tee -a ${LOG}
${newmgddbschema}/view/MGI_Set_CloneSet_View_drop.object | tee -a ${LOG}
${newmgddbschema}/view/MGI_Set_CloneSet_View_create.object | tee -a ${LOG}
${newmgddbschema}/view/MGI_Set_ResMolSeg_View_drop.object | tee -a ${LOG}
${newmgddbschema}/view/MGI_Set_ResMolSeg_View_create.object | tee -a ${LOG}
${newmgddbschema}/view/MGI_Set_ResSequence_View_drop.object | tee -a ${LOG}
${newmgddbschema}/view/MGI_Set_ResSequence_View_create.object | tee -a ${LOG}

${newmgddbschema}/procedure/MGI_createRestrictedMolSegSet_drop.object | tee -a ${LOG}
${newmgddbschema}/procedure/MGI_createRestrictedMolSegSet_create.object | tee -a ${LOG}
${newmgddbschema}/procedure/MGI_createRestrictedSeqSet_drop.object | tee -a ${LOG}
${newmgddbschema}/procedure/MGI_createRestrictedSeqSet_create.object | tee -a ${LOG}

cat - <<EOSQL | doisql.csh $0 >> ${LOG}

use ${DBNAME}
go

insert into MGI_Set
select o._Set_key, o._MGIType_key, o.name, 1, 
o._CreatedBy_key, o._ModifiedBy_key, o.creation_date, o.modification_date
from MGI_Set_Old o
go

update MGI_Set set sequenceNum = 2 where _Set_key = 1004
update MGI_Set set sequenceNum = 3 where _Set_key = 1005
update MGI_Set set sequenceNum = 4 where _Set_key = 1006
update MGI_Set set sequenceNum = 5 where _Set_key = 1007
update MGI_Set set sequenceNum = 6 where _Set_key = 1008
go

end

EOSQL

date >> ${LOG}

