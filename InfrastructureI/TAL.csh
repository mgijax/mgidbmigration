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
# load a production backup into mgd and radar
#

if ("${1}" == "dev") then
    echo "--- Loading new database into ${MGD_DBSERVER}..${MGD_DBNAME}" | tee -a ${LOG}
    load_db.csh ${MGD_DBSERVER} ${MGD_DBNAME} /lindon/sybase/mgd.backup | tee -a ${LOG}
    date | tee -a ${LOG}
else
    echo "--- Working on existing database: ${MGD_DBSERVER}..${MGD_DBNAME}" | tee -a ${LOG}
endif

if ("${1}" == "dev") then
    echo "--- Loading new database into ${RADAR_DBSERVER}..${RADAR_DBNAME}" | tee -a ${LOG}
    load_db.csh ${RADAR_DBSERVER} ${RADAR_DBNAME} /lindon/sybase/radar.backup | tee -a ${LOG}
    date | tee -a ${LOG}
else
    echo "--- Working on existing database: ${RADAR_DBSERVER}..${RADAR_DBNAME}" | tee -a ${LOG}
endif

echo "--- Finished loading databases " | tee -a ${LOG}

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
echo 'Load Allele/Label Cache Table' | tee -a ${LOG}
${ALLCACHELOAD}/alllabel.csh
date | tee -a ${LOG}
echo 'Load Allele/Combination Cache Table' | tee -a ${LOG}
${ALLCACHELOAD}/allelecombination.csh
date | tee -a ${LOG}
echo 'Load Allele/Strain Cache Table' | tee -a ${LOG}
${ALLCACHELOAD}/allstrain.csh
date | tee -a ${LOG}
echo 'Load Allele/CRE Cache Table' | tee -a ${LOG}
${ALLCACHELOAD}/allelecrecache.csh

date | tee -a ${LOG}
