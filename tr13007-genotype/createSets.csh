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
 
./createSets.py
${SETLOAD}/setload.csh  EASet.config
${SETLOAD}/setload.csh  RNASeqSet.config

date |tee -a $LOG

