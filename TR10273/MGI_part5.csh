#!/bin/csh -fx

#
# Migration for TR10273 -- Europhenome/Sanger MP annotations
# (part 5)
#
# 1. run mirror_wget to download the most recent Sanger BioMart file
# 2. run Sanger BioMart dataload
#
# all other test data is retained
#

###----------------------###
###--- initialization ---###
###----------------------###

source ../Configuration

# start a new log file for this migration, and add a datestamp

setenv LOG $0.log.$$
rm -rf ${LOG}
touch ${LOG}

# run mirror_wget to download the latest Sanger BioMart file
#
echo ${MIRROR_WGET}/www.sanger.ac.uk5 | tee -a ${LOG}
${MIRROR_WGET}/www.sanger.ac.uk5 | tee -a ${LOG}

# run htmpload
# make sure factory settings
echo ${HTMPLOAD}/bin/sangermpload.sh | tee -a ${LOG}
${HTMPLOAD}/bin/sangermpload.sh | tee -a ${LOG}

###-----------------------###
###--- final datestamp ---###
###-----------------------###

date | tee -a ${LOG}
echo "--- Finished" | tee -a ${LOG}
