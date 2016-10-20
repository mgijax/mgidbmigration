#!/bin/csh -fx

#
# Migration for GXD: Index high throughput expression data project TR12330
# (part 1 - optionally load dev database. etc)
#
# Products:
#
# mgidbmigration : cvs/trunk
# pgmgddbschema : branch
# mirror_wget : trunk
# gxdhtload : trunk

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
    ${PG_DBUTILS}/bin/loadDB.csh -a ${PG_DBSERVER} ${PG_DBNAME} mgd /bhmgidb01/dump/mgd.dump  | tee -a ${LOG}
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

#
# run migration
#

# run mirror_wget to get data
${MIRROR_WGET}/download_package www.ebi.ac.uk.arrayexpress.json | tee -a $LOG || exit 1

echo "--- Create tables ---"
${PG_MGD_DBSCHEMADIR}/table/GXD_HTExperiment_drop.object
${PG_MGD_DBSCHEMADIR}/table/GXD_HTSample_drop.object
${PG_MGD_DBSCHEMADIR}/table/GXD_HTExperimentVariable_drop.object

${PG_MGD_DBSCHEMADIR}/table/GXD_HTExperiment_create.object
${PG_MGD_DBSCHEMADIR}/table/GXD_HTSample_create.object
${PG_MGD_DBSCHEMADIR}/table/GXD_HTExperimentVariable_create.object

echo "--- Create keys ---"
${PG_MGD_DBSCHEMADIR}/key/GXD_HTExperiment_create.object
${PG_MGD_DBSCHEMADIR}/key/GXD_HTSample_create.object
${PG_MGD_DBSCHEMADIR}/key/GXD_HTExperimentVariable_create.object

echo "--- Create foreign keys ---"
${PG_MGD_DBSCHEMADIR}/key/MGI_User_drop.object
${PG_MGD_DBSCHEMADIR}/key/MGI_User_create.object
${PG_MGD_DBSCHEMADIR}/key/VOC_Term_drop.object
${PG_MGD_DBSCHEMADIR}/key/VOC_Term_create.object
${PG_MGD_DBSCHEMADIR}/key/MGI_Organism_drop.object
${PG_MGD_DBSCHEMADIR}/key/MGI_Organism_create.object
${PG_MGD_DBSCHEMADIR}/key/GXD_TheilerStage_drop.object
${PG_MGD_DBSCHEMADIR}/key/GXD_TheilerStage_create.object
${PG_MGD_DBSCHEMADIR}/key/GXD_Genotype_drop.object
${PG_MGD_DBSCHEMADIR}/key/GXD_Genotype_create.object

echo "--- Create indexes ---"
${PG_MGD_DBSCHEMADIR}/index/GXD_HTExperiment_create.object
${PG_MGD_DBSCHEMADIR}/index/GXD_HTSample_create.object
${PG_MGD_DBSCHEMADIR}/index/GXD_HTExperimentVariable_create.object

echo "--- Create comments ---"
${PG_MGD_DBSCHEMADIR}/comments/GXD_HTExperiment_create.object
${PG_MGD_DBSCHEMADIR}/comments/GXD_HTSample_create.object
${PG_MGD_DBSCHEMADIR}/comments/GXD_HTExperimentVariable_create.object

${PG_DBUTILS}/bin/grantPublicPerms.csh ${PG_DBSERVER} ${PG_DBNAME} mgd | tee -a $LOG || exit 1

#
# update schema-version and public-version
#
date | tee -a ${LOG}
cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG

update MGI_dbinfo set schema_version = '6-0-7', public_version = 'MGI 6.07';

EOSQL

date | tee -a ${LOG}

