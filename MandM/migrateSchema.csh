#!/bin/csh -fx

#
# Migration for M&M project
# (part 1 - optionally load dev database. etc)
#
# Products:
# mgddbschema
# rvload
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
echo "--- Create MGI_Property* tables" | tee -a ${LOG}
${MGD_DBSCHEMADIR}/table/MGI_PropertyType_create.object
${MGD_DBSCHEMADIR}/table/MGI_Property_create.object

date | tee -a ${LOG}
echo "--- Bind defaults for MGI_Property* tables" | tee -a ${LOG}
${MGD_DBSCHEMADIR}/default/MGI_PropertyType_bind.object
${MGD_DBSCHEMADIR}/default/MGI_Property_bind.object

date | tee -a ${LOG}
echo "--- Create MGI_Property* keys" | tee -a ${LOG}
${MGD_DBSCHEMADIR}/key/MGI_PropertyType_create.object
${MGD_DBSCHEMADIR}/key/MGI_Property_create.object

date | tee -a ${LOG}
echo "--- Add foreign key relationships for MGI_Property*" | tee -a ${LOG}
${MGD_DBSCHEMADIR}/key/ACC_MGIType_drop.object
${MGD_DBSCHEMADIR}/key/MGI_User_drop.object
${MGD_DBSCHEMADIR}/key/VOC_Term_drop.object
${MGD_DBSCHEMADIR}/key/VOC_Vocab_drop.object

${MGD_DBSCHEMADIR}/key/ACC_MGIType_create.object
${MGD_DBSCHEMADIR}/key/MGI_User_create.object
${MGD_DBSCHEMADIR}/key/VOC_Term_create.object
${MGD_DBSCHEMADIR}/key/VOC_Vocab_create.object

date | tee -a ${LOG}
echo "--- Add indexes to MRK_Cluster*" | tee -a ${LOG}

${MGD_DBSCHEMADIR}/index/MGI_PropertyType_create.object
${MGD_DBSCHEMADIR}/index/MGI_Property_create.object

date | tee -a ${LOG}
echo "--- Create triggers" | tee -a ${LOG}
${MGD_DBSCHEMADIR}/trigger/MGI_PropertyType_create.object

${MGD_DBSCHEMADIR}/drop/ACC_MGIType_create.object
${MGD_DBSCHEMADIR}/drop/MRK_Cluster_create.object
${MGD_DBSCHEMADIR}/drop/VOC_Term_create.object
${MGD_DBSCHEMADIR}/drop/VOC_Vocab_create.object

${MGD_DBSCHEMADIR}/trigger/ACC_MGIType_create.object
${MGD_DBSCHEMADIR}/trigger/MRK_Cluster_create.object
${MGD_DBSCHEMADIR}/trigger/VOC_Term_create.object
${MGD_DBSCHEMADIR}/trigger/VOC_Vocab_create.object

date | tee -a ${LOG}
echo "--- Re-setting permissions/schema ---" | tee -a ${LOG}
${MGD_DBSCHEMADIR}/all_perms.csh | tee -a ${LOG}

exec MGI_Table_Column_Cleanup
go

EOSQL

date | tee -a ${LOG}
echo "--- Finished" | tee -a ${LOG}
