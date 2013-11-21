#!/bin/csh -fx

#
# For production - create tables for GXD Anatomy project 
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
# Migrate database structures
#

date | tee -a ${LOG}

echo '---Create tables, indexes, keys on EMAP* tables' | tee -a ${LOG}
${MGD_DBSCHEMADIR}/table/VOC_Term_EMAPA_drop.object
${MGD_DBSCHEMADIR}/table/VOC_Term_EMAPA_create.object
${MGD_DBSCHEMADIR}/table/VOC_Term_EMAPS_drop.object
${MGD_DBSCHEMADIR}/table/VOC_Term_EMAPS_create.object

${MGD_DBSCHEMADIR}/key/VOC_Term_EMAPA_create.object
${MGD_DBSCHEMADIR}/key/VOC_Term_EMAPS_create.object

${MGD_DBSCHEMADIR}/index/VOC_Term_EMAPA_create.object
${MGD_DBSCHEMADIR}/index/VOC_Term_EMAPS_create.object

echo '---Drop and recreate VOC_Term keys, delete trigger' | tee -a ${LOG}
${MGD_DBSCHEMADIR}/key/VOC_Term_drop.object
${MGD_DBSCHEMADIR}/key/VOC_Term_create.object

${MGD_DBSCHEMADIR}/trigger/VOC_Term_drop.object
${MGD_DBSCHEMADIR}/trigger/VOC_Term_create.object

echo '---Drop and recreate MGI_User keys' | tee -a ${LOG}
${MGD_DBSCHEMADIR}/key/MGI_User_drop.object
${MGD_DBSCHEMADIR}/key/MGI_User_create.object

echo '---MGI_EMAPS_Maping' | tee -a ${LOG}
#${MGD_DBSCHEMADIR}/default/MGI_EMAPS_Mapping_unbind.object
${MGD_DBSCHEMADIR}/default/MGI_EMAPS_Mapping_bind.object
#${MGD_DBSCHEMADIR}/view/MGI_EMAPS_Mapping_View_drop.object
${MGD_DBSCHEMADIR}/view/MGI_EMAPS_Mapping_View_create.object

date | tee -a ${LOG}
echo "--- Re-setting permissions/schema ---" | tee -a ${LOG}
${MGD_DBSCHEMADIR}/all_perms.csh | tee -a ${LOG}

date | tee -a ${LOG}
