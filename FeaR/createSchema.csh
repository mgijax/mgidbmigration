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

#
# Migrate database structures
#

date | tee -a ${LOG}

echo '---Create table tables---' | tee -a ${LOG}
${MGD_DBSCHEMADIR}/table/MGI_Relationship_Category_create.object
${MGD_DBSCHEMADIR}/table/MGI_Relationship_create.object
${MGD_DBSCHEMADIR}/table/MGI_Relationship_Property_create.object

echo '---Create table defaults---' | tee -a ${LOG}
${MGD_DBSCHEMADIR}/default/MGI_Relationship_Category_bind.object
${MGD_DBSCHEMADIR}/default/MGI_Relationship_bind.object
${MGD_DBSCHEMADIR}/default/MGI_Relationship_Property_bind.object

echo '---Create primary keys---' | tee -a ${LOG}
${MGD_DBSCHEMADIR}/key/MGI_Relationship_Category_create.object
${MGD_DBSCHEMADIR}/key/MGI_Relationship_create.object
${MGD_DBSCHEMADIR}/key/MGI_Relationship_Property_create.object

echo '---Drop/recreate foreign keys---' | tee -a ${LOG}
${MGD_DBSCHEMADIR}/key/ACC_MGIType_drop.object
${MGD_DBSCHEMADIR}/key/ACC_MGIType_create.object
${MGD_DBSCHEMADIR}/key/BIB_Refs_drop.object
${MGD_DBSCHEMADIR}/key/BIB_Refs_create.object
${MGD_DBSCHEMADIR}/key/DAG_DAG_drop.object
${MGD_DBSCHEMADIR}/key/DAG_DAG_create.object
${MGD_DBSCHEMADIR}/key/MGI_User_drop.object
${MGD_DBSCHEMADIR}/key/MGI_User_create.object
${MGD_DBSCHEMADIR}/key/VOC_Term_drop.object
${MGD_DBSCHEMADIR}/key/VOC_Term_create.object
${MGD_DBSCHEMADIR}/key/VOC_Vocab_drop.object
${MGD_DBSCHEMADIR}/key/VOC_Vocab_create.object

echo '---Create indexes---' | tee -a ${LOG}
${MGD_DBSCHEMADIR}/index/MGI_Relationship_Category_create.object
${MGD_DBSCHEMADIR}/index/MGI_Relationship_create.object
${MGD_DBSCHEMADIR}/index/MGI_Relationship_Property_create.object

echo '---Create new triggers---' | tee -a ${LOG}
${MGD_DBSCHEMADIR}/trigger/MGI_Relationship_Category_create.object
${MGD_DBSCHEMADIR}/trigger/MGI_Relationship_create.object

echo '---Drop/create existing triggers---' | tee -a  ${LOG}
${MGD_DBSCHEMADIR}/trigger/ACC_MGIType_drop.object
${MGD_DBSCHEMADIR}/trigger/ACC_MGIType_create.object

${MGD_DBSCHEMADIR}/trigger/ALL_Allele_drop.object
${MGD_DBSCHEMADIR}/trigger/ALL_Allele_create.object

${MGD_DBSCHEMADIR}/trigger/BIB_Refs_drop.object
${MGD_DBSCHEMADIR}/trigger/BIB_Refs_create.object

${MGD_DBSCHEMADIR}/trigger/DAG_DAG_drop.object
${MGD_DBSCHEMADIR}/trigger/DAG_DAG_create.object

${MGD_DBSCHEMADIR}/trigger/MRK_Marker_drop.object
${MGD_DBSCHEMADIR}/trigger/MRK_Marker_create.object

${MGD_DBSCHEMADIR}/trigger/VOC_Term_drop.object
${MGD_DBSCHEMADIR}/trigger/VOC_Term_create.object

${MGD_DBSCHEMADIR}/trigger/VOC_Vocab_drop.object
${MGD_DBSCHEMADIR}/trigger/VOC_Vocab_create.object

date | tee -a ${LOG}
echo "--- Re-setting permissions/schema ---" | tee -a ${LOG}
${MGD_DBSCHEMADIR}/all_perms.csh | tee -a ${LOG}


echo "--- Update MGI_Tables and MGI_Columns ---" | tee -a ${LOG}
cat - <<EOSQL | doisql.csh ${MGD_DBSERVER} ${MGD_DBNAME} $0 | tee -a ${LOG}

use ${MGD_DBNAME}
go

exec MGI_Table_Column_Cleanup
go

EOSQL

date | tee -a ${LOG}
