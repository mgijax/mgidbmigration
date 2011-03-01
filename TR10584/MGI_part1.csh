#!/bin/csh -fx

# Migration for TR10584 - Part 1
#
# Object Type     Count
# ==============  ============
# procedures:	  137
# triggers:	  238
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

date | tee -a ${LOG}
echo "--- stored procedures ---"
${MGD_DBSCHEMADIR}/procedure/MGI_checkUserRole_drop.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/procedure/MGI_checkUserRole_create.object | tee -a ${LOG}

${MGD_DBSCHEMADIR}/procedure/ACCRef_process_drop.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/procedure/ACCRef_process_create.object | tee -a ${LOG}

${MGD_DBSCHEMADIR}/procedure/PRB_processAnonymousSource_drop.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/procedure/PRB_processAnonymousSource_create.object | tee -a ${LOG}

${MGD_DBSCHEMADIR}/procedure/VOC_deleteGOGAFRed_drop.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/procedure/VOC_deleteGOGAFRed_create.object | tee -a ${LOG}

${MGD_DBSCHEMADIR}/view/MGI_Reference_Strain_View_drop.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/view/MGI_Reference_Strain_View_create.object | tee -a ${LOG}

${MGD_DBSCHEMADIR}/view/PRB_Strain_Genotype_View_drop.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/view/PRB_Strain_Genotype_View_create.object | tee -a ${LOG}

date | tee -a ${LOG}
echo "--- triggers ---"
./perms2.csh | tee -a ${LOG}
${MGD_DBSCHEMADIR}/trigger/trigger_drop.csh | tee -a ${LOG}
${MGD_DBSCHEMADIR}/trigger/trigger_create.csh | tee -a ${LOG}

#date | tee -a ${LOG}
#echo "--- adding new permission ---"
#./tr10584.csh | tee -a ${LOG}

#date | tee -a ${LOG}
#echo "--- Re-setting permissions/schema ---"
#${MGD_DBSCHEMADIR}/reconfig.csh | tee -a ${LOG}
${MGD_DBSCHEMADIR}/all_revoke.csh | tee -a ${LOG}
${MGD_DBSCHEMADIR}/all_grant.csh | tee -a ${LOG}

