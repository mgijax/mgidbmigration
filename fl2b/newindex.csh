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
drop index if exists mgd.ACC_Accession_idx_CreatedBy_key;
drop index if exists mgd.ACC_AccessionReference_idx_CreatedBy_key;
drop index if exists mgd.ACC_ActualDB_idx_CreatedBy_key;
drop index if exists mgd.ACC_LogicalDB_idx_CreatedBy_key;
drop index if exists mgd.ACC_MGIType_idx_CreatedBy_key;
drop index if exists mgd.ALL_Allele_CellLine_idx_CreatedBy_key;
drop index if exists mgd.ALL_Allele_idx_CreatedBy_key;
drop index if exists mgd.ALL_Allele_Mutation_idx_CreatedBy_key;
drop index if exists mgd.ALL_CellLine_Derivation_idx_CreatedBy_key;
drop index if exists mgd.ALL_CellLine_idx_CreatedBy_key;
drop index if exists mgd.ALL_Cre_Cache_idx_CreatedBy_key;
drop index if exists mgd.ALL_Knockout_Cache_idx_CreatedBy_key;
drop index if exists mgd.ALL_Label_idx_CreatedBy_key;
drop index if exists mgd.ALL_Variant_idx_CreatedBy_key;
drop index if exists mgd.ALL_Variant_Sequence_idx_CreatedBy_key;

drop index if exists mgd.ACC_Accession_idx_ModifiedBy_key;
drop index if exists mgd.ACC_Accession_idx_ModifiedBy_key;
drop index if exists mgd.ACC_AccessionReference_idx_ModifiedBy_key;
drop index if exists mgd.ACC_ActualDB_idx_ModifiedBy_key;
drop index if exists mgd.ACC_LogicalDB_idx_ModifiedBy_key;
drop index if exists mgd.ACC_MGIType_idx_ModifiedBy_key;
drop index if exists mgd.ALL_Allele_CellLine_idx_ModifiedBy_key;
drop index if exists mgd.ALL_Allele_idx_ModifiedBy_key;
drop index if exists mgd.ALL_Allele_Mutation_idx_ModifiedBy_key;
drop index if exists mgd.ALL_CellLine_Derivation_idx_ModifiedBy_key;
drop index if exists mgd.ALL_CellLine_idx_ModifiedBy_key;
drop index if exists mgd.ALL_Cre_Cache_idx_ModifiedBy_key;
drop index if exists mgd.ALL_Knockout_Cache_idx_ModifiedBy_key;
drop index if exists mgd.ALL_Label_idx_ModifiedBy_key;
drop index if exists mgd.ALL_Variant_idx_ModifiedBy_key;
drop index if exists mgd.ALL_Variant_Sequence_idx_ModifiedBy_key;

create index ACC_Accession_idx_CreatedBy_key on mgd.ACC_Accession (_CreatedBy_key);
create index ACC_AccessionReference_idx_CreatedBy_key on mgd.ACC_AccessionReference (_CreatedBy_key);
create index ACC_ActualDB_idx_CreatedBy_key on mgd.ACC_ActualDB (_CreatedBy_key);
create index ACC_LogicalDB_idx_CreatedBy_key on mgd.ACC_LogicalDB (_CreatedBy_key);
create index ACC_MGIType_idx_CreatedBy_key on mgd.ACC_MGIType (_CreatedBy_key);
create index ALL_Allele_CellLine_idx_CreatedBy_key on mgd.ALL_Allele_CellLine (_CreatedBy_key);
create index ALL_Allele_idx_CreatedBy_key on mgd.ALL_Allele (_CreatedBy_key);
create index ALL_CellLine_idx_CreatedBy_key on mgd.ALL_CellLine (_CreatedBy_key);
create index ALL_CellLine_Derivation_idx_CreatedBy_key on mgd.ALL_CellLine_Derivation (_CreatedBy_key);
create index ALL_Cre_Cache_idx_CreatedBy_key on mgd.ALL_Cre_Cache (_CreatedBy_key);
create index ALL_Knockout_Cache_idx_CreatedBy_key on mgd.ALL_Knockout_Cache (_CreatedBy_key);
create index ALL_Variant_idx_CreatedBy_key on mgd.ALL_Variant (_CreatedBy_key);
create index ALL_Variant_Sequence_idx_CreatedBy_key on mgd.ALL_Variant_Sequence (_CreatedBy_key);

