#!/bin/csh -fx

#
# delete orphan genotypes
#

cd `dirname $0` && source ../Configuration
setenv CWD `pwd`	# current working directory
echo "Server: ${PG_DBSERVER}"
echo "Database: ${PG_DBNAME}"

# start a new log file for this migration, and add a datestamp

setenv LOG $0.log.$$
rm -rf ${LOG}
touch ${LOG}
date | tee -a ${LOG}
echo "--- Starting in ${CWD}..." | tee -a ${LOG}

echo "--- Deleting Orphan Genotypes ..." | tee -a ${LOG}
echo "--- Deleting Orphan Genotypes ..." | tee -a ${LOG}
./deleteOrphans.py

date | tee -a ${LOG}
echo "--- Finished" | tee -a ${LOG}
