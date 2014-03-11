#!/bin/csh -fx

#
# Migration for Feature Relationship (FeaR) project
# (part 1 - optionally load dev database. etc)
#
# Products:
# mgddbschema
#
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

echo "--- Create Schema " | tee -a ${LOG}
./createSchema.csh

echo "--- Running RV vocabulary load " | tee -a ${LOG}
${RVLOAD}/bin/rvload.sh

echo "--- Load Relationship Categories ---" | tee -a ${LOG}
cat - <<EOSQL | doisql.csh ${MGD_DBSERVER} ${MGD_DBNAME} $0 | tee -a ${LOG}

use ${MGD_DBNAME}
go

insert into MGI_Relationship_Category
values(1001, 'regulates', 96, 44, 2, 2, 94, 95, 1001, 1001, getdate(), getdate())
go

insert into MGI_Relationship_Category
values(1002, 'cluster_member', 96, 45, 2, 2, 94, 95, 1001, 1001, getdate(), getdate())
go

insert into MGI_Relationship_Category
values(1003, 'mutation_overlaps', 96, 46, 11, 2, 94, 95, 1001, 1001, getdate(), getdate())
go

insert into MGI_Relationship_Category
values(1004, 'expresses', 96, 47, 11, 2, 94, 95, 1001, 1001, getdate(), getdate())
go


EOSQL

date | tee -a ${LOG}
