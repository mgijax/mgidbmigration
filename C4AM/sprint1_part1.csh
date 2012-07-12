#!/bin/csh -fx

#
# Migration for C4AM -- Sprint 1
# (part 1 - optionally load dev database. Migration of existing data 
# into new structures)

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
# Migrate data
#
date | tee -a ${LOG}
echo "--- Collection Abbreviation Updates" | tee -a ${LOG}

cat - <<EOSQL | doisql.csh ${MGD_DBSERVER} ${MGD_DBNAME} $0 | tee -a ${LOG}

use ${MGD_DBNAME}
go

update MAP_Coord_Collection
set abbreviation = 'MGI'
where name = 'MGI QTL'
go

update MAP_Coord_Collection
set abbreviation = 'UniSTS'
where name = 'NCBI UniSTS'
go

update MAP_Coord_Collection
set abbreviation = 'MGI'
where name = 'Roopenian STS'
go

update MAP_Coord_Collection
set abbreviation = 'MGI'
where name = 'MGI QTL'
go

EOSQL
echo "--- Finished Collection Abbreviation Updates " | tee -a ${LOG}
