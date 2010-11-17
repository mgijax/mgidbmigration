#!/bin/csh -f

#
# Template
#

source ../Configuration

cd `dirname $0`

setenv LOG $0.log
rm -rf $LOG
touch $LOG
 
date | tee -a $LOG
./migratenotes.py | tee -a $LOG 
date |tee -a $LOG

