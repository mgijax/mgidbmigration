#!/bin/csh -fx

# Migration for TR6839 - Part 1
#
# Tables	200
# Triggers	125 (236)
# Procedures	137
# Views		237
# Defaults	6
# Rules		5
#

cd `dirname $0` && source ../Configuration

echo "Server: ${MGD_DBSERVER}"
echo "Database: ${MGD_DBNAME}"

setenv LOG $0.log.$$
rm -rf ${LOG}
touch ${LOG}
date | tee -a ${LOG}

# load a backup

if ("${1}" == "dev") then
    echo "--- Loading new database into ${MGD_DBSERVER}..${MGD_DBNAME}" | tee -a ${LOG}
    load_db.csh ${MGD_DBSERVER} ${MGD_DBNAME} /lindon/sybase/mgd.backup | tee -a ${LOG}
    date | tee -a ${LOG}
else
    echo "--- Working on existing database: ${MGD_DBSERVER}..${MGD_DBNAME}" | tee -a ${LOG}
endif

setenv SCHEMA ${MGD_DBSCHEMADIR}
setenv PERMS ${MGD_DBPERMSDIR}
setenv UTILS ${MGI_DBUTILS}

date | tee -a ${LOG}
echo "--- Updating version numbers in db..." | tee -a ${LOG}

#${UTILS}/bin/updatePublicVersion.csh ${MGD_DBSERVER} ${MGD_DBNAME} "MGI 4.35" | tee -a ${LOG}
#${UTILS}/bin/updateSchemaVersion.csh ${MGD_DBSERVER} ${MGD_DBNAME} "4-3-5-0" | tee -a ${LOG}

###----------------------###
###--- add new tables ---###
###----------------------###

date | tee -a ${LOG}
echo "--- Creating new tables" | tee -a ${LOG}

${SCHEMA}/table/MRK_MCV_Cache_create.object | tee -a ${LOG}
${SCHEMA}/table/MRK_MCV_Count_Cache_create.object | tee -a ${LOG}

# add defaults for new tables
# not created yet

# drop/add keys and indexes for new tables

date | tee -a ${LOG}
echo "--- Dropping/Adding keys" | tee -a ${LOG}

${SCHEMA}/key/MRK_Marker_drop.object | tee -a ${LOG}
${SCHEMA}/key/MRK_Marker_create.object | tee -a ${LOG}
${SCHEMA}/key/MRK_MCV_Cache_create.object | tee -a ${LOG}
${SCHEMA}/key/MRK_MCV_Count_Cache_create.object | tee -a ${LOG}

date | tee -a ${LOG}
echo "--- Adding indexes" | tee -a ${LOG}

${SCHEMA}/index/MRK_MCV_Cache_create.object | tee -a ${LOG}
${SCHEMA}/index/MRK_MCV_Count_Cache_create.object | tee -a ${LOG}

date | tee -a ${LOG}
echo "--- View changes " | tee -a ${LOG}

${SCHEMA}/view/GXD_Antibody_View_drop.object | tee -a ${LOG}
${SCHEMA}/view/GXD_Antibody_View_create.object | tee -a ${LOG}
${SCHEMA}/view/VOC_Annot_View_drop.object | tee -a ${LOG}
${SCHEMA}/view/VOC_Annot_View_create.object | tee -a ${LOG}
${SCHEMA}/view/VOC_Term_View_drop.object | tee -a ${LOG}
${SCHEMA}/view/VOC_Term_View_create.object | tee -a ${LOG}

# add permissions

date | tee -a ${LOG}
echo "--- Adding perms" | tee -a ${LOG}

${PERMS}/public/table/MRK_MCV_Cache_grant.object | tee -a ${LOG}
${PERMS}/public/table/MRK_MCV_Count_Cache_grant.object | tee -a ${LOG}
${PERMS}/curatorial/view/GXD_Antibody_View_grant.object | tee -a ${LOG}
${PERMS}/curatorial/view/VOC_Annot_View_grant.object | tee -a ${LOG}
${PERMS}/curatorial/view/VOC_Term_View_grant.object | tee -a ${LOG}

date | tee -a ${LOG}
echo 'Update Marker Types'
./updateMarkerType.csh

#date | tee -a ${LOG}
#echo 'Re-setting permissions/schema'
#${SCHEMA}/reconfig.csh | tee -a ${LOG}
#${PERMS}/all_revoke.csh | tee -a ${LOG}
#${PERMS}/all_grant.csh | tee -a ${LOG}

