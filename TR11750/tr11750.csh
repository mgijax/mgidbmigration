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

use $RADAR_DBNAME
go

drop table VOC_DAGSort
go

drop table VOC_Header
go

drop table VOC_Note
go

drop table VOC_Synonym
go

end

EOSQL
date | tee -a ${LOG}

${MGD_DBSCHEMADIR}/procedure/ALL_insertAllele_drop.object | tee -a $LOG
${MGD_DBSCHEMADIR}/procedure/ALL_insertAllele_create.object | tee -a $LOG
${MGD_DBSCHEMADIR}/procedure/ALL_createWildType_drop.object | tee -a $LOG
${MGD_DBSCHEMADIR}/procedure/ALL_createWildType_create.object | tee -a $LOG
${MGD_DBSCHEMADIR}/procedure/MRK_mergeWithdrawal_drop.object | tee -a $LOG
${MGD_DBSCHEMADIR}/procedure/MRK_mergeWithdrawal_create.object | tee -a $LOG
${MGD_DBSCHEMADIR}/procedure/NOM_transferToMGD_drop.object | tee -a $LOG
${MGD_DBSCHEMADIR}/procedure/NOM_transferToMGD_create.object | tee -a $LOG
${MGD_DBSCHEMADIR}/view/NOM_drop.logical | tee -a $LOG
${MGD_DBSCHEMADIR}/view/NOM_create.logical | tee -a $LOG
${MGD_DBSCHEMADIR}/view/MGI_SynonymType_Nomen_View_drop.object | tee -a $LOG
${MGD_DBSCHEMADIR}/view/MGI_SynonymType_Nomen_View_create.object | tee -a $LOG
${MGD_DBSCHEMADIR}/view/MGI_Synonym_Nomen_View_drop.object | tee -a $LOG
${MGD_DBSCHEMADIR}/view/MGI_Synonym_Nomen_View_create.object | tee -a $LOG



# Create and index new PWI specific tables
${MGD_DBSCHEMADIR}/table/PWI_Report_create.object | tee -a $LOG
${MGD_DBSCHEMADIR}/table/PWI_Report_Label_create.object | tee -a $LOG

${MGD_DBSCHEMADIR}/key/PWI_Report_create.object | tee -a $LOG

${MGD_DBSCHEMADIR}/index/PWI_Report_create.object | tee -a $LOG
${MGD_DBSCHEMADIR}/index/PWI_Report_Label_create.object | tee -a $LOG


${MGD_DBSCHEMADIR}/all_perms.csh | tee -a ${LOG}

date | tee -a ${LOG}

#${ALLCACHELOAD}/allelecrecache.csh
#${ALOMRKLOAD}/bin/alomrkload.sh
#${FEARLOAD}/bin/fearload.sh
#${VOCLOAD}/runOBOIncLoad.sh MP.config
#${VOCLOAD}/runOBOIncLoad.sh GO.config
#${VOCLOAD}/runOBOIncLoad.sh MA.config
#${VOCLOAD}/runSimpleIncLoadNoArchive.sh OMIM.config

