#!/bin/csh -fx

#
# SEQ_Marker_Cache; add primary accID
#

source ./Configuration

setenv LOG	`basename $0`.log
rm -rf $LOG
touch $LOG

date | tee -a ${LOG}

${newmgddbschema}/table/SEQ_Marker_Cache_drop.object | tee -a ${LOG}
${newmgddbschema}/table/SEQ_Marker_Cache_create.object | tee -a ${LOG}
${newmgddbschema}/default/SEQ_Marker_Cache_bind.object | tee -a ${LOG}
${newmgddbschema}/key/SEQ_Marker_Cache_create.object | tee -a ${LOG}
${newmgddbperms}/public/table/SEQ_Marker_Cache_grant.object | tee -a ${LOG}

# load new table

${SEQCACHELOAD} | tee -a ${LOG}

date | tee -a ${LOG}

