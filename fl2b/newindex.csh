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

drop index if exists mgd.ACC_Accession_idx_CreatedBy_key;
drop index if exists mgd.ACC_AccessionReference_idx_CreatedBy_key;
drop index if exists mgd.ALL_Allele_CellLine_idx_CreatedBy_key;
drop index if exists mgd.ALL_Allele_idx_CreatedBy_key;
drop index if exists mgd.ALL_CellLine_Derivation_idx_CreatedBy_key;
drop index if exists mgd.ALL_CellLine_idx_CreatedBy_key;
drop index if exists mgd.ALL_Variant_idx_CreatedBy_key;
drop index if exists mgd.ALL_Variant_Sequence_idx_CreatedBy_key;

drop index if exists mgd.ACC_Accession_idx_ModifiedBy_key;
drop index if exists mgd.ACC_AccessionReference_idx_ModifiedBy_key;
drop index if exists mgd.ALL_Allele_CellLine_idx_ModifiedBy_key;
drop index if exists mgd.ALL_Allele_idx_ModifiedBy_key;
drop index if exists mgd.ALL_CellLine_Derivation_idx_ModifiedBy_key;
drop index if exists mgd.ALL_CellLine_idx_ModifiedBy_key;
drop index if exists mgd.ALL_Variant_idx_ModifiedBy_key;
drop index if exists mgd.ALL_Variant_Sequence_idx_ModifiedBy_key;

drop index if exists mgd.ACC_Accession_idx_creation_date;
drop index if exists mgd.ACC_AccessionReference_idx_creation_date;
drop index if exists mgd.ALL_Allele_CellLine_idx_creation_date;
drop index if exists mgd.ALL_Allele_idx_creation_date;
drop index if exists mgd.ALL_Allele_Mutation_idx_creation_date;
drop index if exists mgd.ALL_CellLine_Derivation_idx_creation_date;
drop index if exists mgd.ALL_CellLine_idx_creation_date;
drop index if exists mgd.ALL_Variant_idx_creation_date;
drop index if exists mgd.ALL_Variant_Sequence_idx_creation_date;

drop index if exists mgd.ACC_Accession_idx_modification_date;
drop index if exists mgd.ACC_AccessionReference_idx_modification_date;
drop index if exists mgd.ALL_Allele_CellLine_idx_modification_date;
drop index if exists mgd.ALL_Allele_idx_modification_date;
drop index if exists mgd.ALL_Allele_Mutation_idx_modification_date;
drop index if exists mgd.ALL_CellLine_Derivation_idx_modification_date;
drop index if exists mgd.ALL_CellLine_idx_modification_date;
drop index if exists mgd.ALL_Variant_idx_modification_date;
drop index if exists mgd.ALL_Variant_Sequence_idx_modification_date;

create index ACC_Accession_idx_CreatedBy_key on mgd.ACC_Accession (_CreatedBy_key);
create index ACC_AccessionReference_idx_CreatedBy_key on mgd.ACC_AccessionReference (_CreatedBy_key);
create index ALL_Allele_CellLine_idx_CreatedBy_key on mgd.ALL_Allele_CellLine (_CreatedBy_key);
create index ALL_Allele_idx_CreatedBy_key on mgd.ALL_Allele (_CreatedBy_key);
create index ALL_CellLine_idx_CreatedBy_key on mgd.ALL_CellLine (_CreatedBy_key);
create index ALL_CellLine_Derivation_idx_CreatedBy_key on mgd.ALL_CellLine_Derivation (_CreatedBy_key);
create index ALL_Variant_idx_CreatedBy_key on mgd.ALL_Variant (_CreatedBy_key);
create index ALL_Variant_Sequence_idx_CreatedBy_key on mgd.ALL_Variant_Sequence (_CreatedBy_key);

