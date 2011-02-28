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
#${MGD_DBSCHEMADIR}/procedure/MGI_checkTask_drop.object | tee -a ${LOG}
#${MGD_DBSCHEMADIR}/procedure/MGI_checkTask_create.object | tee -a ${LOG}
#${MGD_DBPERMSDIR}/public/procedure/MGI_checkTask_grant.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/procedure/MGI_checkUserRole_drop.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/procedure/MGI_checkUserRole_create.object | tee -a ${LOG}
${MGD_DBPERMSDIR}/public/procedure/MGI_checkUserRole_grant.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/procedure/ACCRef_process_drop.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/procedure/ACCRef_process_create.object | tee -a ${LOG}
${MGD_DBPERMSDIR}/curatorial/procedure/ACCRef_process_grant.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/procedure/PRB_processAnonymousSource_drop.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/procedure/PRB_processAnonymousSource_create.object | tee -a ${LOG}
${MGD_DBPERMSDIR}/curatorial/procedure/PRB_processAnonymousSource_grant.object | tee -a ${LOG}

date | tee -a ${LOG}
echo "--- triggers ---"
./perms2.csh | tee -a ${LOG}
${MGD_DBSCHEMADIR}/trigger/PRB_Strain_drop.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/trigger/PRB_Strain_create.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/trigger/MGI_Note_drop.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/trigger/MGI_Note_create.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/trigger/MGI_Reference_Assoc_drop.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/trigger/MGI_Reference_Assoc_create.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/trigger/MGI_Synonym_drop.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/trigger/MGI_Synonym_create.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/trigger/VOC_Annot_drop.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/trigger/VOC_Annot_create.object | tee -a ${LOG}

date | tee -a ${LOG}
echo "--- permissions ---"
#${MGD_DBPERMSDIR}/curatorial/table/PRB_Strain_revoke.object | tee -a ${LOG}
#${MGD_DBPERMSDIR}/public/table/PRB_Strain_revoke.object | tee -a ${LOG}
#${MGD_DBPERMSDIR}/curatorial/table/PRB_Strain_grant.object | tee -a ${LOG}
#${MGD_DBPERMSDIR}/public/table/PRB_Strain_grant.object | tee -a ${LOG}

#date | tee -a ${LOG}
#echo "--- adding new permission ---"
#./tr10584.csh | tee -a ${LOG}

#date | tee -a ${LOG}
#echo "--- Re-setting permissions/schema ---"
#${MGD_DBSCHEMADIR}/reconfig.csh | tee -a ${LOG}
${MGD_DBPERMSDIR}/all_revoke.csh | tee -a ${LOG}
${MGD_DBPERMSDIR}/all_grant.csh | tee -a ${LOG}

