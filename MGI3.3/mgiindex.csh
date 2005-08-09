#!/bin/csh -f

#
#
#

cd `dirname $0` && source ./Configuration

setenv LOG $0.log
rm -rf ${LOG}
touch ${LOG}
 
date | tee -a ${LOG}

echo "Drop Indexes..." | tee -a ${LOG}
${oldmgddbschema}/index/index_drop.csh | tee -a ${LOG}

echo "Build Indexes..." | tee -a ${LOG}
${newmgddbschema}/index/index_create.csh | tee -a ${LOG}

echo "Update Statistics..." | tee -a ${LOG}
${DBUTILSBINDIR}/updateStatisticsAll.csh ${newmgddbschema} | tee -a ${LOG}

date | tee -a $LOG

