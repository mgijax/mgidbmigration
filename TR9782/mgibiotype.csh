#!/bin/csh -fx

#
#
#  TR9239 - biotype mismatch
#  TR9239 - changing SEQ_GeneModel._MarkerType_key to _GMMarker_Type_key
#
#  add rawbiotype column
#  add biotype key column
#

cd `dirname $0` && source ../Configuration

setenv LOG $0.log
rm -rf ${LOG}
touch ${LOG}
 
date | tee -a  ${LOG}

${MGD_DBSCHEMADIR}/table/SEQ_Marker_Cache_drop.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/table/SEQ_Marker_Cache_create.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/index/SEQ_Marker_Cache_create.object | tee -a ${LOG}

${MGD_DBSCHEMADIR}/table/SEQ_GeneModel_drop.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/table/SEQ_GeneModel_create.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/index/SEQ_GeneModel_create.object | tee -a ${LOG}

${MGD_DBSCHEMADIR}/key/BIB_Refs_drop.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/key/MGI_User_drop.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/key/MRK_Marker_drop.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/key/MRK_Types_drop.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/key/SEQ_Marker_Cache_drop.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/key/SEQ_Sequence_drop.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/key/VOC_Term_drop.object | tee -a ${LOG}

${MGD_DBSCHEMADIR}/key/BIB_Refs_create.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/key/MGI_User_create.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/key/MRK_Marker_create.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/key/MRK_Types_create.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/key/SEQ_Marker_Cache_create.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/key/SEQ_Sequence_create.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/key/VOC_Term_create.object | tee -a ${LOG}

${MGD_DBSCHEMADIR}/trigger/MRK_Marker_create.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/trigger/SEQ_Allele_Assoc_create.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/trigger/SEQ_Sequence_create.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/trigger/VOC_Term_create.object | tee -a ${LOG}

${MGD_DBSCHEMADIR}/procedure/MRK_reloadLocation_drop.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/procedure/MRK_reloadSequence_drop.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/procedure/NOM_transferToMGD_drop.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/procedure/SEQ_deleteByCreatedBy_drop.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/procedure/SEQ_deleteObsoleteDummy_drop.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/procedure/SEQ_loadMarkerCache_drop.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/procedure/SEQ_split_drop.object | tee -a ${LOG}

${MGD_DBSCHEMADIR}/procedure/MRK_reloadLocation_create.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/procedure/MRK_reloadSequence_create.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/procedure/NOM_transferToMGD_create.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/procedure/SEQ_deleteByCreatedBy_create.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/procedure/SEQ_deleteObsoleteDummy_create.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/procedure/SEQ_loadMarkerCache_create.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/procedure/SEQ_split_create.object | tee -a ${LOG}

#we don't need to add biotype to this view
#${MGD_DBSCHEMADIR}/view/SEQ_Marker_Cache_View_create.object | tee -a ${LOG}

#${SEQCACHELOAD}/seqmarker.csh | tee -a ${LOG}

date | tee -a  ${LOG}