create index ACC_Accession_idx_ModifiedBy_key on mgd.ACC_Accession (_ModifiedBy_key);
create index ACC_AccessionReference_idx_ModifiedBy_key on mgd.ACC_AccessionReference (_ModifiedBy_key);
create index ACC_ActualDB_idx_ModifiedBy_key on mgd.ACC_ActualDB (_ModifiedBy_key);
create index ACC_LogicalDB_idx_ModifiedBy_key on mgd.ACC_LogicalDB (_ModifiedBy_key);
create index ACC_MGIType_idx_ModifiedBy_key on mgd.ACC_MGIType (_ModifiedBy_key);
create index ALL_Allele_CellLine_idx_ModifiedBy_key on mgd.ALL_Allele_CellLine (_ModifiedBy_key);
create index ALL_Allele_idx_ModifiedBy_key on mgd.ALL_Allele (_ModifiedBy_key);
create index ALL_CellLine_idx_ModifiedBy_key on mgd.ALL_CellLine (_ModifiedBy_key);
create index ALL_CellLine_Derivation_idx_ModifiedBy_key on mgd.ALL_CellLine_Derivation (_ModifiedBy_key);
create index ALL_Cre_Cache_idx_ModifiedBy_key on mgd.ALL_Cre_Cache (_ModifiedBy_key);
create index ALL_Knockout_Cache_idx_ModifiedBy_key on mgd.ALL_Knockout_Cache (_ModifiedBy_key);
create index ALL_Variant_idx_ModifiedBy_key on mgd.ALL_Variant (_ModifiedBy_key);
create index ALL_Variant_Sequence_idx_ModifiedBy_key on mgd.ALL_Variant_Sequence (_ModifiedBy_key);

drop index if exists mgd.ACC_Accession_idx_creation_date;
drop index if exists mgd.ACC_AccessionReference_idx_creation_date;
drop index if exists mgd.ACC_ActualDB_idx_creation_date;
drop index if exists mgd.ACC_LogicalDB_idx_creation_date;
drop index if exists mgd.ACC_MGIType_idx_creation_date;
drop index if exists mgd.ALL_Allele_CellLine_idx_creation_date;
drop index if exists mgd.ALL_Allele_idx_creation_date;
drop index if exists mgd.ALL_Allele_Mutation_idx_creation_date;
drop index if exists mgd.ALL_CellLine_Derivation_idx_creation_date;
drop index if exists mgd.ALL_CellLine_idx_creation_date;
drop index if exists mgd.ALL_Cre_Cache_idx_creation_date;
drop index if exists mgd.ALL_Knockout_Cache_idx_creation_date;
drop index if exists mgd.ALL_Label_idx_creation_date;
drop index if exists mgd.ALL_Variant_idx_creation_date;
drop index if exists mgd.ALL_Variant_Sequence_idx_creation_date;

create index ACC_Accession_idx_creation_date on mgd.ACC_Accession (creation_date);
create index ACC_AccessionReference_idx_creation_date on mgd.ACC_AccessionReference (creation_date);
create index ACC_ActualDB_idx_creation_date on mgd.ACC_ActualDB (creation_date);
create index ACC_LogicalDB_idx_creation_date on mgd.ACC_LogicalDB (creation_date);
create index ACC_MGIType_idx_creation_date on mgd.ACC_MGIType (creation_date);
create index ALL_Allele_CellLine_idx_creation_date on mgd.ALL_Allele_CellLine (creation_date);
create index ALL_Allele_idx_creation_date on mgd.ALL_Allele (creation_date);
create index ALL_Allele_Mutation_idx_creation_date on mgd.ALL_Allele_Mutation (creation_date);
create index ALL_CellLine_idx_creation_date on mgd.ALL_CellLine (creation_date);
create index ALL_CellLine_Derivation_idx_creation_date on mgd.ALL_CellLine_Derivation (creation_date);
create index ALL_Cre_Cache_idx_creation_date on mgd.ALL_Cre_Cache (creation_date);
create index ALL_Knockout_Cache_idx_creation_date on mgd.ALL_Knockout_Cache (creation_date);
create index ALL_Label_idx_creation_date on mgd.ALL_Label (creation_date);
create index ALL_Variant_idx_creation_date on mgd.ALL_Variant (creation_date);
create index ALL_Variant_Sequence_idx_creation_date on mgd.ALL_Variant_Sequence (creation_date);

