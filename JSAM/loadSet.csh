#!/bin/csh -f

#
# Load Sets
#

cd `dirname $0` && source ./Configuration
cd setload

setenv LOG $0.log
rm -rf ${LOG}
touch ${LOG}
 
date >> ${LOG}
echo "Set Migration..." | tee -a ${LOG}
 
${SETLOAD}/setload.csh ${newmgddbschema} cloneset.txt load >>& ${LOG}
${SETLOAD}/setload.csh ${newmgddbschema} actualDBset.txt load >>& ${LOG}

date >> ${LOG}
