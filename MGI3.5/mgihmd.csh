#!/bin/csh -fx

#
# TR 7606/add MRK_Homology_Cache
#

source ./Configuration

setenv LOG	`basename $0`.log
rm -rf $LOG
touch $LOG

date | tee -a ${LOG}

${newmgddbschema}/table/MRK_Homology_Cache_create.object | tee -a ${LOG}
${newmgddbschema}/key/MRK_Homology_Cache_create.object | tee -a ${LOG}
${newmgddbschema}/index/MRK_Homology_Cache_create.object | tee -a ${LOG}

${HOMCACHELOAD} | tee -a ${LOG}

date | tee -a ${LOG}

