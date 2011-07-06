#!/bin/csh -fx

# Migration for TR10044 - Part 1
#
# Object Type     Count
# ==============  ============
# Tables               201 scripts
# Indexes              200 scripts  (     719 indexes)
# Keys                 201 scripts  (     201 primary keys,      541 foreign keys)
# Triggers              98 scripts  (     162 triggers)
# Procedures           131 scripts
# Views                245 scripts
# Partitions             4 scripts
# Defaults               6 scripts
# Default binds        186 scripts  (     553 binds)
# Rules                  5 scripts
# Rule binds             5 scripts  (       6 binds)
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

#date | tee -a ${LOG}
#echo "--- loading property vocabulary ---"
#${VOCLOAD}/loadSimpleVocab.py property.txt "GO Property" J:23000 1 ${MGD_DBUSER} ${MGI_DBPASSWORDFILE} ${MGD_DBSERVER} ${MGD_DBNAME} | tee -a ${LOG}

echo "--- view---"
${MGD_DBSCHEMADIR}/view/VOC_Term_MCV_View_drop.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/view/VOC_Term_MCV_View_create.object | tee -a ${LOG}

date | tee -a ${LOG}
echo "--- triggers ---"
${MGD_DBSCHEMADIR}/trigger/VOC_Term_drop.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/trigger/VOC_Term_create.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/trigger/SEQ_Sequence_drop.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/trigger/SEQ_Sequence_create.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/trigger/MRK_Marker_drop.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/trigger/MRK_Marker_create.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/trigger/NOM_Marker_drop.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/trigger/NOM_Marker_create.object | tee -a ${LOG}

echo "--- procedures ---"
${MGD_DBSCHEMADIR}/procedure/SEQ_split_drop.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/procedure/SEQ_split_create.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/procedure/SEQ_loadMarkerCache_drop.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/procedure/SEQ_loadMarkerCache_create.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/procedure/SEQ_deleteDummy_drop.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/procedure/SEQ_deleteDummy_create.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/procedure/PRB_processAntigenAnonSource_drop.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/procedure/PRB_processAntigenAnonSource_create.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/procedure/PRB_processProbeSource_drop.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/procedure/PRB_processProbeSource_create.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/procedure/PRB_processSequenceSource_drop.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/procedure/PRB_processSequenceSource_create.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/procedure/MRK_reloadSequence_drop.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/procedure/MRK_reloadSequence_create.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/procedure/NOM_updateReserved_drop.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/procedure/NOM_updateReserved_create.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/procedure/MRK_simpleWithdrawal_drop.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/procedure/MRK_simpleWithdrawal_create.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/procedure/NOM_transferToMGD_drop.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/procedure/NOM_transferToMGD_create.object | tee -a ${LOG}

date | tee -a ${LOG}
echo "--- Re-setting permissions/schema ---"
#${MGD_DBSCHEMADIR}/reconfig.csh | tee -a ${LOG}
${MGD_DBSCHEMADIR}/all_perms.csh | tee -a ${LOG}

