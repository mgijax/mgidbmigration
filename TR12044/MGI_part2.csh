#!/bin/csh -fx

#
#
# Migration for TR12044 - New HGNC Biomart
# (part 2 - run loads)
#
#
# Products:
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
echo "--- Run HGNC Homology Load ---"  | tee -a ${LOG}
${HOMOLOGYLOAD}/bin/homologyload.sh hgncload.config

date | tee -a ${LOG}
echo "--- Run Hybrid Homology Load ---"  | tee -a ${LOG}
${HOMOLOGYLOAD}/bin/homologyload.sh hybridload.config

echo "--- done running loads ---" | tee -a ${LOG}

date | tee -a ${LOG}
