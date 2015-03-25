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

--still used by reports_db/weekly_postgres/MGI_MarkerNames.py
--drop view HMD_Homology_Pairs_View
--go

--still used by wi
--drop view HMD_Summary_View
--go

drop trigger PRB_Marker_Delete
go

drop trigger GXD_Index_Update
go

-- Pheno:Tier 3 (jr curator)
delete from MGI_UserRole where _Role_key in (706920)
go
delete from VOC_Term where _Term_key in (706920)
go

-- keep
select * from VOC_Term where _Vocab_key = 34 
and term in ('pheno:use Delete button', 'pheno:edit nomen data deleted', 'pheno:create/modify references/deleted')
go

delete from VOC_Term where _Vocab_key = 34
and term not in ('pheno:use Delete button', 'pheno:edit nomen data deleted', 'pheno:create/modify references/deleted')
go

-- what is left
select * from VOC_Term where _Vocab_key = 34 
go

drop trigger ALL_Allele_Mutation_Insert
go
drop trigger ALL_Allele_Mutation_Delete
go
drop trigger MGI_Note_Insert
go
drop trigger MGI_Synonym_Insert
go
drop trigger MGI_Synonym_Delete
go
drop trigger MRK_Notes_Insert
go

end

EOSQL
date | tee -a ${LOG}

${MGD_DBSCHEMADIR}/trigger/PRB_Marker_drop.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/trigger/PRB_Marker_create.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/trigger/GXD_Index_drop.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/trigger/GXD_Index_create.object | tee -a ${LOG}

${MGD_DBSCHEMADIR}/trigger/ALL_Allele_drop.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/trigger/ALL_Allele_create.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/trigger/ALL_CellLine_Derivation_drop.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/trigger/ALL_CellLine_Derivation_create.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/trigger/ALL_CellLine_drop.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/trigger/ALL_CellLine_create.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/trigger/MGI_Note_drop.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/trigger/MGI_Note_create.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/trigger/MGI_Reference_Assoc_drop.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/trigger/MGI_Reference_Assoc_create.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/trigger/MGI_Synonym_drop.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/trigger/MRK_Notes_drop.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/procedure/MGI_checkUserRole_drop.object | tee -a ${LOG}
${MGD_DBSCHEMADIR}/procedure/MGI_checkUserRole_create.object | tee -a ${LOG}

${MGI_DBUTILS}/bin/updateSchemaDoc.csh ${MGD_DBSERVER} ${MGD_DBNAME} | tee -a ${LOG}

${MGD_DBSCHEMADIR}/all_perms.csh | tee -a ${LOG}
${MGD_DBSCHEMADIR}/all_perms.csh | tee -a ${LOG}

${MGD_DBSCHEMADIR}/objectCounter.sh | tee -a ${LOG}

date | tee -a ${LOG}

