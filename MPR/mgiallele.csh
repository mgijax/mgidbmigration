#!/bin/csh -f

#
# Migration for:
#   ALL_Note to MGI_Note, MGI_NoteType
#   ALL_Reference to MGI_Reference_Assoc, MGI_RefAssocType
#

cd `dirname $0` && source ./Configuration

setenv LOG $0.log
rm -rf $LOG
touch $LOG
 
date >> $LOG
echo "Notes Migration..." | tee -a $LOG
 
cat - <<EOSQL | doisql.csh $0 >> $LOG

use $DBNAME
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

/* References */

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

checkpoint
go

quit

EOSQL

date >> $LOG

