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

-- obsolete

drop procedure SEQ_loadMarkerCache
go

drop procedure SEQ_loadProbeCache
go

drop procedure PRB_getTissueDataSets
go

drop procedure PRB_reloadSequence
go

drop trigger MGI_Reference_Assoc_Insert
go

drop trigger HMD_Assay_Delete
go

drop trigger HMD_Class_Delete
go

drop trigger HMD_Homology_Delete
go

drop procedure HMD_updateClass
go

drop view HMD_Homology_Assay_View
go

drop view HMD_Homology_View
go

--still used by reports_db/weekly_postgres/MGI_MarkerNames.py
--drop view HMD_Homology_Pairs_View
--go

--still used by wi
--drop view HMD_Summary_View
--go

end

EOSQL
date | tee -a ${LOG}

${MGD_DBSCHEMADIR}/trigger/ACC_Accession_drop.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/trigger/ACC_Accession_create.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/trigger/MGI_Reference_Assoc_drop.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/trigger/MGI_Reference_Assoc_create.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/trigger/MRK_Marker_drop.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/trigger/MRK_Marker_create.object | tee -a ${LOG}

${MGD_DBSCHEMADIR}/procedure/SEQ_split_drop.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/procedure/SEQ_split_create.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/procedure/MRK_updateKeys_drop.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/procedure/MRK_updateKeys_create.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/procedure/MRK_reloadReference_drop.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/procedure/MRK_reloadReference_create.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/procedure/GXD_getGenotypesDataSets_drop.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/procedure/GXD_getGenotypesDataSets_create.object | tee -a ${LOG}

${MGD_DBSCHEMADIR}/index/GXD_AlleleGenotype_drop.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/index/GXD_AlleleGenotype_create.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/index/GXD_Expression_drop.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/index/GXD_Expression_create.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/index/VOC_Annot_drop.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/index/VOC_Annot_create.object | tee -a ${LOG}

${MGI_DBUTILS}/bin/updateSchemaDoc.csh ${MGD_DBSERVER} ${MGD_DBNAME} | tee -a ${LOG}

${MGD_DBSCHEMADIR}/all_perms.csh | tee -a ${LOG}
${MGD_DBSCHEMADIR}/all_perms.csh | tee -a ${LOG}

${MGD_DBSCHEMADIR}/objectCounter.sh | tee -a ${LOG}

date | tee -a ${LOG}

