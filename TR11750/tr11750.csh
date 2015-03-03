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

${MGD_DBSCHEMADIR}/objectCounter.sh | tee -a ${LOG}

cat - <<EOSQL | doisql.csh $MGD_DBSERVER $MGD_DBNAME $0 | tee -a $LOG

use $MGD_DBNAME
go

-- obsolete
drop view MLC_Marker_View
go

drop trigger MLC_Text_Delete
go

end

EOSQL
date | tee -a ${LOG}

${MGD_DBSCHEMADIR}/trigger/BIB_Refs_drop.object | tee -a $LOG
${MGD_DBSCHEMADIR}/trigger/BIB_Refs_create.object | tee -a $LOG
${MGD_DBSCHEMADIR}/trigger/MRK_Marker_drop.object | tee -a $LOG
${MGD_DBSCHEMADIR}/trigger/MRK_Marker_create.object | tee -a $LOG

${MGD_DBSCHEMADIR}/procedure/MRK_updateKeys_drop.object | tee -a $LOG
${MGD_DBSCHEMADIR}/procedure/MRK_updateKeys_create.object | tee -a $LOG
${MGD_DBSCHEMADIR}/procedure/BIB_getCopyright_drop.object | tee -a $LOG
${MGD_DBSCHEMADIR}/procedure/BIB_getCopyright_create.object | tee -a $LOG

-- GXD_Expression
${MGD_DBSCHEMADIR}/table/GXD_Expression_drop.object | tee -a $LOG
${MGD_DBSCHEMADIR}/table/GXD_Expression_create.object | tee -a $LOG
${MGD_DBSCHEMADIR}/key/GXD_Expression_create.object | tee -a $LOG

# update referencing keys
${MGD_DBSCHEMADIR}/key/BIB_Refs_drop.object | tee -a $LOG
${MGD_DBSCHEMADIR}/key/BIB_Refs_create.object | tee -a $LOG
${MGD_DBSCHEMADIR}/key/MRK_Marker_drop.object | tee -a $LOG
${MGD_DBSCHEMADIR}/key/MRK_Marker_create.object | tee -a $LOG
${MGD_DBSCHEMADIR}/key/GXD_Assay_drop.object | tee -a $LOG
${MGD_DBSCHEMADIR}/key/GXD_Assay_create.object | tee -a $LOG
${MGD_DBSCHEMADIR}/key/GXD_AssayType_drop.object | tee -a $LOG
${MGD_DBSCHEMADIR}/key/GXD_AssayType_create.object | tee -a $LOG
${MGD_DBSCHEMADIR}/key/GXD_Genotype_drop.object | tee -a $LOG
${MGD_DBSCHEMADIR}/key/GXD_Genotype_create.object | tee -a $LOG
${MGD_DBSCHEMADIR}/key/GXD_Structure_drop.object | tee -a $LOG
${MGD_DBSCHEMADIR}/key/GXD_Structure_create.object | tee -a $LOG
${MGD_DBSCHEMADIR}/key/GXD_Specimen_drop.object | tee -a $LOG
${MGD_DBSCHEMADIR}/key/GXD_Specimen_create.object | tee -a $LOG
${MGD_DBSCHEMADIR}/key/GXD_GelLane_drop.object | tee -a $LOG
${MGD_DBSCHEMADIR}/key/GXD_GelLane_create.object | tee -a $LOG

# update referencing procedures
${MGD_DBSCHEMADIR}/procedure/GXD_getGenotypesDataSets_drop.object | tee -a $LOG
${MGD_DBSCHEMADIR}/procedure/GXD_getGenotypesDataSets_create.object | tee -a $LOG
${MGD_DBSCHEMADIR}/procedure/MGI_resetAgeMinMax_drop.object | tee -a $LOG
${MGD_DBSCHEMADIR}/procedure/MGI_resetAgeMinMax_create.object | tee -a $LOG
${MGD_DBSCHEMADIR}/procedure/MRK_updateKeys_drop.object | tee -a $LOG
${MGD_DBSCHEMADIR}/procedure/MRK_updateKeys_create.object | tee -a $LOG
${MGD_DBSCHEMADIR}/procedure/PRB_getStrainByReference_drop.object | tee -a $LOG
${MGD_DBSCHEMADIR}/procedure/PRB_getStrainByReference_create.object | tee -a $LOG
${MGD_DBSCHEMADIR}/procedure/PRB_getStrainReferences_drop.object | tee -a $LOG
${MGD_DBSCHEMADIR}/procedure/PRB_getStrainReferences_create.object | tee -a $LOG

# update referencing triggers
${MGD_DBSCHEMADIR}/trigger/GXD_Assay_drop.object | tee -a $LOG
${MGD_DBSCHEMADIR}/trigger/GXD_Assay_create.object | tee -a $LOG
${MGD_DBSCHEMADIR}/trigger/GXD_AssayType_drop.object | tee -a $LOG
${MGD_DBSCHEMADIR}/trigger/GXD_AssayType_create.object | tee -a $LOG
${MGD_DBSCHEMADIR}/trigger/GXD_Genotype_drop.object | tee -a $LOG
${MGD_DBSCHEMADIR}/trigger/GXD_Genotype_create.object | tee -a $LOG
${MGD_DBSCHEMADIR}/trigger/GXD_Structure_drop.object | tee -a $LOG
${MGD_DBSCHEMADIR}/trigger/GXD_Structure_create.object | tee -a $LOG

${MGD_DBSCHEMADIR}/default/GXD_Expression_bind.object | tee -a $LOG
${MGD_DBSCHEMADIR}/index/GXD_Expression_create.object | tee -a $LOG

cat - <<EOSQL | doisql.csh $MGD_DBSERVER $MGD_DBNAME $0 | tee -a $LOG

use $MGD_DBNAME
go

exec MGI_Table_Column_Cleanup
go

end

EOSQL
date | tee -a ${LOG}

${MGD_DBSCHEMADIR}/all_perms.csh | tee -a ${LOG}
${MGD_DBSCHEMADIR}/all_perms.csh | tee -a ${LOG}

${MGICACHELOAD}/gxdexpression.csh | tee -a ${LOG}

${MGD_DBSCHEMADIR}/objectCounter.sh | tee -a ${LOG}

date | tee -a ${LOG}