create index ACC_Accession_idx_ModifiedBy_key on mgd.ACC_Accession (_ModifiedBy_key);
create index ACC_AccessionReference_idx_ModifiedBy_key on mgd.ACC_AccessionReference (_ModifiedBy_key);
create index ALL_Allele_CellLine_idx_ModifiedBy_key on mgd.ALL_Allele_CellLine (_ModifiedBy_key);
create index ALL_Allele_idx_ModifiedBy_key on mgd.ALL_Allele (_ModifiedBy_key);
create index ALL_CellLine_idx_ModifiedBy_key on mgd.ALL_CellLine (_ModifiedBy_key);
create index ALL_CellLine_Derivation_idx_ModifiedBy_key on mgd.ALL_CellLine_Derivation (_ModifiedBy_key);
create index ALL_Variant_idx_ModifiedBy_key on mgd.ALL_Variant (_ModifiedBy_key);
create index ALL_Variant_Sequence_idx_ModifiedBy_key on mgd.ALL_Variant_Sequence (_ModifiedBy_key);

create index ACC_Accession_idx_creation_date on mgd.ACC_Accession (creation_date);
create index ACC_AccessionReference_idx_creation_date on mgd.ACC_AccessionReference (creation_date);
create index ALL_Allele_CellLine_idx_creation_date on mgd.ALL_Allele_CellLine (creation_date);
create index ALL_Allele_idx_creation_date on mgd.ALL_Allele (creation_date);
create index ALL_Allele_Mutation_idx_creation_date on mgd.ALL_Allele_Mutation (creation_date);
create index ALL_CellLine_idx_creation_date on mgd.ALL_CellLine (creation_date);
create index ALL_CellLine_Derivation_idx_creation_date on mgd.ALL_CellLine_Derivation (creation_date);
create index ALL_Variant_idx_creation_date on mgd.ALL_Variant (creation_date);
create index ALL_Variant_Sequence_idx_creation_date on mgd.ALL_Variant_Sequence (creation_date);

create index ACC_Accession_idx_modification_date on mgd.ACC_Accession (modification_date);
create index ACC_AccessionReference_idx_modification_date on mgd.ACC_AccessionReference (modification_date);
create index ALL_Allele_CellLine_idx_modification_date on mgd.ALL_Allele_CellLine (modification_date);
create index ALL_Allele_idx_modification_date on mgd.ALL_Allele (modification_date);
create index ALL_Allele_Mutation_idx_modification_date on mgd.ALL_Allele_Mutation (modification_date);
create index ALL_CellLine_idx_modification_date on mgd.ALL_CellLine (modification_date);
create index ALL_CellLine_Derivation_idx_modification_date on mgd.ALL_CellLine_Derivation (modification_date);
create index ALL_Variant_idx_modification_date on mgd.ALL_Variant (modification_date);
create index ALL_Variant_Sequence_idx_modification_date on mgd.ALL_Variant_Sequence (modification_date);

drop index if exists mgd.BIB_Refs_idx_CreatedBy_key;
drop index if exists mgd.BIB_Workflow_Data_idx_CreatedBy_key;
drop index if exists mgd.BIB_Workflow_Relevance_idx_CreatedBy_key;
drop index if exists mgd.BIB_Workflow_Status_idx_CreatedBy_key;
drop index if exists mgd.BIB_Workflow_Tag_idx_CreatedBy_key;
drop index if exists mgd.BIB_Refs_idx_ModifiedBy_key;
drop index if exists mgd.BIB_Workflow_Data_idx_ModifiedBy_key;
drop index if exists mgd.BIB_Workflow_Relevance_idx_ModifiedBy_key;
drop index if exists mgd.BIB_Workflow_Status_idx_ModifiedBy_key;
drop index if exists mgd.BIB_Workflow_Tag_idx_ModifiedBy_key;
drop index if exists mgd.BIB_Books_idx_creation_date;
drop index if exists mgd.BIB_Notes_idx_creation_date;
drop index if exists mgd.BIB_Refs_idx_creation_date;
drop index if exists mgd.BIB_Workflow_Relevance_idx_creation_date;
drop index if exists mgd.BIB_Workflow_Status_idx_creation_date;
drop index if exists mgd.BIB_Workflow_Tag_idx_creation_date;
drop index if exists mgd.BIB_Books_idx_modification_date;
drop index if exists mgd.BIB_Notes_idx_modification_date;
drop index if exists mgd.BIB_Refs_idx_modification_date;
drop index if exists mgd.BIB_Workflow_Relevance_idx_modification_date;
drop index if exists mgd.BIB_Workflow_Status_idx_modification_date;
drop index if exists mgd.BIB_Workflow_Tag_idx_modification_date;

