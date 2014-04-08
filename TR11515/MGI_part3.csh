#!/bin/csh -fx

#
# Migration for TR11515
# (part 3 - reports
#

###----------------------###
###--- initialization ---###
###----------------------###

if ( ${?MGICONFIG} == 0 ) then
	setenv MGICONFIG /usr/local/mgi/live/mgiconfig
endif

source ${MGICONFIG}/master.config.csh

# start a new log file for this migration, and add a datestamp

setenv LOG $0.log
rm -rf ${LOG}
touch ${LOG}

#
# update/run MGI_Statistics
#
${DBUTILS}/mgidbmigration/TR11515/alleletype/alleletype-after-stats.csh | tee -a ${LOG}

#
# run some qc/public reports after migration
# use *after* report changes
# only run for testing; do not run during release
#
date | tee -a ${LOG}
./runreports-after.csh | tee -a ${LOG}
date | tee -a ${LOG}

date | tee -a ${LOG}
echo "--- Finished" | tee -a ${LOG}

