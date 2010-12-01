#!/bin/csh -fx

# Migration for TR10033 - Part 1
#
# default: 6
# procedure: 137
# rule: 5
# trigger: 236
# user table: 201 -> 202 (*save, *Old = 205)
# view: 241 -> 243
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

${MGI_DBUTILS}/bin/updatePublicVersion.csh ${MGD_DBSERVER} ${MGD_DBNAME} "MGI 4.41" | tee -a ${LOG}
${MGI_DBUTILS}/bin/updateSchemaVersion.csh ${MGD_DBSERVER} ${MGD_DBNAME} "4-4-1-1" | tee -a ${LOG}

# done in production
#date | tee -a ${LOG}
#echo "--- loading vocabulary ---"
#${VOCLOAD}/loadSimpleVocab.py class.txt "Image Class" J:23000 1 ${MGD_DBUSER} ${MGI_DBPASSWORDFILE} ${MGD_DBSERVER} ${MGD_DBNAME} | tee -a ${LOG}

date | tee -a ${LOG}
echo "--- TR10044/schema changes ---"
../TR10044/tr10044.csh | tee -a ${LOG}

date | tee -a ${LOG}
echo "--- TR10033/schema changes ---"
./tr10033.csh | tee -a ${LOG}

#date | tee -a ${LOG}
#echo "--- Re-setting permissions/schema ---"
#${MGD_DBSCHEMADIR}/reconfig.csh | tee -a ${LOG}
#${{MGD_DBPERMSDIR}/all_revoke.csh | tee -a ${LOG}
#${{MGD_DBPERMSDIR}/all_grant.csh | tee -a ${LOG}

