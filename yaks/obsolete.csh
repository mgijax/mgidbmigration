#!/bin/csh -f

if ( ${?MGICONFIG} == 0 ) then
        setenv MGICONFIG /usr/local/mgi/live/mgiconfig
endif

source ${MGICONFIG}/master.config.csh

cd `dirname $0`

setenv LOG $0.log
rm -rf $LOG
touch $LOG
 
date | tee -a $LOG
 
cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG

DROP FUNCTION IF EXISTS MAP_deleteByCollection(text);

DROP FUNCTION IF EXISTS MGI_checkUserRole(varchar,text);
DROP FUNCTION IF EXISTS MGI_checkUserTask(text,int);

drop view if exists mgd.ACC_LogicalDB_View CASCADE;
drop view if exists mgd.ALL_Annot_View CASCADE;
drop view if exists mgd.ALL_Derivation_Summary_View CASCADE;
drop view if exists mgd.BIB_All2_View CASCADE;
drop view if exists mgd.BIB_Summary_All_View CASCADE;
drop view if exists mgd.GO_Tracking_View CASCADE;
drop view if exists mgd.MGI_RoleTask_View CASCADE;
drop view if exists mgd.MGI_TranslationStrain_View CASCADE;
drop view if exists mgd.MGI_Translation_View CASCADE;
drop view if exists mgd.MGI_Note_MRKGO_View CASCADE;
drop view if exists mgd.MGI_Note_Sequence_View CASCADE;
drop view if exists mgd.MGI_Note_Source_View CASCADE;
drop view if exists mgd.MGI_NoteType_AllDriver_View CASCADE;
drop view if exists mgd.MGI_NoteType_Allele_View CASCADE;
drop view if exists mgd.MGI_NoteType_Derivation_View CASCADE;
drop view if exists mgd.MGI_NoteType_Genotype_View CASCADE;
drop view if exists mgd.MGI_NoteType_Image_View CASCADE;
drop view if exists mgd.MGI_NoteType_Marker_View CASCADE;
drop view if exists mgd.MGI_NoteType_MRKGO_View CASCADE;
drop view if exists mgd.MGI_NoteType_Probe_View CASCADE;
drop view if exists mgd.MGI_NoteType_Sequence_View CASCADE;
drop view if exists mgd.MGI_NoteType_Source_View CASCADE;
drop view if exists mgd.MGI_NoteType_VocEvidence_View CASCADE;
drop view if exists mgd.MGI_Organism_Acc_View CASCADE;
drop view if exists mgd.MGI_Organism_Marker_View CASCADE;
drop view if exists mgd.MGI_Organism_Summary_View CASCADE;
drop view if exists mgd.MGI_Organism_View CASCADE;
drop view if exists mgd.MGI_Reference_Sequence_View CASCADE;

drop view if exists mgd.MLD_Acc_View CASCADE;
drop view if exists mgd.MLD_Concordance_View CASCADE;
drop view if exists mgd.MLD_FISH_View CASCADE;
drop view if exists mgd.MLD_Hybrid_View CASCADE;
drop view if exists mgd.MLD_InSitu_View CASCADE;
drop view if exists mgd.MLD_Matrix_View CASCADE;
drop view if exists mgd.MLD_MC2point_View CASCADE;
drop view if exists mgd.MLD_RI2Point_View CASCADE;
drop view if exists mgd.MLD_RIData_View CASCADE;
drop view if exists mgd.MLD_RI_View CASCADE;
drop view if exists mgd.MLD_Statistics_View CASCADE;
drop view if exists mgd.MLD_Summary_View CASCADE;
drop view if exists mgd.RI_RISet_View CASCADE;

drop view if exists mgd.MGI_UserRole_View CASCADE;
drop view if exists mgd.MGI_UserTask_View CASCADE;

drop view if exists mgd.SEQ_Allele_Assoc_View CASCADE;
drop view if exists mgd.SEQ_Allele_View CASCADE;
drop view if exists mgd.SEQ_Marker_Cache_View CASCADE;
drop view if exists mgd.SEQ_Probe_Cache_View CASCADE;
drop view if exists mgd.SEQ_Sequence_View CASCADE;

drop view if exists mgd.PWI_ALL_Allele_View CASCADE;
drop view if exists mgd.PWI_BIB_Refs_View CASCADE;
drop view if exists mgd.PWI_MRK_Marker_View CASCADE;

EOSQL

date |tee -a $LOG

