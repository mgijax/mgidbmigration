#!/bin/csh -fx

#
# Migration part 2 for TR9924
#

###----------------------###
###--- initialization ---###
###----------------------###

source ../Configuration

# start a new log file for this migration, and add a datestamp

setenv LOG $0.log.$$
rm -rf ${LOG}
touch ${LOG}

###------------------------###
###--- run arrayexpload ---###
###------------------------###
date | tee -a ${LOG}
echo 'Running Array Express Load' | tee -a ${LOG}
${ARRAYEXPLOAD}/bin/arrayexpload.sh

###-----------------------###
###--- final datestamp ---###
###-----------------------###

date | tee -a ${LOG}
echo "--- Finished" | tee -a ${LOG}
