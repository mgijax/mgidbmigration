#!/bin/csh -f

#
# Migration for SEQ_Marker_Cache
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

date | tee -a $LOG

