#!/bin/csh -f

#
# Migration for WKS_Rosetta
#

cd `dirname $0` && source ./Configuration

setenv LOG $0.log
rm -rf $LOG
touch $LOG
 
date | tee -a $LOG
 
#
# Use new schema product to create new table
#
${newmgddbschema}/table/WKS_Rosetta_drop.object | tee -a $LOG
${newmgddbschema}/view/WKS_Rosetta_View_drop.object | tee -a $LOG
${newmgddbschema}/table/WKS_Rosetta_create.object | tee -a $LOG
${newmgddbschema}/default/WKS_Rosetta_bind.object | tee -a $LOG
${newmgddbschema}/index/WKS_Rosetta_create.object | tee -a $LOG
${newmgddbschema}/key/WKS_Rosetta_create.object | tee -a $LOG
${newmgddbschema}/view/WKS_Rosetta_View_create.object | tee -a $LOG

$WKSLOAD/wksload.csh

date | tee -a $LOG

