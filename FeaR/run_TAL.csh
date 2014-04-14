#!/bin/csh -fx

#
# Run targeted allele loads
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

#
# Run TAL loads
#

date | tee -a ${LOG}

date | tee -a ${LOG}
echo 'Targeted Allele Loads' | tee -a ${LOG}
echo 'KOMP-CSD mbp' | tee -a ${LOG}
${TARGETEDALLELELOAD}/bin/targetedalleleload.sh tal_csd_mbp.config

echo 'KOMP-CSD wtsi' | tee -a ${LOG}
${TARGETEDALLELELOAD}/bin/targetedalleleload.sh tal_csd_wtsi.config

echo 'EUCOMM hmgu' | tee -a ${LOG}
${TARGETEDALLELELOAD}/bin/targetedalleleload.sh tal_eucomm_hmgu.config

echo 'EUCOMM wtsi ' | tee -a ${LOG}
${TARGETEDALLELELOAD}/bin/targetedalleleload.sh tal_eucomm_wtsi.config

date | tee -a ${LOG}
