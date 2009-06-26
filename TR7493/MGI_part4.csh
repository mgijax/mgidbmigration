#!/bin/csh -fx

#
# Migration part 4 for TR7493 -- gene trap LF
#

###----------------------###
###--- initialization ---###
###----------------------###

source ../Configuration

# start a new log file for this migration, and add a datestamp

setenv LOG $0.log.$$
rm -rf ${LOG}
touch ${LOG}

###-------------------------------------------###
###--- generate gbrowse genetrap gff files ---###
###-------------------------------------------###

date | tee -a ${LOG}
echo 'Generate Gbrowse GeneTrap gff files' | tee -a ${LOG}
${GBROWSEUTILS}/bin/generateGTReports.sh
echo ${GBROWSEUTILS}

###-----------------------###
###--- final datestamp ---###
###-----------------------###

date | tee -a ${LOG}
echo "--- Finished" | tee -a ${LOG}