create index BIB_Refs_idx_CreatedBy_key on mgd.BIB_Refs (_CreatedBy_key);
create index BIB_Workflow_Data_idx_CreatedBy_key on mgd.BIB_Workflow_Data (_CreatedBy_key);
create index BIB_Workflow_Relevance_idx_CreatedBy_key on mgd.BIB_Workflow_Relevance (_CreatedBy_key);
create index BIB_Workflow_Status_idx_CreatedBy_key on mgd.BIB_Workflow_Status (_CreatedBy_key);
create index BIB_Workflow_Tag_idx_CreatedBy_key on mgd.BIB_Workflow_Tag (_CreatedBy_key);
create index BIB_Refs_idx_ModifiedBy_key on mgd.BIB_Refs (_ModifiedBy_key);
create index BIB_Workflow_Data_idx_ModifiedBy_key on mgd.BIB_Workflow_Data (_ModifiedBy_key);
create index BIB_Workflow_Relevance_idx_ModifiedBy_key on mgd.BIB_Workflow_Relevance (_ModifiedBy_key);
create index BIB_Workflow_Status_idx_ModifiedBy_key on mgd.BIB_Workflow_Status (_ModifiedBy_key);
create index BIB_Workflow_Tag_idx_ModifiedBy_key on mgd.BIB_Workflow_Tag (_ModifiedBy_key);
create index BIB_Books_idx_creation_date on mgd.BIB_Books (creation_date);
create index BIB_Notes_idx_creation_date on mgd.BIB_Notes (creation_date);
create index BIB_Refs_idx_creation_date on mgd.BIB_Refs (creation_date);
create index BIB_Workflow_Relevance_idx_creation_date on mgd.BIB_Workflow_Relevance (creation_date);
create index BIB_Workflow_Status_idx_creation_date on mgd.BIB_Workflow_Status (creation_date);
create index BIB_Workflow_Tag_idx_creation_date on mgd.BIB_Workflow_Tag (creation_date);
create index BIB_Books_idx_modification_date on mgd.BIB_Books (modification_date);
create index BIB_Notes_idx_modification_date on mgd.BIB_Notes (modification_date);
create index BIB_Refs_idx_modification_date on mgd.BIB_Refs (modification_date);
create index BIB_Workflow_Relevance_idx_modification_date on mgd.BIB_Workflow_Relevance (modification_date);
create index BIB_Workflow_Status_idx_modification_date on mgd.BIB_Workflow_Status (modification_date);
create index BIB_Workflow_Tag_idx_modification_date on mgd.BIB_Workflow_Tag (modification_date);

drop index if exists mgd.GO_Tracking_idx_CreatedBy_key;
drop index if exists mgd.GO_Tracking_idx_ModifiedBy_key;
drop index if exists mgd.GO_Tracking_idx_creation_date;
drop index if exists mgd.GO_Tracking_idx_modification_date;

create index GO_Tracking_idx_CreatedBy_key on mgd.GO_Tracking (_CreatedBy_key);
create index GO_Tracking_idx_ModifiedBy_key on mgd.GO_Tracking (_ModifiedBy_key);
create index GO_Tracking_idx_creation_date on mgd.GO_Tracking (creation_date);
create index GO_Tracking_idx_modification_date on mgd.GO_Tracking (modification_date);

drop index if exists mgd.GXD_AllelePair_idx_CreatedBy_key;
drop index if exists mgd.GXD_Antibody_idx_CreatedBy_key;
drop index if exists mgd.GXD_Antigen_idx_CreatedBy_key;
drop index if exists mgd.GXD_Assay_idx_CreatedBy_key;
drop index if exists mgd.GXD_Genotype_idx_CreatedBy_key;
drop index if exists mgd.GXD_HTExperiment_idx_CreatedBy_key;
drop index if exists mgd.GXD_HTRawSample_idx_CreatedBy_key;
drop index if exists mgd.GXD_HTSample_idx_CreatedBy_key;
drop index if exists mgd.GXD_Index_idx_CreatedBy_key;

