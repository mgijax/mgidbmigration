#!/bin/csh -fx

#
# Migration for GeneView
# (part 1 - optionally load dev database. etc)
#
# Products:
# mgddbschema
# rvload
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
    echo "--- Loading new database into ${MGD_DBSERVER}.${MGD_DBNAME}.mgd" | tee -a ${LOG}
    ${PG_DBUTILS}/bin/loadDB.csh ${MGD_DBSERVER} ${MGD_DBNAME} mgd /bhmgidb01/dump/mgd.dump  | tee -a ${LOG}
    date | tee -a ${LOG}
else
    echo "--- Working on existing database: ${MGD_DBSERVER}.${MGD_DBNAME}.mgd" | tee -a ${LOG}
endif

if ("${1}" == "dev") then
    echo "--- Loading new database into ${RADAR_DBSERVER}.${RADAR_DBNAME}.radar" | tee -a ${LOG}
    ${PG_DBUTILS}/bin/loadDB.csh  ${RADAR_DBSERVER} ${RADAR_DBNAME} radar /bhmgidb01/dump/radar.dump | tee -a ${LOG}
    date | tee -a ${LOG}
else
    echo "--- Working on existing database: ${RADAR_DBSERVER}.${RADAR_DBNAME}.radar" | tee -a ${LOG}
endif

echo "--- Finished loading databases " | tee -a ${LOG}

echo "--- Delete DoTS/NIA/DFCI accession IDS and Update schema version ---" | tee -a ${LOG}
cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a ${LOG}

delete from ACC_Accession where _LogicalDB_key in (35,36,53)
;
delete from ACC_LogicalDB where _LogicalDB_key in (35,36,53)
;

update MGI_dbinfo set
        schema_version = '6-0-1',
        public_version = 'MGI 6.01'
;

EOSQL

date | tee -a ${LOG}
echo "--- Finished" | tee -a ${LOG}
