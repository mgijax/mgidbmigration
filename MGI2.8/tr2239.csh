#!/bin/csh -f

#
# Migration for TR 2239
#

cd `dirname $0`

setenv LOG $0.log
rm -rf $LOG
touch $LOG
 
date >> $LOG
 
tr2239cleanup.py $DBSERVER $DBNAME

date >> $LOG

