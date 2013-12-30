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

cd ${DBUTILS}/mgidbmigration/TR11515/allelecollection

# start a new log file for this migration, and add a datestamp

setenv LOG $0.log
rm -rf ${LOG}
touch ${LOG}

./allelecollectionTests.py | tee -a ${LOG}

rm -rf allelecollectionTests.csh.log.sorted
sort allelecollectionTests.csh.log > allelecollectionTests.csh.log.sorted

date | tee -a ${LOG}
echo "--- Finished" | tee -a ${LOG}

