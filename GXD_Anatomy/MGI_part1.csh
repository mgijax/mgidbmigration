#!/bin/csh -fx

#
# Migration for GXD Anatomy project -- 
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
# Migrate database structures
#

date | tee -a ${LOG}

echo '---Create tables, indexes, keys on EMAP* tables' | tee -a ${LOG}
${MGD_DBSCHEMADIR}/table/VOC_Term_EMAPA_create.object
${MGD_DBSCHEMADIR}/table/VOC_Term_EMAPS_create.object

${MGD_DBSCHEMADIR}/key/VOC_Term_EMAPA_create.object
${MGD_DBSCHEMADIR}/key/VOC_Term_EMAPS_create.object

${MGD_DBSCHEMADIR}/index/VOC_Term_EMAPA_create.object
${MGD_DBSCHEMADIR}/index/VOC_Term_EMAPS_create.object

echo '---Drop and recreate VOC_Term keys, delete trigger' | tee -a ${LOG}
${MGD_DBSCHEMADIR}/key/VOC_Term_drop.object
${MGD_DBSCHEMADIR}/key/VOC_Term_create.object

${MGD_DBSCHEMADIR}/trigger/VOC_Term_drop.object
${MGD_DBSCHEMADIR}/trigger/VOC_Term_create.object

date | tee -a ${LOG}
echo "--- Re-setting permissions/schema ---" | tee -a ${LOG}
${MGD_DBSCHEMADIR}/all_perms.csh | tee -a ${LOG}

date | tee -a ${LOG}
