#!/bin/csh -f

#
# Migration for:
#	(to add/convert _CreatedBy_key, _ModifiedBy_key fields)
#
#	ACC_ActualDB
#	ACC_LogicalDB
#	ACC_MGIType
#	ALL_Allele
#	GXD_AlleleGenotype
#	GXD_Assay
#	GXD_Genotype
#	GXD_Index
#	GXD_Index_Stages
#	MGI_Note 
#	MGI_NoteChunk
#	MGI_NoteType
#	MGI_RefAssocType
#	MGI_Reference_Assoc
#	MGI_Set
#	MGI_SetMember
#	MGI_Translation
#	MGI_TranslationType
#	MLD_Marker
#	MRK_Chromosome
#	MRK_History
#	NOM_GeneFamily
#	NOM_Marker
#	NOM_Synonym
#	PRB_Alias
#	PRB_Allele
#	PRB_Allele_Strain
#	PRB_Probe
#	PRB_Reference
#	PRB_RFLV
#	VOC_Evidence
#	VOC_Term
#

cd `dirname $0` && source ./Configuration

setenv LOG $0.log
rm -rf $LOG
touch $LOG
 
date >> $LOG
echo "Created By/Modified By Migration..." | tee -a $LOG

cat - <<EOSQL | doisql.csh $0 >> $LOG

use $DBNAME
go

sp_rename ACC_ActualDB, ACC_ActualDB_Old
go

sp_rename ACC_LogicalDB, ACC_LogicalDB_Old
go

sp_rename ACC_MGIType, ACC_MGIType_Old
go

sp_rename ALL_Allele, ALL_Allele_Old
go

sp_rename GXD_AlleleGenotype, GXD_AlleleGenotype_Old
go

sp_rename GXD_Assay, GXD_Assay_Old
go

sp_rename GXD_Genotype, GXD_Genotype_Old
go

sp_rename GXD_Index, GXD_Index_Old
go

sp_rename GXD_Index_Stages, GXD_Index_Stages_Old
go

sp_rename MGI_Note, MGI_Note_Old
go

sp_rename MGI_NoteChunk, MGI_NoteChunk_Old
go

sp_rename MGI_NoteType, MGI_NoteType_Old
go

sp_rename MGI_RefAssocType, MGI_RefAssocType_Old
go

sp_rename MGI_Reference_Assoc, MGI_Reference_Assoc_Old
go

sp_rename MGI_Set, MGI_Set_Old
go

sp_rename MGI_SetMember, MGI_SetMember_Old
go

sp_rename MGI_Translation, MGI_Translation_Old
go

sp_rename MGI_TranslationType, MGI_TranslationType_Old
go

sp_rename MLD_Marker, MLD_Marker_Old
go

sp_rename MRK_Chromosome, MRK_Chromosome_Old
go

sp_rename MRK_History, MRK_History_Old
go

sp_rename NOM_GeneFamily, NOM_GeneFamily_Old
go

sp_rename NOM_Marker, NOM_Marker_Old
go

sp_rename NOM_Synonym, NOM_Synonym_Old
go

sp_rename PRB_Alias, PRB_Alias_Old
go

sp_rename PRB_Allele, PRB_Allele_Old
go

sp_rename PRB_Allele_Strain, PRB_Allele_Strain_Old
go

sp_rename PRB_Probe, PRB_Probe_Old
go

sp_rename PRB_Reference, PRB_Reference_Old
go

sp_rename PRB_RFLV, PRB_RFLV_Old
go

sp_rename VOC_Evidence, VOC_Evidence_Old
go

sp_rename VOC_Term, VOC_Term_Old
go

end

EOSQL

#
# create new tables
#
${newmgddbschema}/table/ACC_ActualDB_create.object >> $LOG
${newmgddbschema}/default/ACC_ActualDB_bind.object >> $LOG
${newmgddbschema}/table/ACC_LogicalDB_create.object >> $LOG
${newmgddbschema}/default/ACC_LogicalDB_bind.object >> $LOG
${newmgddbschema}/table/ACC_MGIType_create.object >> $LOG
${newmgddbschema}/default/ACC_MGIType_bind.object >> $LOG
${newmgddbschema}/table/ALL_Allele_create.object >> $LOG
${newmgddbschema}/default/ALL_Allele_bind.object >> $LOG

