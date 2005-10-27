#!/bin/csh -f

#
# Migration for GXD_Genotype.note
#

cd `dirname $0` && source ./Configuration

setenv LOG $0.log
rm -rf ${LOG}
touch ${LOG}
 
date | tee -a ${LOG}

cat - <<EOSQL | doisql.csh $0 | tee -a ${LOG}

use ${DBNAME}
go

/* general note type and curator note type */

declare @noteTypeKey integer
select @noteTypeKey = max(_NoteType_key) + 1 from MGI_NoteType

insert into MGI_NoteType values(@noteTypeKey, 12, 'General', 0, ${CREATEDBY}, ${CREATEDBY}, getdate(), getdate())
insert into MGI_NoteType values(@noteTypeKey + 1, 12, 'Private Curatorial', 1, ${CREATEDBY}, ${CREATEDBY}, getdate(), getdate())

select g._Genotype_key, g.note, noteTypeKey = @noteTypeKey, seq = identity(5)
into #notes 
from GXD_Genotype g
where g.note is not null
go

declare @maxKey integer
select @maxKey = max(_Note_key) from MGI_Note

insert into MGI_Note 
select seq + @maxKey, _Genotype_key, 12, noteTypeKey, ${CREATEDBY}, ${CREATEDBY}, getdate(), getdate()
from #notes

insert into MGI_NoteChunk
select seq + @maxKey, 1, n.note, ${CREATEDBY}, ${CREATEDBY}, getdate(), getdate()
from #notes n
go

/* nullify all of these notes...migrating to MGI_Note/MGI_NoteChunk */
/* this field is obsolete and should be removed in the next release */

update GXD_Genotype set note = null where note is not null
go

quit

EOSQL

date | tee -a $LOG

