#!/bin/csh -f

#
# TR 6812/cache tables
#
# Usage:  cache.csh
#

source ../Configuration

setenv LOG `basename $0`.log

rm -rf ${LOG}
touch ${LOG}
 
date >> ${LOG}

${MGD_DBSCHEMADIR}/table/BIB_Citation_Cache_drop.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/table/BIB_Citation_Cache_create.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/key/BIB_Citation_Cache_create.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/index/BIB_Citation_Cache_create.object | tee -a ${LOG}
${MGICACHELOAD}/bibcitation.csh | tee -a ${LOG}

${MGD_DBSCHEMADIR}/table/VOC_GO_Cache_drop.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/table/VOC_GO_Cache_create.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/key/VOC_GO_Cache_create.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/index/VOC_GO_Cache_create.object | tee -a ${LOG}
${MGICACHELOAD}/vocgo.csh | tee -a ${LOG}

date >> ${LOG}

