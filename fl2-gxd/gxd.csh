#!/bin/csh -f

#
# mgidbutilities/fl2-gxd
# littriageload
# autolittriage : figureText.py
# MLtestTools   : utilLib.py
#

if ( ${?MGICONFIG} == 0 ) then
        setenv MGICONFIG /usr/local/mgi/live/mgiconfig
endif

source ${MGICONFIG}/master.config.csh

cd `dirname $0`

setenv LOG $0.log
rm -rf $LOG
touch $LOG
 
date | tee -a $LOG

./vocabulary.csh | tee -a $LOG

#rm -rf ${DATALOADSOUTPUT}/mgi/littriageload/logs/secondary.GXD.log
mkdir ${DATALOADSOUTPUT}/mgi/littriageload/logs/gxd

date |tee -a $LOG