drop index if exists mgd.GXD_AllelePair_idx_ModifiedBy_key;
drop index if exists mgd.GXD_Antibody_idx_ModifiedBy_key;
drop index if exists mgd.GXD_Antigen_idx_ModifiedBy_key;
drop index if exists mgd.GXD_Assay_idx_ModifiedBy_key;
drop index if exists mgd.GXD_Genotype_idx_ModifiedBy_key;
drop index if exists mgd.GXD_HTExperiment_idx_ModifiedBy_key;
drop index if exists mgd.GXD_HTRawSample_idx_ModifiedBy_key;
drop index if exists mgd.GXD_HTSample_idx_ModifiedBy_key;
drop index if exists mgd.GXD_Index_idx_ModifiedBy_key;

drop index if exists mgd.GXD_AllelePair_idx_creation_date;
drop index if exists mgd.GXD_Antibody_idx_creation_date;
drop index if exists mgd.GXD_Antigen_idx_creation_date;
drop index if exists mgd.GXD_Assay_idx_creation_date;
drop index if exists mgd.GXD_Genotype_idx_creation_date;
drop index if exists mgd.GXD_HTExperiment_idx_creation_date;
drop index if exists mgd.GXD_HTRawSample_idx_creation_date;
drop index if exists mgd.GXD_HTSample_idx_creation_date;
drop index if exists mgd.GXD_Index_idx_creation_date;

drop index if exists mgd.GXD_AllelePair_idx_modification_date;
drop index if exists mgd.GXD_Antibody_idx_modification_date;
drop index if exists mgd.GXD_Antigen_idx_modification_date;
drop index if exists mgd.GXD_Assay_idx_modification_date;
drop index if exists mgd.GXD_Genotype_idx_modification_date;
drop index if exists mgd.GXD_HTExperiment_idx_modification_date;
drop index if exists mgd.GXD_HTRawSample_idx_modification_date;
drop index if exists mgd.GXD_HTSample_idx_modification_date;
drop index if exists mgd.GXD_Index_idx_modification_date;

create index GXD_AllelePair_idx_CreatedBy_key on mgd.GXD_AllelePair (_CreatedBy_key);
create index GXD_Antibody_idx_CreatedBy_key on mgd.GXD_Antibody (_CreatedBy_key);
create index GXD_Antigen_idx_CreatedBy_key on mgd.GXD_Antigen (_CreatedBy_key);
create index GXD_Assay_idx_CreatedBy_key on mgd.GXD_Assay (_CreatedBy_key);
create index GXD_Genotype_idx_CreatedBy_key on mgd.GXD_Genotype (_CreatedBy_key);
create index GXD_HTExperiment_idx_CreatedBy_key on mgd.GXD_HTExperiment (_CreatedBy_key);
create index GXD_HTRawSample_idx_CreatedBy_key on mgd.GXD_HTRawSample (_CreatedBy_key);
create index GXD_HTSample_idx_CreatedBy_key on mgd.GXD_HTSample (_CreatedBy_key);
create index GXD_Index_idx_CreatedBy_key on mgd.GXD_Index (_CreatedBy_key);

create index GXD_AllelePair_idx_ModifiedBy_key on mgd.GXD_AllelePair (_ModifiedBy_key);
create index GXD_Antibody_idx_ModifiedBy_key on mgd.GXD_Antibody (_ModifiedBy_key);
create index GXD_Antigen_idx_ModifiedBy_key on mgd.GXD_Antigen (_ModifiedBy_key);
create index GXD_Assay_idx_ModifiedBy_key on mgd.GXD_Assay (_ModifiedBy_key);
create index GXD_Genotype_idx_ModifiedBy_key on mgd.GXD_Genotype (_ModifiedBy_key);
create index GXD_HTExperiment_idx_ModifiedBy_key on mgd.GXD_HTExperiment (_ModifiedBy_key);
create index GXD_HTRawSample_idx_ModifiedBy_key on mgd.GXD_HTRawSample (_ModifiedBy_key);
create index GXD_HTSample_idx_ModifiedBy_key on mgd.GXD_HTSample (_ModifiedBy_key);
create index GXD_Index_idx_ModifiedBy_key on mgd.GXD_Index (_ModifiedBy_key);