${newmgddbschema}/table/GXD_AlleleGenotype_create.object >> $LOG
${newmgddbschema}/default/GXD_AlleleGenotype_bind.object >> $LOG
${newmgddbschema}/table/GXD_Assay_create.object >> $LOG
${newmgddbschema}/default/GXD_Assay_bind.object >> $LOG
${newmgddbschema}/table/GXD_Genotype_create.object >> $LOG
${newmgddbschema}/default/GXD_Genotype_bind.object >> $LOG
${newmgddbschema}/table/GXD_Index_create.object >> $LOG
${newmgddbschema}/default/GXD_Index_bind.object >> $LOG
${newmgddbschema}/table/GXD_Index_Stages_create.object >> $LOG
${newmgddbschema}/default/GXD_Index_Stages_bind.object >> $LOG

${newmgddbschema}/table/MGI_Note_create.object >> $LOG
${newmgddbschema}/default/MGI_Note_bind.object >> $LOG
${newmgddbschema}/table/MGI_NoteChunk_create.object >> $LOG
${newmgddbschema}/default/MGI_NoteChunk_bind.object >> $LOG
${newmgddbschema}/table/MGI_NoteType_create.object >> $LOG
${newmgddbschema}/default/MGI_NoteType_bind.object >> $LOG
${newmgddbschema}/table/MGI_RefAssocType_create.object >> $LOG
${newmgddbschema}/default/MGI_RefAssocType_bind.object >> $LOG
${newmgddbschema}/table/MGI_Reference_Assoc_create.object >> $LOG
${newmgddbschema}/default/MGI_Reference_Assoc_bind.object >> $LOG
${newmgddbschema}/table/MGI_Set_create.object >> $LOG
${newmgddbschema}/default/MGI_Set_bind.object >> $LOG
${newmgddbschema}/table/MGI_SetMember_create.object >> $LOG
${newmgddbschema}/default/MGI_SetMember_bind.object >> $LOG
${newmgddbschema}/table/MGI_Translation_create.object >> $LOG
${newmgddbschema}/default/MGI_Translation_bind.object >> $LOG
${newmgddbschema}/table/MGI_TranslationType_create.object >> $LOG
${newmgddbschema}/default/MGI_TranslationType_bind.object >> $LOG

${newmgddbschema}/table/MLD_Marker_create.object >> $LOG
${newmgddbschema}/default/MLD_Marker_bind.object >> $LOG
${newmgddbschema}/table/MRK_Chromosome_create.object >> $LOG
${newmgddbschema}/default/MRK_Chromosome_bind.object >> $LOG
${newmgddbschema}/table/MRK_History_create.object >> $LOG
${newmgddbschema}/default/MRK_History_bind.object >> $LOG

${newmgddbschema}/table/NOM_GeneFamily_create.object >> $LOG
${newmgddbschema}/default/NOM_GeneFamily_bind.object >> $LOG
${newmgddbschema}/table/NOM_Marker_create.object >> $LOG
${newmgddbschema}/default/NOM_Marker_bind.object >> $LOG
${newmgddbschema}/table/NOM_Synonym_create.object >> $LOG
${newmgddbschema}/default/NOM_Synonym_bind.object >> $LOG

${newmgddbschema}/table/PRB_Probe_create.object >> $LOG
${newmgddbschema}/default/PRB_Probe_bind.object >> $LOG
${newmgddbschema}/table/PRB_Alias_create.object >> $LOG
${newmgddbschema}/default/PRB_Alias_bind.object >> $LOG
${newmgddbschema}/table/PRB_Allele_create.object >> $LOG
${newmgddbschema}/default/PRB_Allele_bind.object >> $LOG
${newmgddbschema}/table/PRB_Allele_Strain_create.object >> $LOG
${newmgddbschema}/default/PRB_Allele_Strain_bind.object >> $LOG
${newmgddbschema}/table/PRB_Reference_create.object >> $LOG
${newmgddbschema}/default/PRB_Reference_bind.object >> $LOG
${newmgddbschema}/table/PRB_RFLV_create.object >> $LOG
${newmgddbschema}/default/PRB_RFLV_bind.object >> $LOG

${newmgddbschema}/table/VOC_Evidence_create.object >> $LOG
${newmgddbschema}/default/VOC_Evidence_bind.object >> $LOG
${newmgddbschema}/table/VOC_Term_create.object >> $LOG
${newmgddbschema}/default/VOC_Term_bind.object >> $LOG

