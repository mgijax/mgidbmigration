#!/bin/csh -fx

#
# Migration for TR12057 - Alternative MGI accession id formats for Genotypes
# (part 1 - optionally load dev database. etc)
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

#
# load a production backup into mgd and radar
#
if ("${1}" == "dev") then
    echo "--- Loading new database into ${PG_DBSERVER}.${PG_DBNAME}.mgd" | tee -a ${LOG}
    ${PG_DBUTILS}/bin/loadDB.csh ${PG_DBSERVER} ${PG_DBNAME} mgd /bhmgidb01/dump/mgd.dump  | tee -a ${LOG}
    date | tee -a ${LOG}
else
    echo "--- Working on existing database: ${PG_DBSERVER}.${PG_DBNAME}.mgd" | tee -a ${LOG}
endif

if ("${1}" == "dev") then
    echo "--- Loading new database into ${PG_DBSERVER}.${PG_DBNAME}.radar" | tee -a ${LOG}
    ${PG_DBUTILS}/bin/loadDB.csh  ${PG_DBSERVER} ${PG_DBNAME} radar /bhmgidb01/dump/radar.dump | tee -a ${LOG}
    date | tee -a ${LOG}
else
    echo "--- Working on existing database: ${PG_DBSERVER}.${PG_DBNAME}.radar" | tee -a ${LOG}
endif

echo "--- Finished loading databases " | tee -a ${LOG}

echo "--- Recreate ACC_assignMGI procedure " | tee -a ${LOG}
${PG_MGD_DBSCHEMADIR}/procedure/ACC_assignMGI_drop.object
${PG_MGD_DBSCHEMADIR}/procedure/ACC_assignMGI_create.object

echo "--- Adding RR IDs to all existing genotypes " | tee -a ${LOG}
./addRrIds.py

echo "--- Done running RR ID migration " | tee -a ${LOG}

date | tee -a ${LOG}
