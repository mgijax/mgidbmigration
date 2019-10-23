#!/bin/csh -fx

if ( ${?MGICONFIG} == 0 ) then
        setenv MGICONFIG /usr/local/mgi/live/mgiconfig
endif

source ${MGICONFIG}/master.config.csh
echo "${PG_DBSERVER} ${PG_DBNAME}"
cd `dirname $0`

setenv LOG $0.log
rm -rf $LOG
touch $LOG

date | tee -a $LOG

./tr13183.py >& $LOG

date | tee -a $LOG
