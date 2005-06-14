#!/bin/csh -f

#
# Migration for Images
#
# IMG_Image
# IMG_ImageNote
#

cd `dirname $0` && source ./Configuration

setenv LOG $0.log
rm -rf ${LOG}
touch ${LOG}
 
date | tee -a ${LOG}

echo "Image Migration..." | tee -a ${LOG}
 
cat - <<EOSQL | doisql.csh $0 | tee -a ${LOG}

use ${DBNAME}
go

sp_rename IMG_Image, IMG_Image_Old
go

quit

EOSQL

${newmgddbschema}/table/IMG_Image_create.object | tee -a ${LOG}
${newmgddbschema}/index/IMG_Image_create.object | tee -a ${LOG}
${newmgddbschema}/default/IMG_Image_bind.object | tee -a ${LOG}
${newmgddbschema}/view/MGI_Note_Image_View_create.object | tee -a ${LOG}
${newmgddbschema}/view/MGI_NoteType_Image_View_create.object | tee -a ${LOG}
${newmgddbperms}/public/view/MGI_Note_Image_View_grant.object | tee -a ${LOG}
${newmgddbperms}/public/view/MGI_NoteType_Image_View_grant.object | tee -a ${LOG}

cat - <<EOSQL | doisql.csh $0 | tee -a ${LOG}

use ${DBNAME}
go

/* images note type */

declare @noteTypeKey integer
select @noteTypeKey = max(_NoteType_key) + 1 from MGI_NoteType

insert into MGI_NoteType values(@noteTypeKey, 9, 'Copyright', 0, ${CREATEDBY}, ${CREATEDBY}, getdate(), getdate())
insert into MGI_NoteType values(@noteTypeKey + 1, 9, 'Caption', 0, ${CREATEDBY}, ${CREATEDBY}, getdate(), getdate())
insert into MGI_NoteType values(@noteTypeKey + 2, 9, 'Private Curatorial', 1, ${CREATEDBY}, ${CREATEDBY}, getdate(), getdate())
go

/* copyright */

select distinct _Image_key, seq = identity(5)
into #notes 
from IMG_Image_Old where copyrightNote is not null
go

declare @noteTypeKey integer
select @noteTypeKey = _NoteType_key from MGI_NoteType where _MGIType_key = 9 and noteType = 'Copyright'

declare @maxKey integer
select @maxKey = max(_Note_key) from MGI_Note

insert into MGI_Note 
select seq + @maxKey, _Image_key, 9, @noteTypeKey, ${CREATEDBY}, ${CREATEDBY}, getdate(), getdate()
from #notes

insert into MGI_NoteChunk
select seq + @maxKey, 1, n.copyrightNote, ${CREATEDBY}, ${CREATEDBY}, n.creation_date, n.modification_date
from #notes s, IMG_Image_Old n
where s._Image_key = n._Image_key
go

drop table #notes
go

/* caption */

select distinct _Image_key, seq = identity(5)
into #notes 
from IMG_ImageNote
go

declare @noteTypeKey integer
select @noteTypeKey = _NoteType_key from MGI_NoteType where _MGIType_key = 9 and noteType = 'Caption'

declare @maxKey integer
select @maxKey = max(_Note_key) from MGI_Note

insert into MGI_Note 
select seq + @maxKey, _Image_key, 9, @noteTypeKey, ${CREATEDBY}, ${CREATEDBY}, getdate(), getdate()
from #notes

insert into MGI_NoteChunk
select seq + @maxKey, n.sequenceNum, n.imageNote, ${CREATEDBY}, ${CREATEDBY}, n.creation_date, n.modification_date
from #notes s, IMG_ImageNote n
where s._Image_key = n._Image_key
go

drop table #notes
go

dump tran $DBNAME with truncate_only
go

checkpoint
go

quit

EOSQL

# add images to PixelDB
#./pixload.csh ${MLCIMAGES} pixmlc.txt >>& ${LOG}

# generate input files for MGI image structures
#./mgiimage.py

# load input files into MGI
#./imageload.py -S${DBSERVER} -D${DBNAME} -U${DBUSER} -p${DBPASSWORDFILE} -Mload

date | tee -a $LOG

