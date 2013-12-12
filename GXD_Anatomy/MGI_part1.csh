#!/bin/csh -fx

#
# Migration for GXD Anatomy project
# (part 1 - optionally load dev database. etc)

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
# Truncate and load MGI_EMAPS_Mapping
#

date | tee -a ${LOG}

echo '---Truncating  MGI_EMAPS_Mapping' | tee -a ${LOG}
${MGD_DBSCHEMADIR}/table/MGI_EMAPS_Mapping_truncate.object

echo '---Reloading MGI_EMAPS_Mapping' | tee -a ${LOG}
/mgi/all/wts_projects/11500/11533/loadMapping.sh

echo '---Running EMAPA/EMAPS load' | tee -a ${LOG}
${EMAPLOAD}/bin/emapload.sh

echo '---Running Mapping QC' | tee -a ${LOG}
reportisql.csh ${QCRPTS}/weekly/GXD_EMAPS_MappingChecks.sql GXD_EMAPS_MappingChecks.rpt ${MGD_DBSERVER} ${MGD_DBNAME}

date | tee -a ${LOG}
