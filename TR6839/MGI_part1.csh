#!/bin/csh -fx

# Migration for TR6839 - Part 1

cd `dirname $0` && source ../Configuration

echo "Server: ${MGD_DBSERVER}"
echo "Database: ${MGD_DBNAME}"

setenv LOG $0.log.$$
rm -rf ${LOG}
touch ${LOG}
date | tee -a ${LOG}

# load a backup

if ("${1}" == "dev") then
    echo "--- Loading new database into ${MGD_DBSERVER}..${MGD_DBNAME}" | tee -a
 ${LOG}
    load_db.csh ${MGD_DBSERVER} ${MGD_DBNAME} /lindon/sybase/mgd.backup | tee -a
${LOG}
    date | tee -a ${LOG}
else
    echo "--- Working on existing database: ${MGD_DBSERVER}..${MGD_DBNAME}" | te
e -a ${LOG}
endif

setenv SCHEMA ${MGD_DBSCHEMADIR}
setenv PERMS ${MGD_DBPERMSDIR}
setenv UTILS ${MGI_DBUTILS}

###----------------------###
###--- add new tables ---###
###----------------------###

date | tee -a ${LOG}
echo "--- Creating new tables" | tee -a ${LOG}

${SCHEMA}/table/MRK_MCV_Cache_create.object | tee -a ${LOG}
${SCHEMA}/table/MRK_MCV_Count_Cache_create.object | tee -a ${LOG}

# add defaults for new tables
# not created yet


# add keys and indexes for new tables

date | tee -a ${LOG}
echo "--- Adding keys" | tee -a ${LOG}

${SCHEMA}/key/MRK_MCV_Cache_create.object | tee -a ${LOG}
${SCHEMA}/key/MRK_MCV_Count_Cache_create.object | tee -a ${LOG}

date | tee -a ${LOG}
echo "--- Adding indexes" | tee -a ${LOG}

${SCHEMA}/index/MRK_MCV_Cache_create.object | tee -a ${LOG}
${SCHEMA}/index/MRK_MCV_Count_Cache_create.object | tee -a ${LOG}

# add permissions for new tables

date | tee -a ${LOG}
echo "--- Adding new perms" | tee -a ${LOG}

${PERMS}/public/table/MRK_MCV_Cache_grant.object | tee -a ${LOG}
${PERMS}/public/table/MRK_MCV_Count_Cache_grant.object | tee -a ${LOG}

date | tee -a ${LOG}
echo "--- Updating version numbers in db..." | tee -a ${LOG}

#${UTILS}/bin/updatePublicVersion.csh ${MGD_DBSERVER} ${MGD_DBNAME} "MGI 4.33" | tee -a ${LOG}
#${UTILS}/bin/updateSchemaVersion.csh ${MGD_DBSERVER} ${MGD_DBNAME} "4-3-3-0" | tee -a ${LOG}

date | tee -a ${LOG}

echo 'Update Marker Types'
./updateMarkerType.csh