${newmgddbschema}/default/userID_default_create.object >> $LOG

cat - <<EOSQL | doisql.csh $0 >> $LOG

use $DBNAME
go

insert into ACC_ActualDB
select o._ActualDB_key, o._LogicalDB_Key, o.name, o.active, o.url, o.allowsMultiple, o.delimiter, 
${CREATEDBY}, ${CREATEDBY}, o.creation_date, o.modification_date
from ACC_ActualDB_Old o
go

dump tran ${DBNAME} with truncate_only
go

insert into ACC_LogicalDB
select o._LogicalDB_Key, o.name, o.description, o._Species_key,
${CREATEDBY}, ${CREATEDBY}, o.creation_date, o.modification_date
from ACC_LogicalDB_Old o
go

dump tran ${DBNAME} with truncate_only
go

insert into ACC_MGIType
select o._MGIType_key, o.name, o.tableName, o.primaryKeyName, o.identityColumnName, o.dbView,
${CREATEDBY}, ${CREATEDBY}, o.creation_date, o.modification_date
from ACC_MGIType_Old o
go

dump tran ${DBNAME} with truncate_only
go

insert into ALL_Allele
select o._Allele_key, o._Marker_key, o._Strain_key, o._Mode_key,
o._Allele_Type_key, o._CellLine_key, o._Allele_Status_key,
o.symbol, o.name, o.nomenSymbol,
u1._User_key, u2._User_key, u3._User_key, 
o.approval_date, o.creation_date, o.modification_date
from ALL_Allele_Old o, MGI_User u1, MGI_User u2, MGI_User u3
where o.createdBy = u1.login
and o.modifiedBy = u2.login
and o.approvedBy *= u3.login
go

dump tran ${DBNAME} with truncate_only
go

insert into GXD_AlleleGenotype
select o._Genotype_key, o._Marker_key, o._Allele_key,
u1._User_key, u2._User_key, o.creation_date, o.modification_date
from GXD_AlleleGenotype_Old o, MGI_User u1, MGI_User u2
where o.createdBy = u1.login
and o.modifiedBy = u2.login
go

dump tran ${DBNAME} with truncate_only
go

insert into GXD_Assay
select o._Assay_key, o._AssayType_key, o._Refs_key, o._Marker_key,
o._ProbePrep_key, o._AntibodyPrep_key, o._ImagePane_key, o._ReporterGene_key,
u1._User_key, u2._User_key, o.creation_date, o.modification_date
from GXD_Assay_Old o, MGI_User u1, MGI_User u2
where o.createdBy = u1.login
and o.modifiedBy = u2.login
go

dump tran ${DBNAME} with truncate_only
go

insert into GXD_Genotype
select o._Genotype_key, o._Strain_key, o.isConditional, o.note,
u1._User_key, u2._User_key, o.creation_date, o.modification_date
from GXD_Genotype_Old o, MGI_User u1, MGI_User u2
where o.createdBy = u1.login
and o.modifiedBy = u2.login
go

dump tran ${DBNAME} with truncate_only
go

insert into GXD_Index
select o._Index_key, o._Refs_key, o._Marker_key, o._Priority_key, o.comments,
u1._User_key, u2._User_key, o.creation_date, o.modification_date
from GXD_Index_Old o, MGI_User u1, MGI_User u2
where o.createdBy = u1.login
and o.modifiedBy = u2.login
go

dump tran ${DBNAME} with truncate_only
go

insert into GXD_Index_Stages
select o._Index_key, o._IndexAssay_key, o._StageID_key,
u1._User_key, u2._User_key, o.creation_date, o.modification_date
from GXD_Index_Stages_Old o, MGI_User u1, MGI_User u2
where o.createdBy = u1.login
and o.modifiedBy = u2.login
go

dump tran ${DBNAME} with truncate_only
go

insert into MGI_Note
select o._Note_key, o._Object_key, o._MGIType_key, o._NoteType_key,
u1._User_key, u2._User_key, o.creation_date, o.modification_date
from MGI_Note_Old o, MGI_User u1, MGI_User u2
where o.createdBy = u1.login
and o.modifiedBy = u2.login
go

dump tran ${DBNAME} with truncate_only
go

