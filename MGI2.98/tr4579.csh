#!/bin/csh -f

#
# Migration for TR 4579
#

cd `dirname $0` && source ./Configuration

setenv LOG $0.log
rm -rf $LOG
touch $LOG
 
date | tee -a $LOG
 
cat - <<EOSQL | doisql.csh $0 | tee -a $LOG

use $DBNAME
go

sp_rename VOC_Evidence, VOC_Evidence_Old
go

end

EOSQL

#
# Use new schema product to create new table
#
${newmgddbschema}/table/VOC_Evidence_create.object | tee -a $LOG
${newmgddbschema}/default/VOC_Evidence_bind.object | tee -a $LOG
${newmgddbschema}/index/MGI_Note_drop.object | tee -a $LOG
${newmgddbschema}/index/MGI_NoteChunk_drop.object | tee -a $LOG

cat - <<EOSQL | doisql.csh $0 | tee -a $LOG

use $DBNAME
go

insert into ACC_MGIType 
values (25, 'Annotation Evidence', 'VOC_Evidence', '_AnnotEvidence_key', null, null, getdate(), getdate(), getdate())
go

insert into MGI_NoteType values(1008, 25, 'General', 1, '${CREATEDBY}', '${CREATEDBY}', getdate(), getdate())
go

select *, seq = identity(10)
into #oldevidence
from VOC_Evidence_Old
go

insert into VOC_Evidence
select o.seq + 1000, o._Annot_key, o._EvidenceTerm_key, o._Refs_key, o.inferredFrom,
o.createdBy, o.modifiedBy, o.creation_date, o.modification_date
from #oldevidence o
go

declare @maxKey integer
select @maxKey = max(_Note_key) from MGI_Note
if @maxKey is null
        select @maxKey = 1000

insert into MGI_Note 
select seq + @maxKey, e._AnnotEvidence_key, 25, 1008, '${CREATEDBY}', '${CREATEDBY}', getdate(), getdate()
from #oldevidence o, VOC_Evidence e
where o.notes is not null
and o._Annot_key = e._Annot_key
and o._EvidenceTerm_key = e._EvidenceTerm_key
and o._Refs_key = e._Refs_key

insert into MGI_NoteChunk
select seq + @maxKey, 1, notes, '${CREATEDBY}', '${CREATEDBY}', creation_date, modification_date
from #oldevidence
where notes is not null

go

checkpoint
go

quit

EOSQL

${newmgddbschema}/index/VOC_Evidence_create.object | tee -a $LOG
${newmgddbschema}/index/MGI_Note_create.object | tee -a $LOG
${newmgddbschema}/index/MGI_NoteChunk_create.object | tee -a $LOG

date | tee -a $LOG

