#!/bin/csh -f

#
# Migration for ALL controlled vocabs
#
# ALL_Inheritance_Mode
# ALL_Molecular_Mutation
# ALL_Status
# ALL_Type
#
# ALL_Note
# ALL_NoteType
# ALL_Reference
# ALL_ReferenceType
# ALL_Synonym
#

cd `dirname $0` && source ./Configuration

setenv LOG $0.log
rm -rf ${LOG}
touch ${LOG}
 
date | tee -a ${LOG}

echo "Allele Vocabulary Migration..." | tee -a ${LOG}
 
./loadVoc.csh | tee -a ${LOG}
./deleteNotes.py | tee -a ${LOG}

cat - <<EOSQL | doisql.csh $0 | tee -a ${LOG}

use ${DBNAME}
go

update ALL_Allele
set _Mode_key = t._Term_key
from ALL_Allele a, ALL_Inheritance_Mode o, VOC_Term t, VOC_Vocab v
where a._Mode_key = o._Mode_key
and o.status = t.term
and t._Vocab_key = v._Vocab_key
and v.name = "Allele Inheritance Mode"
go

dump tran ${DBNAME} with truncate_only
go

update ALL_Allele
set _Allele_Status_key = t._Term_key
from ALL_Allele a, ALL_Status o, VOC_Term t, VOC_Vocab v
where a._Allele_Status_key = o._Allele_Status_key
and o.status = t.term
and t._Vocab_key = v._Vocab_key
and v.name = "Allele Status"
go

dump tran ${DBNAME} with truncate_only
go

update ALL_Allele
set _Allele_Type_key = t._Term_key
from ALL_Allele a, ALL_Type o, VOC_Term t, VOC_Vocab v
where a._Allele_Type_key = o._Allele_Type_key
and o.alleleType = t.term
and t._Vocab_key = v._Vocab_key
and v.name = "Allele Type"
go

dump tran ${DBNAME} with truncate_only
go

update ALL_Allele_Mutation
set _Mutation_key = t._Term_key
from ALL_Allele_Mutation a, ALL_Molecular_Mutation o, VOC_Term t, VOC_Vocab v
where a._Mutation_key = o._Mutation_key
and o.mutation = t.term
and t._Vocab_key = v._Vocab_key
and v.name = "Allele Molecular Mutation"
go

dump tran ${DBNAME} with truncate_only
go

/* notes */

declare @noteTypeKey integer
select @noteTypeKey = max(_NoteType_key) from MGI_NoteType

insert into MGI_NoteType values(@noteTypeKey, 11, 'General', 0, '${CREATEDBY}', '${CREATEDBY}', getdate(), getdate())
insert into MGI_NoteType values(@noteTypeKey + 1, 11, 'Molecular', 0, '${CREATEDBY}', '${CREATEDBY}', getdate(), getdate())
insert into MGI_NoteType values(@noteTypeKey + 2, 11, 'Nomenclature', 1, '${CREATEDBY}', '${CREATEDBY}', getdate(), getdate())
go

select distinct n._Allele_key, noteTypeKey = n._NoteType_key, seq = identity(5)
into #notes 
from ALL_Note n, ALL_NoteType an, MGI_NoteType nt
where n._NoteType_key = an._NoteType_key
and an.noteType = nt.noteType
and nt._MGIType_key = 11
go

declare @maxKey integer
select @maxKey = max(_Note_key) from MGI_Note

insert into MGI_Note 
select seq + @maxKey, _Allele_key, 11, noteType, '${CREATEDBY}', '${CREATEDBY}', getdate(), getdate()
from #notes

insert into MGI_NoteChunk
select seq + @maxKey, n.sequenceNum, n.note, '${CREATEDBY}', '${CREATEDBY}', n.creation_date, n.modification_date
from #notes s, ALL_Note n
where s._Allele_key = n._Allele_key
go

dump tran $DBNAME with truncate_only
go

/* references */

declare @reftypeKey integer
select @reftypeKey = max(_RefAssocType_key) from MGI_RefAssocType

insert into MGI_RefAssocType values(@refTypeKey, 11, 'Original', 1, '${CREATEDBY}', '${CREATEDBY}', getdate(), getdate())
insert into MGI_RefAssocType values(@refTypeKey, 11, 'Molecular', 0, '${CREATEDBY}', '${CREATEDBY}', getdate(), getdate())
insert into MGI_RefAssocType values(@refTypeKey, 11, 'Indexed', 0, '${CREATEDBY}', '${CREATEDBY}', getdate(), getdate())
insert into MGI_RefAssocType values(@refTypeKey, 11, 'Not Used', 0, '${CREATEDBY}', '${CREATEDBY}', getdate(), getdate())
insert into MGI_RefAssocType values(@refTypeKey, 11, 'Used-PS', 0, '${CREATEDBY}', '${CREATEDBY}', getdate(), getdate())
insert into MGI_RefAssocType values(@refTypeKey, 11, 'Used-CUR', 0, '${CREATEDBY}', '${CREATEDBY}', getdate(), getdate())
insert into MGI_RefAssocType values(@refTypeKey, 11, 'Used-FC', 0, '${CREATEDBY}', '${CREATEDBY}', getdate(), getdate())
go

select distinct r._Allele_key, r._Refs_key, refTypeKey = r._RefsType_key, seq = identity(5)
into #refs
from ALL_Reference r, ALL_ReferenceType rn, MGI_RefAssocType rt
where r._RefsType_key = rn._RefsType_key
and rn.referenceType = rt.referenceType
and rt._MGIType_key = 11
go

declare @maxKey integer
select @maxKey = max(_Assoc_key) from MGI_Reference_Assoc

insert into MGI_Reference_Assoc
select seq + @maxKey, _Refs_key, _Allele_key, 11, refsTypeKey, '${CREATEDBY}', '${CREATEDBY}', getdate(), getdate()
from #refs
go

dump tran $DBNAME with truncate_only
go

/* synonyms */

declare @syntypeKey integer
select @syntypeKey = max(_SynonymType_key) from MGI_SynonymType

insert into MGI_SynonymType values(@synTypeKey, 11, 'General', null, 0, '${CREATEDBY}', '${CREATEDBY}', getdate(), getdate())

select s._Allele_key, s._Refs_key, s.synonym, @synTypeKey, seq = identity(5)
into #syns
from ALL_Synonym s
go

declare @maxKey integer
select @maxKey = max(_Synonym_key) from MGI_Synonym

insert into MGI_Synonym
select seq + @maxKey, _Allele_key, 11, synTypeKey, _Refs_key, synonym, '${CREATEDBY}', '${CREATEDBY}', getdate(), getdate()
from #syns
go

dump tran $DBNAME with truncate_only
go

checkpoint
go

quit

EOSQL

date | tee -a $LOG