insert into MGI_NoteChunk
select o._Note_key, o.sequenceNum, o.note,
u1._User_key, u2._User_key, o.creation_date, o.modification_date
from MGI_NoteChunk_Old o, MGI_User u1, MGI_User u2
where o.createdBy = u1.login
and o.modifiedBy = u2.login
go

dump tran ${DBNAME} with truncate_only
go

insert into MGI_NoteType
select o._NoteType_key, o._MGIType_key, o.noteType, o.private,
u1._User_key, u2._User_key, o.creation_date, o.modification_date
from MGI_NoteType_Old o, MGI_User u1, MGI_User u2
where o.createdBy = u1.login
and o.modifiedBy = u2.login
go

dump tran ${DBNAME} with truncate_only
go

insert into MGI_Reference_Assoc
select o._Assoc_key, o._Refs_key, o._Object_key, o._MGIType_key, o._RefAssocType_key,
u1._User_key, u2._User_key, o.creation_date, o.modification_date
from MGI_Reference_Assoc_Old o, MGI_User u1, MGI_User u2
where o.createdBy = u1.login
and o.modifiedBy = u2.login
go

dump tran ${DBNAME} with truncate_only
go

insert into MGI_RefAssocType
select o._RefAssocType_key, o._MGIType_key, o.assocType, o.allowOnlyOne,
u1._User_key, u2._User_key, o.creation_date, o.modification_date
from MGI_RefAssocType_Old o, MGI_User u1, MGI_User u2
where o.createdBy = u1.login
and o.modifiedBy = u2.login
go

dump tran ${DBNAME} with truncate_only
go

insert into MGI_Set
select o._Set_key, o._MGIType_key, o.name,
u1._User_key, u2._User_key, o.creation_date, o.modification_date
from MGI_Set_Old o, MGI_User u1, MGI_User u2
where o.createdBy = u1.login
and o.modifiedBy = u2.login
go

dump tran ${DBNAME} with truncate_only
go

insert into MGI_SetMember
select o._SetMember_key, o._Set_key, o._Object_key, o.sequenceNum,
u1._User_key, u2._User_key, o.creation_date, o.modification_date
from MGI_SetMember_Old o, MGI_User u1, MGI_User u2
where o.createdBy = u1.login
and o.modifiedBy = u2.login
go

dump tran ${DBNAME} with truncate_only
go

insert into MGI_Translation
select o._Translation_key, o._TranslationType_key, o._Object_key, o.badName, o.sequenceNum, 
u1._User_key, u2._User_key, o.creation_date, o.modification_date
from MGI_Translation_Old o, MGI_User u1, MGI_User u2
where o.createdBy = u1.login
and o.modifiedBy = u2.login
go

dump tran ${DBNAME} with truncate_only
go

insert into MGI_TranslationType
select o._TranslationType_key, o._MGIType_key, null, o.translationType,
o.compressionChars, o.regularExpression,
u1._User_key, u2._User_key, o.creation_date, o.modification_date
from MGI_TranslationType_Old o, MGI_User u1, MGI_User u2
where o.createdBy = u1.login
and o.modifiedBy = u2.login
go

dump tran ${DBNAME} with truncate_only
go

select *, seq = identity(10)
into #oldmld
from MLD_Marker_Old
go

insert into MLD_Marker
select o.seq + 1000, o._Refs_key, o._Marker_key, o.sequenceNum,
${CREATEDBY}, ${CREATEDBY}, o.creation_date, o.modification_date
from #oldmld o
go

dump tran ${DBNAME} with truncate_only
go

select *, seq = identity(10)
into #oldchromosome
from MRK_Chromosome_Old
go

insert into MRK_Chromosome
select o.seq + 1000, o._Species_key, o.chromosome, o.sequenceNum,
${CREATEDBY}, ${CREATEDBY}, o.creation_date, o.modification_date
from #oldchromosome o
go

dump tran ${DBNAME} with truncate_only
go

insert into MRK_History
select o._Marker_key, o._Marker_Event_key, o._Marker_EventReason_key, 
o._History_key, o._Refs_key, o.sequenceNum, o.name, o.event_date,
u1._User_key, u2._User_key, o.creation_date, o.modification_date
from MRK_History_Old o, MGI_User u1, MGI_User u2
where o.createdBy = u1.login
and o.modifiedBy = u2.login
go

