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

--drop procedure VOC_getGOInferredFrom
--go

--drop procedure MGI_createReferenceSet
--go

--drop procedure MGI_createRestrictedMolSegSet
--go

--drop procedure MGI_createRestrictedSeqSet
--go

EOSQL
date | tee -a ${LOG}

#${MGD_DBSCHEMADIR}/trigger/trigger_drop.csh | tee -a ${LOG}
#${MGD_DBSCHEMADIR}/trigger/trigger_create.csh | tee -a ${LOG}

${MGD_DBSCHEMADIR}/procedure/PRB_ageMinMax_drop.csh | tee -a ${LOG}
${MGD_DBSCHEMADIR}/procedure/PRB_ageMinMax_create.csh | tee -a ${LOG}

#${MGD_DBSCHEMADIR}/procedure/procedure_drop.csh | tee -a ${LOG}
#${MGD_DBSCHEMADIR}/procedure/procedure_create.csh | tee -a ${LOG}

#${MGD_DBSCHEMADIR}/view/view_drop.csh | tee -a ${LOG}
#${MGD_DBSCHEMADIR}/view/view_create.csh | tee -a ${LOG}

#${MGD_DBSCHEMADIR}/key/key_drop.csh | tee -a ${LOG}
#${MGD_DBSCHEMADIR}/key/key_create.csh | tee -a ${LOG}

${MGI_DBUTILS}/bin/updateSchemaDoc.csh ${MGD_DBSERVER} ${MGD_DBNAME} | tee -a ${LOG}

${MGD_DBSCHEMADIR}/all_perms.csh | tee -a ${LOG}
${MGD_DBSCHEMADIR}/all_perms.csh | tee -a ${LOG}

${MGD_DBSCHEMADIR}/objectCounter.sh | tee -a ${LOG}

date | tee -a ${LOG}

