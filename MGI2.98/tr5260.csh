#!/bin/csh -f

#
# Migration for TR 5260
#

cd `dirname $0` && source ./Configuration

setenv LOG $0.log
rm -rf $LOG
touch $LOG
 
date | tee -a $LOG
 
${newmgddbschema}/index/GXD_Index_drop.object | tee -a $LOG
${newmgddbschema}/index/GXD_Index_create.object | tee -a $LOG

date | tee -a $LOG