dump tran ${DBNAME} with truncate_only
go

insert into NOM_GeneFamily
select o._Nomen_key, o._GeneFamily_key,
u1._User_key, u2._User_key, o.creation_date, o.modification_date
from NOM_GeneFamily_Old o, MGI_User u1, MGI_User u2
where o.createdBy = u1.login
and o.modifiedBy = u2.login
go

dump tran ${DBNAME} with truncate_only
go

insert into NOM_Marker
select o._Nomen_key, o._Marker_Type_key, o._NomenStatus_key, o._Marker_Event_key, o._Marker_EventReason_key, o._CurationState_key,
o.symbol, o.name, o.chromosome, o.humanSymbol, o.statusNote, 
o.broadcast_date, u3._User_key,
u1._User_key, u2._User_key, o.creation_date, o.modification_date
from NOM_Marker_Old o, MGI_User u1, MGI_User u2, MGI_User u3
where o.broadcastBy = u3.login
and o.createdBy = u1.login
and o.modifiedBy = u2.login
go

insert into NOM_Marker
select o._Nomen_key, o._Marker_Type_key, o._NomenStatus_key, o._Marker_Event_key, o._Marker_EventReason_key, o._CurationState_key,
o.symbol, o.name, o.chromosome, o.humanSymbol, o.statusNote, 
o.broadcast_date, NULL,
u1._User_key, u2._User_key, o.creation_date, o.modification_date
from NOM_Marker_Old o, MGI_User u1, MGI_User u2
where o.broadcastBy is null
and o.createdBy = u1.login
and o.modifiedBy = u2.login
go

dump tran ${DBNAME} with truncate_only
go

insert into NOM_Synonym
select o._Synonym_key, o._Nomen_key, o._Refs_key, o.name, o.isAuthor,
u1._User_key, u2._User_key, o.creation_date, o.modification_date
from NOM_Synonym_Old o, MGI_User u1, MGI_User u2
where o.createdBy = u1.login
and o.modifiedBy = u2.login
go

dump tran ${DBNAME} with truncate_only
go

insert into PRB_Alias
select _Alias_key, _Reference_key, alias,
${CREATEDBY}, ${CREATEDBY}, creation_date, modification_date
from PRB_Alias_Old
go

dump tran ${DBNAME} with truncate_only
go

insert into PRB_Allele
select _Allele_key, _RFLV_key, allele, fragments,
${CREATEDBY}, ${CREATEDBY}, creation_date, modification_date
from PRB_Allele_Old
go

dump tran ${DBNAME} with truncate_only
go

insert into PRB_Allele_Strain
select _Allele_key, _Strain_key,
${CREATEDBY}, ${CREATEDBY}, creation_date, modification_date
from PRB_Allele_Strain_Old
go

dump tran ${DBNAME} with truncate_only
go

insert into PRB_Probe
select p._Probe_key, p.name, p.derivedFrom, p._Source_key, 
t1._Term_key,
t2._Term_key,
p.primer1sequence, p.primer2sequence, p.regionCovered, p.regionCovered2,
p.insertSite, p.insertSize, p.repeatUnit, p.productSize, p.moreProduct,
${CREATEDBY}, ${CREATEDBY}, p.creation_date, p.modification_date
from PRB_Probe_Old p, PRB_Vector_Types vt, 
VOC_Term_Old t1, VOC_Vocab v1, VOC_Term_Old t2, VOC_Vocab v2
where p._Vector_key = vt._Vector_key
and vt.vectorType = t1.term
and t1._Vocab_key = v1._Vocab_key
and v1.name = "Segment Vector Type"
and p.DNAtype = t2.term
and t2._Vocab_key = v2._Vocab_key
and v2.name = "Segment Type"
go

dump tran ${DBNAME} with truncate_only
go

insert into PRB_Reference
select _Reference_key, _Probe_key, _Refs_key, holder, hasRmap, hasSequence, 
${CREATEDBY}, ${CREATEDBY}, creation_date, modification_date
from PRB_Reference_Old
go

dump tran ${DBNAME} with truncate_only
go

insert into PRB_RFLV
select _RFLV_Key, _Reference_key, _Marker_key, endonuclease,
${CREATEDBY}, ${CREATEDBY}, creation_date, modification_date
from PRB_RFLV_Old
go

