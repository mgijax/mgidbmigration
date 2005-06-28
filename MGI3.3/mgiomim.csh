#!/bin/csh -f

#
# Migration for OMIM
#
# MRK_OMIM_Cache
#

cd `dirname $0` && source ./Configuration

setenv LOG $0.log
rm -rf ${LOG}
touch ${LOG}
 
date | tee -a ${LOG}

echo "OMIM Migration..." | tee -a ${LOG}
 
${newmgddbschema}/table/MRK_OMIM_Cache_create.object | tee -a ${LOG}
${newmgddbschema}/index/MRK_OMIM_Cache_create.object | tee -a ${LOG}
${MRKCACHELOAD}/mrkomim.csh | tee -a ${LOG}

date | tee -a $LOG

