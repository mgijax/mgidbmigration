#!/bin/csh -f

#
# Load Sets
#

cd `dirname $0` && source ./Configuration

setenv LOG $0.log
rm -rf $LOG
touch $LOG
 
date >> $LOG
echo "Set Migration..." | tee -a $LOG
 
${SETLOAD}/runnamedsource.csh >>& $LOG

date >> $LOG
