#!/bin/csh -fx

#
# Migration for dbSNP 142
# (part 2 - run loads)
#
# Products:
#

###----------------------###
###--- initialization ---###
###----------------------###

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

date | tee -a ${LOG}
echo "--- Run DBNSP Load ---" | tee -a ${LOG}
${DBSNPLOAD/bin/dbsnpload.sh >& /data/loads/dbsnp/dbsnpload/logs/dbsnpload.sh.out

date | tee -a ${LOG}
