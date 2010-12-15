#!/bin/csh -fx

# Migration for TR10047 - Part 1
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

date | tee -a ${LOG}
echo "--- Updating version numbers in db..." | tee -a ${LOG}

#${MGI_DBUTILS}/bin/updatePublicVersion.csh ${MGD_DBSERVER} ${MGD_DBNAME} "MGI 4.41" | tee -a ${LOG}
#${MGI_DBUTILS}/bin/updateSchemaVersion.csh ${MGD_DBSERVER} ${MGD_DBNAME} "4-4-1-0" | tee -a ${LOG}

date | tee -a ${LOG}
echo "--- Trigger changes " | tee -a ${LOG}

${MGD_DBSCHEMADIR}/trigger/GXD_Structure_drop.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/trigger/GXD_Structure_create.object | tee -a ${LOG}

date | tee -a ${LOG}
echo "--- View changes " | tee -a ${LOG}

${MGD_DBSCHEMADIR}/view/GXD_Structure_Acc_View_drop.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/view/GXD_Structure_Acc_View_create.object | tee -a ${LOG}
${MGD_DBPERMSDIR}/public/view/GXD_Structure_Acc_View_grant.object | tee -a ${LOG}

date | tee -a ${LOG}
echo "--- schema changes---"
./accload.py | tee -a ${LOG}

date | tee -a ${LOG}
echo "--- migration changes---"
./tr10455.csh | tee -a ${LOG}

#date | tee -a ${LOG}
#echo "--- Re-setting permissions/schema ---"
#${MGD_DBSCHEMADIR}/reconfig.csh | tee -a ${LOG}
#${{MGD_DBPERMSDIR}/all_revoke.csh | tee -a ${LOG}
#${{MGD_DBPERMSDIR}/all_grant.csh | tee -a ${LOG}

