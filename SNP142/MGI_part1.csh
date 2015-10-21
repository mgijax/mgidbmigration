#!/bin/csh -fx

#
# Migration for dbSNP 142
# (part 1 - optionally load dev database. etc)
#
# Products:
# pgsnpdbschema
# 
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

echo "--- Update SNP Schema ---" | tee -a ${LOG}

${SNP_DBSCHEMADIR}/table/SNP_ConsensusSnp_Marker_drop.object
${SNP_DBSCHEMADIR}/table/SNP_ConsensusSnp_Marker_create.object
${SNP_DBSCHEMADIR}/key/SNP_ConsensusSnp_Marker_create.object
${SNP_DBSCHEMADIR}/index/SNP_ConsensusSnp_Marker_create.object

echo "--- Drop SNP_Summary_View ---"  | tee -a ${LOG}
cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0

drop view snp.SNP_Summary_View

CASCADE
;

EOSQL


date | tee -a ${LOG}
echo "--- Finished" | tee -a ${LOG}
