#!/bin/csh -f

if ( ${?MGICONFIG} == 0 ) then
        setenv MGICONFIG /usr/local/mgi/live/mgiconfig
endif

source ${MGICONFIG}/master.config.csh

cd `dirname $0`

setenv LOG $0.log
rm -rf $LOG
touch $LOG
 
date | tee -a $LOG
 
$PYTHON case1.py | tee -a $LOG
$PYTHON case2.py | tee -a $LOG
$PYTHON case3.py | tee -a $LOG

date |tee -a $LOG

