#!/bin/csh -f

#
# Migration for MGI 2.3 release patch
#

setenv DSQUERY $1
setenv MGD $2

setenv LOG `pwd`/MGI.log

rm -rf $LOG
touch $LOG
 
date >> $LOG
 
set scripts = $SYBASE/admin

echo "TR 789..." >> $LOG
./tr789.sql $DSQUERY $MGD >>& $LOG

date >> $LOG

