#!/bin/csh -fx

if ( ${?MGICONFIG} == 0 ) then
       setenv MGICONFIG /usr/local/mgi/live/mgiconfig
endif

source ${MGICONFIG}/master.config.csh

setenv LOG $0.log
rm -rf ${LOG}
touch ${LOG}

# COMMENT OUT BEFORE RUNNING ON PRODUCTION
# ${MGI_DBUTILS}/bin/load_db.csh ${MGD_DBSERVER} ${MGD_DBNAME} /backups/rohan/scrum-dog/mgd_dog.backup

date | tee -a ${LOG}

/usr/local/mgi/live/dbutils/mgd/mgddbschema/objectCounter.sh | tee -a ${LOG}

cat - <<EOSQL | doisql.csh $MGD_DBSERVER $MGD_DBNAME $0 | tee -a ${LOG}

use $MGD_DBNAME
go

delete from MGI_UserRole where _Role_key in (6763219,3566936)
go
delete from VOC_Term where _Term_key in (6763219,3566936)
go

EOSQL
date | tee -a ${LOG}

${MGD_DBSCHEMADIR}/trigger/trigger_drop.csh | tee -a ${LOG}
${MGD_DBSCHEMADIR}/trigger/trigger_create.csh | tee -a ${LOG}

${MGD_DBSCHEMADIR}/procedure/MGI_checkTask_drop.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/procedure/MGI_checkTask_create.object | tee -a ${LOG}

${MGD_DBSCHEMADIR}/procedure/ACC_assignJ_drop.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/procedure/ACC_assignJ_create.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/procedure/ACC_assignMGI_drop.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/procedure/ACC_assignMGI_create.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/procedure/ACC_delete_byAccKey_drop.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/procedure/ACC_delete_byAccKey_create.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/procedure/ACC_insertNoChecks_drop.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/procedure/ACC_insertNoChecks_create.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/procedure/ACC_insert_drop.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/procedure/ACC_insert_create.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/procedure/ACC_update_drop.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/procedure/ACC_update_create.object | tee -a ${LOG}

${MGD_DBSCHEMADIR}/procedure/ACCRef_insert_drop.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/procedure/ACCRef_insert_create.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/procedure/ACCRef_process_drop.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/procedure/ACCRef_process_create.object | tee -a ${LOG}

${MGD_DBSCHEMADIR}/procedure/NOM_transferToMGD_drop.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/procedure/NOM_transferToMGD_create.object | tee -a ${LOG}

${MGI_DBUTILS}/bin/updateSchemaDoc.csh ${MGD_DBSERVER} ${MGD_DBNAME} | tee -a ${LOG}

${MGD_DBSCHEMADIR}/all_perms.csh | tee -a ${LOG}
${MGD_DBSCHEMADIR}/all_perms.csh | tee -a ${LOG}

${MGD_DBSCHEMADIR}/objectCounter.sh | tee -a ${LOG}

${MGICACHELOAD}/inferredfrom.csh | tee -a ${LOG}

date | tee -a ${LOG}

