#!/bin/csh -fx

#
# Migration for TR11515
# (part 2 - run data loads
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
# alleleload
#

#
# targeted allele load
#

#
# gene trap load
#

date | tee -a ${LOG}
echo "--- Finished" | tee -a ${LOG}
