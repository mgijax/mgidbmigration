#!/bin/csh -f

#
# TR 4460/MIT Coordinates
#
# Usage:  mgimit.csh
#

cd `dirname $0` && source ./Configuration

setenv LOG `basename $0`.log

rm -rf ${LOG}
touch ${LOG}
 
date >> ${LOG}

${newmgddbschema}/table/MRK_Location_Cache_drop.object | tee -a ${LOG}
${newmgddbschema}/table/MRK_Location_Cache_create.object | tee -a ${LOG}
${LOCCACHELOAD} | tee -a ${LOG}

date >> ${LOG}

