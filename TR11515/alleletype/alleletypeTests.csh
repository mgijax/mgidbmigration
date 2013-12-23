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

env | grep MGD

# start a new log file for this migration, and add a datestamp

setenv SQLLOG $0.log
rm -rf ${SQLLOG}
touch ${SQLLOG}

./alleletypeTests.py | tee -a ${SQLLOG}

rm -rf alleletypeTests.csh.log.sorted
sort alleletypeTests.csh.log > alleletypeTests.csh.log.sorted

date | tee -a ${SQLLOG}
echo "--- Finished" | tee -a ${SQLLOG}

