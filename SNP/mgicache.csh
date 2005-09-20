#!/bin/csh -f

#
# Migration for SEQ_Marker_Cache, Human/Rat EntrezGene load, HomoloGene
#
#

cd `dirname $0` && source ./Configuration

setenv LOG $0.log
rm -rf ${LOG}
touch ${LOG}
 
date | tee -a ${LOG}

echo "Cache Migration..." | tee -a ${LOG}
 
${newmgddbschema}/table/SEQ_Marker_Cache_drop.object | tee -a ${LOG}
${newmgddbschema}/table/SEQ_Marker_Cache_create.object | tee -a ${LOG}
${newmgddbschema}/index/SEQ_Marker_Cache_create.object | tee -a ${LOG}
${newmgddbschema}/default/SEQ_Marker_Cache_bind.object | tee -a ${LOG}

${newmgddbschema}/procedure/MRK_reloadSequence_drop.object | tee -a ${LOG}
${newmgddbschema}/procedure/MRK_reloadSequence_create.object | tee -a ${LOG}
${newmgddbschema}/procedure/SEQ_loadMarkerCache_drop.object | tee -a ${LOG}
${newmgddbschema}/procedure/SEQ_loadMarkerCache_create.object | tee -a ${LOG}

${newmgddbschema}/view/SEQ_Marker_Cache_View_drop.object | tee -a ${LOG}
${newmgddbschema}/view/SEQ_Marker_Cache_View_create.object | tee -a ${LOG}

${EGLOAD}/human/load.csh | tee -a ${LOG}
${EGLOAD}/rat/load.csh | tee -a ${LOG}
#${SEQCACHELOAD}/seqmarker.csh | tee -a ${LOG}

date | tee -a $LOG

