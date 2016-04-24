#!/bin/csh -fx

#
# Migration for HIPPO TR12267
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

echo "--- Load HPO Vocab ---"  | tee -a ${LOG}
${VOCLOAD}/runOBOIncLoad.sh HPO.config

echo "--- Load MP/HPO relationships ---"  | tee -a ${LOG}
${MPHPOLOAD}/bin/mp_hpoload.sh

echo "--- Load OMIM/HPO annotations ---"  | tee -a ${LOG}
${OMIMHPOLOAD}/bin/omim_hpoload.sh

echo "--- done running loads ---" | tee -a ${LOG}

date | tee -a ${LOG}
