#!/bin/csh -f

#
# Migration for NomenDB
#

cd `dirname $0` && source ./Configuration

setenv LOG $0.log
rm -rf $LOG
touch $LOG
 
date >> $LOG
echo "Nomen Migration..." | tee -a $LOG
 
#
# Use new schema product to create new table
#
${newmgddbschema}/table/NOM_create.logical >>& $LOG
${newmgddbschema}/default/NOM_bind.logical >>& $LOG

# remove indexes; this will make inserts faster
${newmgddbschema}/index/MGI_Note_drop.object >>& $LOG
${newmgddbschema}/index/MGI_NoteChunk_drop.object >>& $LOG

cat - <<EOSQL | doisql.csh $0 >> $LOG

use $DBNAME
go

insert into ACC_MGIType 
values (21, 'Nomenclature', 'NOM_Marker', '_Nomen_key', 'symbol', null, getdate(), getdate(), getdate())
go

insert into MGI_NoteType values(1003, 21, 'General', 0, '${CREATEDBY}', '${CREATEDBY}', getdate(), getdate())
go

insert into MGI_NoteType values(1004, 21, 'Editor', 1, '${CREATEDBY}', '${CREATEDBY}', getdate(), getdate())
go

insert into MGI_NoteType values(1005, 21, 'Coordinator', 1, '${CREATEDBY}', '${CREATEDBY}', getdate(), getdate())
go

declare @curationKey integer
select @curationKey = t._Term_key from VOC_Term t, VOC_Vocab v
where t.term = 'Internal'
and t._Vocab_key = v._Vocab_key
and v.name = "Curation State"

insert into NOM_Marker
select n._Nomen_key, n._Marker_Type_key, t._Term_key, n._Marker_Event_key, n._Marker_EventReason_key,
@curationKey, n.symbol, n.name, n.chromosome, n.humanSymbol, n.statusNote, 
n.broadcast_date, null, n.submittedBy, n.submittedBy,
n.creation_date, n.modification_date
from ${NOMEN}..MRK_Nomen n, ${NOMEN}..MRK_Status s, VOC_Term t, VOC_Vocab v
where n._Marker_Status_key = s._Marker_Status_key
and s.status = t.term
and t._Vocab_key = v._Vocab_key
and v.name = "Nomen Status"
and n.broadcastBy is null

insert into NOM_Marker
select n._Nomen_key, n._Marker_Type_key, t._Term_key, n._Marker_Event_key, n._Marker_EventReason_key,
@curationKey, n.symbol, n.name, n.chromosome, n.humanSymbol, n.statusNote, 
n.broadcast_date, n.broadcastBy, n.submittedBy, n.submittedBy,
n.creation_date, n.modification_date
from ${NOMEN}..MRK_Nomen n, ${NOMEN}..MRK_Status s, VOC_Term t, VOC_Vocab v
where n._Marker_Status_key = s._Marker_Status_key
and s.status = t.term
and t._Vocab_key = v._Vocab_key
and v.name = "Nomen Status"
and n.broadcastBy is not null
go

dump tran $DBNAME with truncate_only
go

/* Gene Family */

insert into NOM_GeneFamily
select n._Nomen_key, t._Term_key, '${CREATEDBY}', '${CREATEDBY}', n.creation_date, n.modification_date
from ${NOMEN}..MRK_Nomen_GeneFamily n, ${NOMEN}..MRK_GeneFamily g, VOC_Term t, VOC_Vocab v
where n._Marker_Family_key = g._Marker_Family_key
and g.name = t.term
and t._Vocab_key = v._Vocab_key
and v.name = "Nomen Gene Family"
go

dump tran $DBNAME with truncate_only
go

/* Synonyms */

insert into NOM_Synonym
select _Other_key, _Nomen_key, _Refs_key, name, isAuthor, '${CREATEDBY}', '${CREATEDBY}', creation_date, modification_date
from ${NOMEN}..MRK_Nomen_Other
go

dump tran $DBNAME with truncate_only
go

/* Notes */

