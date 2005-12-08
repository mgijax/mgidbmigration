#!/bin/csh -f

#
# Add MGI ID, J#, PubMed IDs to MRK_Reference cache table
#
# Usage:  mgiref.csh
#

cd `dirname $0` && source ./Configuration

setenv LOG `basename $0`.log

rm -rf ${LOG}
touch ${LOG}
 
date >> ${LOG}

${newmgddbschema}/table/MRK_Reference_drop.object | tee -a ${LOG}
${newmgddbschema}/table/MRK_Reference_create.object | tee -a ${LOG}
${newmgddbschema}/default/MRK_Reference_bind.object | tee -a ${LOG}
${newmgddbperms}/public/table/MRK_Reference_grant.object | tee -a ${LOG}

${REFCACHELOAD} | tee -a ${LOG}

date >> ${LOG}