create index GXD_AllelePair_idx_creation_date on mgd.GXD_AllelePair (creation_date);
create index GXD_Antibody_idx_creation_date on mgd.GXD_Antibody (creation_date);
create index GXD_Antigen_idx_creation_date on mgd.GXD_Antigen (creation_date);
create index GXD_Assay_idx_creation_date on mgd.GXD_Assay (creation_date);
create index GXD_Genotype_idx_creation_date on mgd.GXD_Genotype (creation_date);
create index GXD_HTExperiment_idx_creation_date on mgd.GXD_HTExperiment (creation_date);
create index GXD_HTRawSample_idx_creation_date on mgd.GXD_HTRawSample (creation_date);
create index GXD_HTSample_idx_creation_date on mgd.GXD_HTSample (creation_date);
create index GXD_Index_idx_creation_date on mgd.GXD_Index (creation_date);

create index GXD_AllelePair_idx_modification_date on mgd.GXD_AllelePair (modification_date);
create index GXD_Antibody_idx_modification_date on mgd.GXD_Antibody (modification_date);
create index GXD_Antigen_idx_modification_date on mgd.GXD_Antigen (modification_date);
create index GXD_Assay_idx_modification_date on mgd.GXD_Assay (modification_date);
create index GXD_Genotype_idx_modification_date on mgd.GXD_Genotype (modification_date);
create index GXD_HTExperiment_idx_modification_date on mgd.GXD_HTExperiment (modification_date);
create index GXD_HTRawSample_idx_modification_date on mgd.GXD_HTRawSample (modification_date);
create index GXD_HTSample_idx_modification_date on mgd.GXD_HTSample (modification_date);
create index GXD_Index_idx_modification_date on mgd.GXD_Index (modification_date);

drop index if exists mgd.IMG_Image_idx_CreatedBy_key;
drop index if exists mgd.IMG_Image_idx_ModifiedBy_key;
drop index if exists mgd.IMG_Image_idx_creation_date;
drop index if exists mgd.IMG_Image_idx_modification_date;

create index IMG_Image_idx_CreatedBy_key on mgd.IMG_Image (_CreatedBy_key);
create index IMG_Image_idx_ModifiedBy_key on mgd.IMG_Image (_ModifiedBy_key);
create index IMG_Image_idx_creation_date on mgd.IMG_Image (creation_date);
create index IMG_Image_idx_modification_date on mgd.IMG_Image (modification_date);

drop index if exists mgd.PRB_Probe_idx_CreatedBy_key;
drop index if exists mgd.PRB_Probe_idx_ModifiedBy_key;
drop index if exists mgd.PRB_Probe_idx_creation_date;
drop index if exists mgd.PRB_Probe_idx_modification_date;

create index PRB_Probe_idx_CreatedBy_key on mgd.PRB_Probe (_CreatedBy_key);
create index PRB_Probe_idx_ModifiedBy_key on mgd.PRB_Probe (_ModifiedBy_key);
create index PRB_Probe_idx_creation_date on mgd.PRB_Probe (creation_date);
create index PRB_Probe_idx_modification_date on mgd.PRB_Probe (modification_date);

drop index if exists mgd.MRK_Marker_idx_CreatedBy_key;
drop index if exists mgd.MRK_Marker_idx_ModifiedBy_key;
drop index if exists mgd.MRK_Marker_idx_creation_date;
drop index if exists mgd.MRK_Marker_idx_modification_date;

create index MRK_Marker_idx_CreatedBy_key on mgd.MRK_Marker (_CreatedBy_key);
create index MRK_Marker_idx_ModifiedBy_key on mgd.MRK_Marker (_ModifiedBy_key);
create index MRK_Marker_idx_creation_date on mgd.MRK_Marker (creation_date);
create index MRK_Marker_idx_modification_date on mgd.MRK_Marker (modification_date);

drop index if exists mgd.PRB_Strain_idx_CreatedBy_key;
drop index if exists mgd.PRB_Strain_idx_ModifiedBy_key;
drop index if exists mgd.PRB_Strain_idx_creation_date;
drop index if exists mgd.PRB_Strain_idx_modification_date;

create index PRB_Strain_idx_CreatedBy_key on mgd.PRB_Strain (_CreatedBy_key);
create index PRB_Strain_idx_ModifiedBy_key on mgd.PRB_Strain (_ModifiedBy_key);
create index PRB_Strain_idx_creation_date on mgd.PRB_Strain (creation_date);
create index PRB_Strain_idx_modification_date on mgd.PRB_Strain (modification_date);

