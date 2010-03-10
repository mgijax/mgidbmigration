#!/bin/csh -fx

#
# Migration part 4 for TR9782 -- MGI 4.33
#

###----------------------###
###--- initialization ---###
###----------------------###

source ../Configuration

# start a new log file for this migration, and add a datestamp

setenv LOG $0.log.$$
rm -rf ${LOG}
touch ${LOG}

###----------------------------------###
###--- generate gbrowse gff files ---###
###----------------------------------###

date | tee -a ${LOG}
echo 'Generate Gbrowse GeneTrap gff files' | tee -a ${LOG}
${GBROWSEUTILS}/bin/generateReports.sh
echo ${GBROWSEUTILS}

###-----------------------###
###--- final datestamp ---###
###-----------------------###

date | tee -a ${LOG}
echo "--- Finished" | tee -a ${LOG}