drop index if exists mgd.ACC_Accession_idx_modification_date;
drop index if exists mgd.ACC_AccessionReference_idx_modification_date;
drop index if exists mgd.ACC_ActualDB_idx_modification_date;
drop index if exists mgd.ACC_LogicalDB_idx_modification_date;
drop index if exists mgd.ACC_MGIType_idx_modification_date;
drop index if exists mgd.ALL_Allele_CellLine_idx_modification_date;
drop index if exists mgd.ALL_Allele_idx_modification_date;
drop index if exists mgd.ALL_Allele_Mutation_idx_modification_date;
drop index if exists mgd.ALL_CellLine_Derivation_idx_modification_date;
drop index if exists mgd.ALL_CellLine_idx_modification_date;
drop index if exists mgd.ALL_Cre_Cache_idx_modification_date;
drop index if exists mgd.ALL_Knockout_Cache_idx_modification_date;
drop index if exists mgd.ALL_Label_idx_modification_date;
drop index if exists mgd.ALL_Variant_idx_modification_date;
drop index if exists mgd.ALL_Variant_Sequence_idx_modification_date;

create index ACC_Accession_idx_modification_date on mgd.ACC_Accession (modification_date);
create index ACC_AccessionReference_idx_modification_date on mgd.ACC_AccessionReference (modification_date);
create index ACC_ActualDB_idx_modification_date on mgd.ACC_ActualDB (modification_date);
create index ACC_LogicalDB_idx_modification_date on mgd.ACC_LogicalDB (modification_date);
create index ACC_MGIType_idx_modification_date on mgd.ACC_MGIType (modification_date);
create index ALL_Allele_CellLine_idx_modification_date on mgd.ALL_Allele_CellLine (modification_date);
create index ALL_Allele_idx_modification_date on mgd.ALL_Allele (modification_date);
create index ALL_Allele_Mutation_idx_modification_date on mgd.ALL_Allele_Mutation (modification_date);
create index ALL_CellLine_idx_modification_date on mgd.ALL_CellLine (modification_date);
create index ALL_CellLine_Derivation_idx_modification_date on mgd.ALL_CellLine_Derivation (modification_date);
create index ALL_Cre_Cache_idx_modification_date on mgd.ALL_Cre_Cache (modification_date);
create index ALL_Knockout_Cache_idx_modification_date on mgd.ALL_Knockout_Cache (modification_date);
create index ALL_Label_idx_modification_date on mgd.ALL_Label (modification_date);
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
drop index if exists mgd.BIB_Workflow_Data_idx_creation_date;
drop index if exists mgd.BIB_Workflow_Relevance_idx_creation_date;
drop index if exists mgd.BIB_Workflow_Status_idx_creation_date;
drop index if exists mgd.BIB_Workflow_Tag_idx_creation_date;
drop index if exists mgd.BIB_Books_idx_modification_date;
drop index if exists mgd.BIB_Notes_idx_modification_date;
drop index if exists mgd.BIB_Refs_idx_modification_date;
drop index if exists mgd.BIB_Workflow_Data_idx_modification_date;
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
create index BIB_Workflow_Data_idx_creation_date on mgd.BIB_Workflow_Data (creation_date);
create index BIB_Workflow_Relevance_idx_creation_date on mgd.BIB_Workflow_Relevance (creation_date);
create index BIB_Workflow_Status_idx_creation_date on mgd.BIB_Workflow_Status (creation_date);
create index BIB_Workflow_Tag_idx_creation_date on mgd.BIB_Workflow_Tag (creation_date);
create index BIB_Books_idx_modification_date on mgd.BIB_Books (modification_date);
create index BIB_Notes_idx_modification_date on mgd.BIB_Notes (modification_date);
create index BIB_Refs_idx_modification_date on mgd.BIB_Refs (modification_date);
create index BIB_Workflow_Data_idx_modification_date on mgd.BIB_Workflow_Data (modification_date);
create index BIB_Workflow_Relevance_idx_modification_date on mgd.BIB_Workflow_Relevance (modification_date);
create index BIB_Workflow_Status_idx_modification_date on mgd.BIB_Workflow_Status (modification_date);
create index BIB_Workflow_Tag_idx_modification_date on mgd.BIB_Workflow_Tag (modification_date);

EOSQL

${MGD_DBSCHEMADIR}/objectCounter.sh | tee -a $LOG

date |tee -a $LOG

