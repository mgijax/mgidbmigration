#!/bin/csh -f

#
# Defaults
#

cd `dirname $0` && source ./Configuration

setenv LOG $0.log
rm -rf $LOG
touch $LOG
 
date >> $LOG
echo "Defaults Migration..." | tee -a $LOG
 
${oldmgddbschema}/default/default_unbind.csh | tee -a ${LOG}
${oldmgddbschema}/default/default_drop.csh | tee -a ${LOG}
${newmgddbschema}/default/default_create.csh | tee -a ${LOG}
${newmgddbschema}/default/default_bind.csh | tee -a ${LOG}

date >> $LOG

