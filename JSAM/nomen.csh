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
 
# for testing, drop the tables first
#${newmgddbschema}/table/NOM_drop.logical

#
# Use new schema product to create new table
#
${newmgddbschema}/table/NOM_create.logical >>& $LOG
${newmgddbschema}/default/NOM_bind.logical >>& $LOG

# remove indexes; this will make inserts faster
${oldmgddbschema}/index/ACC_Accession_drop.object >>& $LOG
${newmgddbschema}/index/MGI_Note_drop.object >>& $LOG
${newmgddbschema}/index/MGI_NoteChunk_drop.object >>& $LOG

# ACC_AccessionReference trigger references MRK_Marker._Organism_key
${newmgddbschema}/trigger/ACC_AccessionReference_drop.object >>& $LOG
${newmgddbschema}/trigger/ACC_AccessionReference_create.object >>& $LOG

cat - <<EOSQL | doisql.csh $0 >> $LOG

use $DBNAME
go

declare @curationKey integer
select @curationKey = t._Term_key from VOC_Term t, VOC_Vocab v
where t.term = 'Internal'
and t._Vocab_key = v._Vocab_key
and v.name = "Curation State"

insert into NOM_Marker
select n._Nomen_key, n._Marker_Type_key, t._Term_key, n._Marker_Event_key, n._Marker_EventReason_key,
@curationKey, n.symbol, n.name, n.chromosome, n.humanSymbol, n.statusNote, 
n.broadcast_date, null, u1._User_key, u1._User_key, 
n.creation_date, n.modification_date
from ${NOMEN}..MRK_Nomen n, ${NOMEN}..MRK_Status s, VOC_Term t, VOC_Vocab v, MGI_User u1
where n._Marker_Status_key = s._Marker_Status_key
and s.status = t.term
and t._Vocab_key = v._Vocab_key
and v.name = "Nomen Status"
and n.submittedBy = u1.login
and n.broadcastBy is null

insert into NOM_Marker
select n._Nomen_key, n._Marker_Type_key, t._Term_key, n._Marker_Event_key, n._Marker_EventReason_key,
@curationKey, n.symbol, n.name, n.chromosome, n.humanSymbol, n.statusNote, 
n.broadcast_date, u2._User_key, u1._User_key, u1._User_key, 
n.creation_date, n.modification_date
from ${NOMEN}..MRK_Nomen n, ${NOMEN}..MRK_Status s, VOC_Term t, VOC_Vocab v, MGI_User u1, MGI_User u2
where n._Marker_Status_key = s._Marker_Status_key
and s.status = t.term
and t._Vocab_key = v._Vocab_key
and v.name = "Nomen Status"
and n.submittedBy = u1.login
and n.broadcastBy = u2.login
go

dump tran $DBNAME with truncate_only
go

/* Synonyms */

insert into NOM_Synonym
select _Other_key, _Nomen_key, _Refs_key, name, isAuthor, ${CREATEDBY}, ${CREATEDBY}, creation_date, modification_date
from ${NOMEN}..MRK_Nomen_Other
go

dump tran $DBNAME with truncate_only
go

/* Notes */

select distinct _Nomen_key, type = 2, seq = identity(5)
into #notes 
from ${NOMEN}..MRK_Nomen_Notes where noteType = 'E'
union
select distinct _Nomen_key, type = 3, seq = identity(5)
from ${NOMEN}..MRK_Nomen_Notes where noteType = 'C'
go

declare @maxKey integer
select @maxKey = max(_Note_key) from MGI_Note
if @maxKey is null
        select @maxKey = 1000

insert into MGI_Note 
select seq + @maxKey, _Nomen_key, 21, type, ${CREATEDBY}, ${CREATEDBY}, getdate(), getdate()
from #notes

insert into MGI_NoteChunk
select seq + @maxKey, n.sequenceNum, n.note, ${CREATEDBY}, ${CREATEDBY}, n.creation_date, n.modification_date
from #notes s, ${NOMEN}..MRK_Nomen_Notes n
where s._Nomen_key = n._Nomen_key
and s.type = 2
and n.noteType = 'E'

insert into MGI_NoteChunk
select seq + @maxKey, n.sequenceNum, n.note, ${CREATEDBY}, ${CREATEDBY}, n.creation_date, n.modification_date
from #notes s, ${NOMEN}..MRK_Nomen_Notes n
where s._Nomen_key = n._Nomen_key
and s.type = 3
and n.noteType = 'C'

go

dump tran $DBNAME with truncate_only
go

/* References */

select _Nomen_key, _Refs_key, type = 3, seq = identity(5)
into #refs
from ${NOMEN}..MRK_Nomen_Reference
where isPrimary = 1
union
select _Nomen_key, _Refs_key, type = 4, seq = identity(5)
from ${NOMEN}..MRK_Nomen_Reference
where isPrimary = 0 and broadcastToMGD = 1
union
select _Nomen_key, _Refs_key, type = 5, seq = identity(5)
from ${NOMEN}..MRK_Nomen_Reference
where isPrimary = 0 and broadcastToMGD = 0
go

declare @maxKey integer
select @maxKey = max(_Assoc_key) from MGI_Reference_Assoc
if @maxKey is null
        select @maxKey = 1000

insert into MGI_Reference_Assoc
select seq + @maxKey, _Refs_key, _Nomen_key, 21, type, ${CREATEDBY}, ${CREATEDBY}, getdate(), getdate()
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
# re-create indexes on ACC_Accession
#${newmgddbschema}/index/ACC_Accession_create.object

date >> $LOG

