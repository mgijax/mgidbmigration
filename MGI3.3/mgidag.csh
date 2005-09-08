#!/bin/csh -f

#
# Migration for DAG_Closure
#
#

cd `dirname $0` && source ./Configuration

setenv LOG $0.log
rm -rf ${LOG}
touch ${LOG}
 
date | tee -a ${LOG}

echo "DAG Migration..." | tee -a ${LOG}
 
${newmgddbschema}/table/DAG_Closure_drop.object | tee -a ${LOG}
${newmgddbschema}/table/DAG_Closure_create.object | tee -a ${LOG}
${newmgddbschema}/index/DAG_Closure_create.object | tee -a ${LOG}
${newmgddbschema}/default/DAG_Closure_bind.object | tee -a ${LOG}

date | tee -a $LOG

