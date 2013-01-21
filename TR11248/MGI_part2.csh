#!/bin/csh -fx

#
# Migration for TR11248
# (part 2 running loads)
#
#

###----------------------###
###--- initialization ---###
###----------------------###

source ../Configuration

# start a new log file for this migration, and add a datestamp

setenv LOG $0.log.$$
rm -rf ${LOG}
touch ${LOG}

date | tee -a ${LOG}

###-----------------------###
###--- final datestamp ---###
###-----------------------###
date | tee -a ${LOG}
echo "--- Finished" | tee -a ${LOG}

