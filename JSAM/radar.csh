#!/bin/csh -f

#
# Migration for RADAR
#

cd `dirname $0` && source ./Configuration

setenv LOG $0.log
rm -rf $LOG
touch $LOG
 
date >> $LOG
echo "RADAR Migration..." | tee -a $LOG
 
#
# Use new schema product to create new table
#
${newrdrdbschema}/table/QC_MS_AttrEdit_create.object >> $LOG
${newrdrdbschema}/table/QC_MS_NameConflict_create.object >> $LOG
${newrdrdbschema}/table/QC_MS_NoLibFound_create.object >> $LOG
${newrdrdbschema}/index/QC_MS_AttrEdit_create.object >> $LOG
${newrdrdbschema}/index/QC_MS_NameConflict_create.object >> $LOG
${newrdrdbschema}/index/QC_MS_NoLibFound_create.object >> $LOG
${newrdrdbschema}/key/QC_MS_AttrEdit_create.object >> $LOG
${newrdrdbschema}/key/QC_MS_NameConflict_create.object >> $LOG
${newrdrdbschema}/key/QC_MS_NoLibFound_create.object >> $LOG
${newrdrdbschema}/key/APP_JobStream_drop.object >> $LOG
${newrdrdbschema}/key/APP_JobStream_create.object >> $LOG

${newrdrdbperms}/developers/table/QC_grant.logical >> $LOG
${newrdrdbperms}/public/table/QC_grant.logical >> $LOG

date >> $LOG

