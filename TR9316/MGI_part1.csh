#!/bin/csh -fx

# Migration for TR9316 - Part 1
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
###--- stored procedures ---###
###----------------------###

date | tee -a ${LOG}
echo "--- deleting/adding stored procedures" | tee -a ${LOG}
${SCHEMA}/procedure/NOM_transferToMGD_drop.object | tee -a ${LOG}
${SCHEMA}/procedure/NOM_transferToMGD_create.object | tee -a ${LOG}

# add permissions

date | tee -a ${LOG}
echo "--- Adding perms" | tee -a ${LOG}
${PERMS}/curatorial/procedure/NOM_transferToMGD_grant.object | tee -a ${LOG}

# run marker location cache load
date | tee -a ${LOG}
echo "--- MRK_Location_Cache load" | tee -a ${LOG}
${MRKCACHELOAD}/mrklocation.csh | tee -a ${LOG}

# fix offsets
date | tee -a ${LOG}
echo "--- fix offsets" | tee -a ${LOG}
./fixoffets.csh | tee -a ${LOG}

#date | tee -a ${LOG}
#echo 'Re-setting permissions/schema'
#${SCHEMA}/reconfig.csh | tee -a ${LOG}
#${PERMS}/all_revoke.csh | tee -a ${LOG}
#${PERMS}/all_grant.csh | tee -a ${LOG}

