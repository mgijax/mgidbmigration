#!/bin/csh -f

#
# Migration for MGI Assembly
#

cd `dirname $0` && source ./Configuration

setenv LOG $0.log
rm -rf ${LOG}
touch ${LOG}
 
date | tee -a ${LOG}
echo "MGI Assembly Migration..." | tee -a ${LOG}
 
# MAP_

${newmgddbschema}/table/MAP_drop.logical | tee -a ${LOG}
${newmgddbschema}/table/MAP_create.logical | tee -a ${LOG}
${newmgddbschema}/default/MAP_bind.logical | tee -a ${LOG}
${newmgddbschema}/index/MAP_create.logical | tee -a ${LOG}
${newmgddbschema}/key/MAP_create.logical | tee -a ${LOG}

# SEQ_

${newmgddbschema}/table/SEQ_Coord_Cache_drop.object | tee -a ${LOG}
${newmgddbschema}/table/SEQ_Coord_Cache_create.object | tee -a ${LOG}
${newmgddbschema}/default/SEQ_Coord_Cache_bind.object | tee -a ${LOG}
${newmgddbschema}/index/SEQ_Coord_Cache_create.object | tee -a ${LOG}

${newmgddbschema}/table/SEQ_Marker_Cache_drop.object | tee -a ${LOG}
${newmgddbschema}/table/SEQ_Marker_Cache_create.object | tee -a ${LOG}
${newmgddbschema}/default/SEQ_Marker_Cache_bind.object | tee -a ${LOG}
${newmgddbschema}/index/SEQ_Marker_Cache_create.object | tee -a ${LOG}

${newmgddbschema}/table/MRK_CuratedRepSequence_create.object | tee -a ${LOG}
${newmgddbschema}/default/MRK_CuratedRepSequence_bind.object | tee -a ${LOG}
${newmgddbschema}/index/MRK_CuratedRepSequence_create.object | tee -a ${LOG}

${newmgddbschema}/view/SEQ_Marker_Cache_View_drop.object | tee -a ${LOG}
${newmgddbschema}/view/SEQ_Marker_Cache_View_create.object | tee -a ${LOG}
${newmgddbschema}/view/VOC_Term_RepQualifier_View_create.object | tee -a ${LOG}
${newmgddbschema}/procedure/SEQ_deriveRepByMarker_create.object | tee -a ${LOG}
${newmgddbschema}/procedure/SEQ_deriveRepAll_create.object | tee -a ${LOG}
${newmgddbschema}/procedure/MRK_reloadSequence_drop.object | tee -a ${LOG}
${newmgddbschema}/procedure/MRK_reloadSequence_create.object | tee -a ${LOG}

cat - <<EOSQL | doisql.csh $0 >> ${LOG}

use ${DBNAME}
go

insert into MGI_RefAssocType values(1008, 19, 'Load', 0, '${CREATEDBY}', '${CREATEDBY}', getdate(), getdate())
go

end

EOSQL

date | tee -a ${LOG}

