#!/bin/csh -fx

# Migration for TR10044 - Part 1
#
# Tables	202
# Triggers	125 (236)
# Procedures	137
# Views		241
# Defaults	7
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

date | tee -a ${LOG}
echo "--- Updating version numbers in db..." | tee -a ${LOG}

#${MGI_DBUTILS}/bin/updatePublicVersion.csh ${MGD_DBSERVER} ${MGD_DBNAME} "MGI 4.35" | tee -a ${LOG}
#${MGI_DBUTILS}/bin/updateSchemaVersion.csh ${MGD_DBSERVER} ${MGD_DBNAME} "4-3-5-0" | tee -a ${LOG}

###----------------------###
###--- add new tables ---###
###----------------------###

date | tee -a ${LOG}
echo "--- Creating new tables" | tee -a ${LOG}

${MGD_DBSCHEMADIR}/table/VOC_Evidence_Property_drop.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/table/VOC_Evidence_Property_create.object | tee -a ${LOG}

# add defaults for new tables
# not created yet

# drop/add keys and indexes for new tables

date | tee -a ${LOG}
echo "--- Dropping/Adding keys" | tee -a ${LOG}

${MGD_DBSCHEMADIR}/key/VOC_Evidence_Property_drop.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/key/VOC_Evidence_Property_create.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/key/VOC_Evidence_drop.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/key/VOC_Evidence_create.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/key/VOC_Term_drop.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/key/VOC_Term_create.object | tee -a ${LOG}

date | tee -a ${LOG}
echo "--- Adding indexes" | tee -a ${LOG}

${MGD_DBSCHEMADIR}/index/VOC_Evidence_Property_drop.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/index/VOC_Evidence_Property_create.object | tee -a ${LOG}

date | tee -a ${LOG}
echo "--- View changes " | tee -a ${LOG}

#${MGD_DBSCHEMADIR}/view/ | tee -a ${LOG}

# add permissions

date | tee -a ${LOG}
echo "--- Adding perms" | tee -a ${LOG}

${{MGD_DBPERMSDIR}/curatorial/table/VOC_Evidence_Property_grant.object | tee -a ${LOG}
${{MGD_DBPERMSDIR}/public/table/VOC_Evidence_Property_grant.object | tee -a ${LOG}

#date | tee -a ${LOG}
#echo "--- loading property vocabulary ---"
#${VOCLOAD}/loadSimpleVocab.py property.txt "Annotation/Evidence/Property" J:23000 1 ${MGD_DBUSER} ${MGI_DBPASSWORDFILE} ${MGD_DBSERVER} ${MGD_DBNAME} | tee -a ${LOG}

#date | tee -a ${LOG}
#echo "--- Re-setting permissions/schema ---"
#${MGD_DBSCHEMADIR}/reconfig.csh | tee -a ${LOG}
#${{MGD_DBPERMSDIR}/all_revoke.csh | tee -a ${LOG}
#${{MGD_DBPERMSDIR}/all_grant.csh | tee -a ${LOG}