select distinct _Nomen_key, type = 1004, seq = identity(5)
into #notes 
from ${NOMEN}..MRK_Nomen_Notes where noteType = 'E'
union
select distinct _Nomen_key, type = 1005, seq = identity(5)
from ${NOMEN}..MRK_Nomen_Notes where noteType = 'C'
go

declare @maxKey integer
select @maxKey = max(_Note_key) from MGI_Note
if @maxKey is null
        select @maxKey = 1000

insert into MGI_Note 
select seq + @maxKey, _Nomen_key, 21, type, '${CREATEDBY}', '${CREATEDBY}', getdate(), getdate()
from #notes

insert into MGI_NoteChunk
select seq + @maxKey, n.sequenceNum, n.note, '${CREATEDBY}', '${CREATEDBY}', n.creation_date, n.modification_date
from #notes s, ${NOMEN}..MRK_Nomen_Notes n
where s._Nomen_key = n._Nomen_key
and s.type = 1004
and n.noteType = 'E'

insert into MGI_NoteChunk
select seq + @maxKey, n.sequenceNum, n.note, '${CREATEDBY}', '${CREATEDBY}', n.creation_date, n.modification_date
from #notes s, ${NOMEN}..MRK_Nomen_Notes n
where s._Nomen_key = n._Nomen_key
and s.type = 1005
and n.noteType = 'C'

go

dump tran $DBNAME with truncate_only
go

/* References */

select _Nomen_key, _Refs_key, type = 1003, seq = identity(5)
into #refs
from ${NOMEN}..MRK_Nomen_Reference
where isPrimary = 1
union
select _Nomen_key, _Refs_key, type = 1004, seq = identity(5)
from ${NOMEN}..MRK_Nomen_Reference
where isPrimary = 0 and broadcastToMGD = 1
union
select _Nomen_key, _Refs_key, type = 1005, seq = identity(5)
from ${NOMEN}..MRK_Nomen_Reference
where isPrimary = 0 and broadcastToMGD = 0
go

declare @maxKey integer
select @maxKey = max(_Assoc_key) from MGI_Reference_Assoc
if @maxKey is null
        select @maxKey = 1000

insert into MGI_Reference_Assoc
select seq + @maxKey, _Refs_key, _Nomen_key, 21, type, '${CREATEDBY}', '${CREATEDBY}', getdate(), getdate()
from #refs
go

dump tran $DBNAME with truncate_only
go

/* Accession IDs */

select *, seq = identity(5)
into #accs
from ${NOMEN}..ACC_Accession
where _LogicalDB_key = 1
go

declare @maxKey integer
select @maxKey = max(_Accession_key) from ACC_Accession

insert into ACC_Accession
select seq + @maxKey, accID, prefixPart, numericPart, _LogicalDB_key, _Object_key, 
21, preferred, 1, creation_date, modification_date, release_date
from #accs
go

drop table #accs
go

dump tran $DBNAME with truncate_only
go

select *, seq = identity(5)
into #accs
from ${NOMEN}..ACC_Accession
where _LogicalDB_key != 1
go

select r.*, seq = identity(5)
into #accrefs
from ${NOMEN}..ACC_Accession a, ${NOMEN}..ACC_AccessionReference r
where a._LogicalDB_key != 1
and a._Accession_key = r._Accession_key
go

declare @maxKey integer
select @maxKey = max(_Accession_key) from ACC_Accession

insert into ACC_Accession
select seq + @maxKey, accID, prefixPart, numericPart, _LogicalDB_key, _Object_key, 
21, preferred, private, creation_date, modification_date, release_date
from #accs

insert into ACC_AccessionReference
select seq + @maxKey, _Refs_key, creation_date, modification_date, release_date
from #accrefs
go

dump tran $DBNAME with truncate_only
go

checkpoint
go

quit

EOSQL

${newmgddbschema}/index/NOM_create.logical >>& $LOG
${newmgddbschema}/index/MGI_Note_create.object | tee -a $LOG
${newmgddbschema}/index/MGI_NoteChunk_create.object | tee -a $LOG
${newmgddbschema}/index/MGI_Reference_Assoc_create.object | tee -a $LOG


date >> $LOG

