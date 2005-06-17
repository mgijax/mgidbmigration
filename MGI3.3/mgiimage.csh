#!/bin/csh -f

#
# Migration for Images
#
# IMG_Image
# IMG_ImagePane_Assoc (new)
# IMG_ImageNote (deleting)
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
${newmgddbschema}/table/IMG_ImagePane_Assoc_create.object | tee -a ${LOG}

${newmgddbschema}/index/IMG_ImagePane_Assoc_create.object | tee -a ${LOG}

${newmgddbschema}/default/IMG_Image_bind.object | tee -a ${LOG}
${newmgddbschema}/default/IMG_ImagePane_Assoc_bind.object | tee -a ${LOG}

${newmgddbschema}/trigger/IMG_drop.logical | tee -a ${LOG}
${newmgddbschema}/trigger/IMG_create.logical | tee -a ${LOG}
${newmgddbschema}/trigger/ALL_Allele_drop.object | tee -a ${LOG}
${newmgddbschema}/trigger/ALL_Allele_create.object | tee -a ${LOG}
${newmgddbschema}/trigger/GXD_Genotype_drop.object | tee -a ${LOG}
${newmgddbschema}/trigger/GXD_Genotype_create.object | tee -a ${LOG}

${newmgddbschema}/procedure/IMG_drop.logical | tee -a ${LOG}
${newmgddbschema}/procedure/IMG_create.logical | tee -a ${LOG}

${newmgddbschema}/view/MGI_Note_Image_View_create.object | tee -a ${LOG}
${newmgddbschema}/view/MGI_NoteType_Image_View_create.object | tee -a ${LOG}

cat - <<EOSQL | doisql.csh $0 | tee -a ${LOG}

use ${DBNAME}
go

/* IMG_Image */

declare @typeKey integer
select @typeKey = t._Term_key from VOC_Term t, VOC_Vocab v
        where t._Vocab_key = v._Vocab_key
        and v.name = 'Image Type'
        and t.term = 'Full Size'

insert into IMG_Image
select o._Image_key, @typeKey, o._Refs_key, null, o.xDim, o.yDim, o.figureLabel, ${CREATEDBY}, ${CREATEDBY}, o.creation_date, o.modification_date
from IMG_Image_Old o
go

/* ACC_MGIType */

declare @mgiTypeKey integer
select @mgiTypeKey = max(_MGIType_key) + 1 from ACC_MGIType

insert into ACC_MGIType values(@mgiTypeKey, 'Image Pane Association', 'IMG_ImagePane_Assoc', '_Assoc_key', null, null, ${CREATEDBY}, ${CREATEDBY}, getdate(), getdate())
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

/* reference type */

declare @refTypeKey integer
select @refTypeKey = max(_RefAssocType_key) + 1 from MGI_RefAssocType

insert into MGI_RefAssocType values(@refTypeKey, 29, 'General', 0, ${CREATEDBY}, ${CREATEDBY}, getdate(), getdate())
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

${newmgddbschema}/index/IMG_Image_create.object | tee -a ${LOG}

date | tee -a $LOG

