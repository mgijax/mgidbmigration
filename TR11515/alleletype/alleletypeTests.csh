#!/bin/csh -fx

#
# Migration for TR11515
#
#

###----------------------###
###--- initialization ---###
###----------------------###

if ( ${?MGICONFIG} == 0 ) then
	setenv MGICONFIG /usr/local/mgi/live/mgiconfig
endif

source ${MGICONFIG}/master.config.csh

cd ${DBUTILS}/mgidbmigration/TR11515/alleletype

# start a new log file for this migration, and add a datestamp

setenv LOG ${DBUTILS}/mgidbmigration/TR11515/alleletype/alleletypeTests.csh.log
rm -rf ${LOG}
touch ${LOG}

./alleletypeTests.py | tee -a ${LOG}

rm -rf alleletypeTests.csh.log.sorted
sort alleletypeTests.csh.log > alleletypeTests.csh.log.sorted

date | tee -a ${LOG}
echo "--- Finished" | tee -a ${LOG}

