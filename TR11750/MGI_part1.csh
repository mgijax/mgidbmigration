#!/bin/csh -fx

#
# Migration for TR11750
# (part 1)
#

###----------------------###
###--- initialization ---###
###----------------------###

#if ( ${?MGICONFIG} == 0 ) then
#	setenv MGICONFIG /usr/local/mgi/live/mgiconfig
#endif
#
#source ${MGICONFIG}/master.config.csh

# start a new log file for this migration, and add a datestamp

setenv LOG $0.log
rm -rf ${LOG}
touch ${LOG}

#
# PLEASE READ!
# FOR TESTING ONLY 
# MAKE SURE BOTH ARE TURNED OFF FOR REAL MIGRATION
#
#${MGI_DBUTILS}/bin/load_db.csh ${RADAR_DBSERVER} ${RADAR_DBNAME} /backups/rohan/scrum-dog/radar.backup
${MGI_DBUTILS}/bin/load_db.csh ${MGD_DBSERVER} ${MGD_DBNAME} /backups/rohan/scrum-dog/mgd_dog.backup

date | tee -a ${LOG}

cat - <<EOSQL | doisql.csh $MGD_DBSERVER $MGD_DBNAME $0 | tee -a $LOG

use $MGD_DBNAME
go

update NOM_Marker set _Marker_Event_key = 1
go

update NOM_Marker set _NomenStatus_key = 166903 where _NomenStatus_key in (166902, 166904)
go

delete from VOC_Term where _Term_key in (166902,166904,166905)
go

update VOC_Term set term = 'Broadcast' where _Term_key = 166903
go

drop procedure PRB_getTissueDataSets
go

drop procedure NOM_updateReserved
go

drop procedure MRK_reloadSequence
go

drop view MGI_Organism_Sequence_View
go

exec MGI_Table_Column_Cleanup
go

-- add indexes for PG/referential integrity that are missing

create nonclustered index idx_Allele_Type_key on ALL_Cre_Cache (_Allele_Type_key) on seg1
go

create nonclustered index idx_System_key on ALL_Cre_Cache (_System_key) on seg1
go

create nonclustered index idx_Qualifier_key on ALL_Marker_Assoc (_Qualifier_key) on seg1
go

create nonclustered index idx_CurationState_key on MRK_Marker (_CurationState_key) on seg1
go

create nonclustered index idx_Evidence_key on MGI_Relationship (_Evidence_key) on seg1
go

create nonclustered index idx_Qualifier_key on MGI_Relationship (_Qualifier_key) on seg1
go

create nonclustered index idx_NomenStatus_key on NOM_Marker (_NomenStatus_key) on seg1
go

create nonclustered index idx_CurationState_key on NOM_Marker (_CurationState_key) on seg1
go

create nonclustered index idx_Qualifier_key on SEQ_Allele_Assoc (_Qualifier_key) on seg1
go

create nonclustered index idx_TagMethod_key on SEQ_GeneTrap (_TagMethod_key) on seg1
go

create nonclustered index idx_VectorEnd_key on SEQ_GeneTrap (_VectorEnd_key) on seg1
go

create nonclustered index idx_ReverseComp_key on SEQ_GeneTrap (_ReverseComp_key) on seg1
go

checkpoint
go
end

EOSQL
date | tee -a ${LOG}

${MGD_DBSCHEMADIR}/trigger/MRK_Marker_drop.object | tee -a $LOG
${MGD_DBSCHEMADIR}/trigger/MRK_Marker_create.object | tee -a $LOG
${MGD_DBSCHEMADIR}/procedure/ALL_insertAllele_drop.object | tee -a $LOG
${MGD_DBSCHEMADIR}/procedure/ALL_insertAllele_create.object | tee -a $LOG
${MGD_DBSCHEMADIR}/procedure/ALL_createWildType_drop.object | tee -a $LOG
${MGD_DBSCHEMADIR}/procedure/ALL_createWildType_create.object | tee -a $LOG
${MGD_DBSCHEMADIR}/procedure/MRK_simpleWithdrawal_drop.object | tee -a $LOG
${MGD_DBSCHEMADIR}/procedure/MRK_simpleWithdrawal_create.object | tee -a $LOG
${MGD_DBSCHEMADIR}/procedure/MRK_mergeWithdrawal_drop.object | tee -a $LOG
${MGD_DBSCHEMADIR}/procedure/MRK_mergeWithdrawal_create.object | tee -a $LOG

${MGD_DBSCHEMADIR}/index/NOM_Marker_drop.object | tee -a $LOG
${MGD_DBSCHEMADIR}/index/NOM_Marker_create.object | tee -a $LOG
${MGD_DBSCHEMADIR}/procedure/NOM_transferToMGD_drop.object | tee -a $LOG
${MGD_DBSCHEMADIR}/procedure/NOM_updateReserved_drop.object | tee -a $LOG
${MGD_DBSCHEMADIR}/procedure/NOM_transferToMGD_create.object | tee -a $LOG
${MGD_DBSCHEMADIR}/procedure/NOM_updateReserved_create.object | tee -a $LOG
${MGD_DBSCHEMADIR}/trigger/NOM_Marker_drop.object | tee -a $LOG
${MGD_DBSCHEMADIR}/trigger/NOM_Marker_create.object | tee -a $LOG
${MGD_DBSCHEMADIR}/view/NOM_drop.logical | tee -a $LOG
${MGD_DBSCHEMADIR}/view/NOM_create.logical | tee -a $LOG
${MGD_DBSCHEMADIR}/view/MGI_SynonymType_Nomen_View_drop.object | tee -a $LOG
${MGD_DBSCHEMADIR}/view/MGI_SynonymType_Nomen_View_create.object | tee -a $LOG
${MGD_DBSCHEMADIR}/view/MGI_Synonym_Nomen_View_drop.object | tee -a $LOG
${MGD_DBSCHEMADIR}/view/MGI_Synonym_Nomen_View_create.object | tee -a $LOG

${MGD_DBSCHEMADIR}/procedure/ACC_delete_byAccKey_drop.object | tee -a $LOG
${MGD_DBSCHEMADIR}/procedure/ACC_delete_byAccKey_create.object | tee -a $LOG

###-----------------------###
###--- final datestamp ---###
###-----------------------###

date | tee -a ${LOG}

#
# set permissions & counts
#
${MGD_DBSCHEMADIR}/all_perms.csh | tee -a ${LOG}
${MGD_DBSCHEMADIR}/all_perms.csh | tee -a ${LOG}
${MGD_DBSCHEMADIR}/objectCounter.sh | tee -a ${LOG}

date | tee -a ${LOG}
echo "--- Finished" | tee -a ${LOG}

