#!/bin/csh -fx

#
#
#  TR9139 - biotype mismatch
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

#${SEQCACHELOAD}/seqmarker.csh | tee -a ${LOG}

date | tee -a  ${LOG}

