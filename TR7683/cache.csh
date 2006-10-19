#!/bin/csh -f

#
# TR 6812/cache tables
#
# Usage:  cache.csh
#

cd `dirname $0` && source ./Configuration

setenv LOG `basename $0`.log

rm -rf ${LOG}
touch ${LOG}
 
date >> ${LOG}

${MGD_DBSCHEMADIR}/table/BIB_Citation_Cache_create.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/default/BIB_Citation_Cache_bind.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/key/BIB_Citation_Cache_create.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/index/BIB_Citation_Cache_create.object | tee -a ${LOG}
${MGICACHELOAD}/bibcitation.csh | tee -a ${LOG}

date >> ${LOG}