drop index if exists mgd.VOC_Evidence_idx_CreatedBy_key;
drop index if exists mgd.VOC_Evidence_idx_ModifiedBy_key;
drop index if exists mgd.VOC_Evidence_idx_creation_date;
drop index if exists mgd.VOC_Evidence_idx_modification_date;

create index VOC_Evidence_idx_CreatedBy_key on mgd.VOC_Evidence (_CreatedBy_key);
create index VOC_Evidence_idx_ModifiedBy_key on mgd.VOC_Evidence (_ModifiedBy_key);
create index VOC_Evidence_idx_creation_date on mgd.VOC_Evidence (creation_date);
create index VOC_Evidence_idx_modification_date on mgd.VOC_Evidence (modification_date);

drop index if exists mgd.MLD_Expts_idx_creation_date;
drop index if exists mgd.MLD_Expts_idx_modification_date;
create index MLD_Expts_idx_creation_date on mgd.MLD_Expts (creation_date);
create index MLD_Expts_idx_modification_date on mgd.MLD_Expts (modification_date);

drop index if exists mgd.GXD_Index_Stages_idx_CreatedBy_key;
drop index if exists mgd.GXD_Index_Stages_idx_ModifiedBy_key;
drop index if exists mgd.GXD_Index_Stages_idx_creation_date;
drop index if exists mgd.GXD_Index_Stages_idx_modification_date;
create index GXD_Index_Stages_idx_CreatedBy_key on mgd.GXD_Index_Stages (_CreatedBy_key);
create index GXD_Index_Stages_idx_ModifiedBy_key on mgd.GXD_Index_Stages (_ModifiedBy_key);
create index GXD_Index_Stages_idx_creation_date on mgd.GXD_Index_Stages (creation_date);
create index GXD_Index_Stages_idx_modification_date on mgd.GXD_Index_Stages (modification_date);

drop index if exists mgd.MRK_History_idx_CreatedBy_key;
drop index if exists mgd.MRK_History_idx_ModifiedBy_key;
drop index if exists mgd.MRK_History_idx_creation_date;
drop index if exists mgd.MRK_History_idx_modification_date;
create index MRK_History_idx_CreatedBy_key on mgd.MRK_History (_CreatedBy_key);
create index MRK_History_idx_ModifiedBy_key on mgd.MRK_History (_ModifiedBy_key);
create index MRK_History_idx_creation_date on mgd.MRK_History (creation_date);
create index MRK_History_idx_modification_date on mgd.MRK_History (modification_date);

drop index if exists mgd.SEQ_Allele_Assoc_idx_Refs_key;
drop index if exists mgd.SEQ_Allele_Assoc_idx_CreatedBy_key;
drop index if exists mgd.SEQ_Allele_Assoc_idx_ModifiedBy_key;
create index SEQ_Allele_Assoc_idx_Refs_key on mgd.SEQ_Allele_Assoc (_Refs_key);
create index SEQ_Allele_Assoc_idx_CreatedBy_key on mgd.SEQ_Allele_Assoc (_CreatedBy_key);
create index SEQ_Allele_Assoc_idx_ModifiedBy_key on mgd.SEQ_Allele_Assoc (_ModifiedBy_key);

drop index if exists mgd.MGI_Set_idx_CreatedBy_key;
drop index if exists mgd.MGI_Set_idx_ModifiedBy_key;
create index MGI_Set_idx_CreatedBy_key on mgd.MGI_Set (_CreatedBy_key);
create index MGI_Set_idx_ModifiedBy_key on mgd.MGI_Set (_ModifiedBy_key);

drop index if exists mgd.ALL_Cre_Cache_idx_CreatedBy_key;
drop index if exists mgd.ALL_Cre_Cache_idx_ModifiedBy_key;

drop index if exists mgd.BIB_Citation_Cache_idx_mgiID;
create index BIB_Citation_Cache_idx_mgiID on mgd.BIB_Citation_Cache (mgiID);

EOSQL

${MGD_DBSCHEMADIR}/index/MLD_Expt_Marker_drop.object | tee -a $LOG
${MGD_DBSCHEMADIR}/index/MLD_Expt_Marker_create.object | tee -a $LOG

${MGD_DBSCHEMADIR}/objectCounter.sh | tee -a $LOG

date |tee -a $LOG