dump tran ${DBNAME} with truncate_only
go

insert into VOC_Evidence
select o._AnnotEvidence_key, o._Annot_key, o._EvidenceTerm_key, o._Refs_key, o.inferredFrom,
u1._User_key, u2._User_key, o.creation_date, o.modification_date
from VOC_Evidence_Old o, MGI_User u1, MGI_User u2
where o.createdBy = u1.login
and o.modifiedBy = u2.login
go

dump tran ${DBNAME} with truncate_only
go

insert into VOC_Term
select _Term_key, _Vocab_key, term, abbreviation, sequenceNum, isObsolete,
${CREATEDBY}, ${CREATEDBY}, creation_date, modification_date
from VOC_Term_Old
go

dump tran ${DBNAME} with truncate_only
go

exec sp_bindefault userID_default, "MLC_Text.userID"
go

checkpoint
go

quit

EOSQL

${newmgddbschema}/index/ACC_ActualDB_create.object >> $LOG
${newmgddbschema}/index/ACC_LogicalDB_create.object >> $LOG
${newmgddbschema}/index/ACC_MGIType_create.object >> $LOG
${newmgddbschema}/index/ALL_Allele_create.object >> $LOG

${newmgddbschema}/index/GXD_AlleleGenotype_create.object >> $LOG
${newmgddbschema}/index/GXD_Assay_create.object >> $LOG
${newmgddbschema}/index/GXD_Genotype_create.object >> $LOG
${newmgddbschema}/index/GXD_Index_create.object >> $LOG
${newmgddbschema}/index/GXD_Index_Stages_create.object >> $LOG

${newmgddbschema}/index/MGI_Note_create.object >> $LOG
${newmgddbschema}/index/MGI_NoteChunk_create.object >> $LOG
${newmgddbschema}/index/MGI_NoteType_create.object >> $LOG
${newmgddbschema}/index/MGI_Set_create.object >> $LOG
${newmgddbschema}/index/MGI_SetMember_create.object >> $LOG
${newmgddbschema}/index/MLD_Marker_create.object >> $LOG

${newmgddbschema}/index/PRB_Alias_create.object >> $LOG
${newmgddbschema}/index/PRB_Allele_create.object >> $LOG
${newmgddbschema}/index/PRB_Allele_Strain_create.object >> $LOG
${newmgddbschema}/partition/PRB_Probe_create.object >> $LOG
${newmgddbschema}/index/PRB_Probe_create.object >> $LOG
${newmgddbschema}/index/PRB_Reference_create.object >> $LOG
${newmgddbschema}/index/PRB_RFLV_create.object >> $LOG

${newmgddbschema}/index/MRK_History_create.object >> $LOG

${newmgddbschema}/index/VOC_Evidence_create.object >> $LOG
${newmgddbschema}/index/VOC_Term_create.object >> $LOG

cat - <<EOSQL | doisql.csh $0 >> $LOG

use $DBNAME
go

drop table ACC_ActualDB_Old
go

drop table ACC_LogicalDB_Old
go

drop table ACC_MGIType_Old
go

drop table ALL_Allele_Old
go

drop table GXD_AlleleGenotype_Old
go

drop table GXD_Assay_Old
go

drop table GXD_Genotype_Old
go

drop table GXD_Index_Old
go

drop table GXD_Index_Stages_Old
go

drop table MGI_Note_Old
go

drop table MGI_NoteChunk_Old
go

drop table MGI_NoteType_Old
go

drop table MGI_RefAssocType_Old
go

drop table MGI_Reference_Assoc_Old
go

drop table MGI_Set_Old
go

drop table MGI_SetMember_Old
go

drop table MGI_Translation_Old
go

drop table MGI_TranslationType_Old
go

drop table MLD_Marker_Old
go

drop table MRK_Chromosome_Old
go

drop table MRK_History_Old
go

drop table NOM_GeneFamily_Old
go

drop table NOM_Marker_Old
go

drop table NOM_Synonym_Old
go

drop table PRB_Alias_Old
go

drop table PRB_Allele_Old
go

drop table PRB_Allele_Strain_Old
go

drop table PRB_Probe_Old
go

drop table PRB_Reference_Old
go

drop table PRB_RFLV_Old
go

drop table VOC_Evidence_Old
go

drop table VOC_Term_Old
go

end

EOSQL

date >> $LOG

