#!/bin/csh -fx

#
#
# Migration for GXD: Index high throughput expression data project TR12330
# (part 1 - optionally load dev database. etc)
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
echo "--- Load Raw GXD HT Data ---"  | tee -a ${LOG}
${GXDHTLOAD}/bin/gxdhtload.sh

echo "--- done running loads ---" | tee -a ${LOG}

date | tee -a ${LOG}
