#!/bin/csh -fx

#
# Migration for M&M project
# (part 2 - run loads)
#
# Products:
# fearload
#

###----------------------###
###--- initialization ---###
###----------------------###

cd `dirname $0` && source ../Configuration
setenv CWD `pwd`	# current working directory
echo "Server: ${MGD_DBSERVER}"
echo "Database: ${MGD_DBNAME}"

# start a new log file for this migration, and add a datestamp

setenv LOG $0.log.$$
rm -rf ${LOG}
touch ${LOG}
date | tee -a ${LOG}
echo "--- Starting in ${CWD}..." | tee -a ${LOG}

date | tee -a ${LOG}
echo "--- Run HGNC Load ---" | tee -a ${LOG}
${HOMOLOGYLOAD}/bin/homologyload.sh hgncload.config

date | tee -a ${LOG}
echo "--- Run Hybrid HGNC/HomoloGene Load ---" | tee -a ${LOG}
${HOMOLOGYLOAD}/bin/homologyload.sh hybridload.config

date | tee -a ${LOG}
echo "--- Run ZFIN Load ---" | tee -a ${LOG}
${HOMOLOGYLOAD}/bin/homologyload.sh zfinload.config

date | tee -a ${LOG}
echo "--- Run GEISHA Load ---" | tee -a ${LOG}
${HOMOLOGYLOAD}/bin/homologyload.sh geishaload.config

date | tee -a ${LOG}
