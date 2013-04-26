#!/bin/csh -f

#
# Template
#

#setenv MGICONFIG /usr/local/mgi/live/mgiconfig
#setenv MGICONFIG /usr/local/mgi/test/mgiconfig
#source ${MGICONFIG}/master.config.csh

cd `dirname $0`

setenv LOG $0.log
rm -rf $LOG
touch $LOG
 
date | tee -a $LOG
 
cat - <<EOSQL | doisql.csh $MGD_DBSERVER $MGD_DBNAME $0 | tee -a $LOG

use $MGD_DBNAME
go

begin transaction
update IMG_Image set _ModifiedBy_key = 1001, modification_date = getdate() where _Image_key = 442054
declare @noteKey int
select @noteKey = max(_Note_key) + 1 from MGI_Note
if @noteKey is NULL or @noteKey = 0
begin
select @noteKey = 1000
end
insert MGI_Note (_Note_key, _Object_key, _MGIType_key, _NoteType_key, _CreatedBy_key, _ModifiedBy_key)
values(@noteKey,442054,9,1039,1001,1001)
insert MGI_NoteChunk (_Note_key, sequenceNum, note, _CreatedBy_key, _ModifiedBy_key)
values(@noteKey,1,'\Link(https://ndp.jax.org/NDPServe.dll?ViewItem?ItemID=29307&XPos=-11951804&YPos=-4048671&ZPos=0&Lens=0.6912477047653858&SignIn=Sign%20in%20as%20Guest|Full Image|)',1001,1001)
select @noteKey = @noteKey + 1

commit transaction
go

begin transaction
update IMG_Image set _ModifiedBy_key = 1001, modification_date = getdate() where _Image_key = 442058
declare @noteKey int
select @noteKey = max(_Note_key) + 1 from MGI_Note
if @noteKey is NULL or @noteKey = 0
begin
select @noteKey = 1000
end
insert MGI_Note (_Note_key, _Object_key, _MGIType_key, _NoteType_key, _CreatedBy_key, _ModifiedBy_key)
values(@noteKey,442058,9,1039,1001,1001)
insert MGI_NoteChunk (_Note_key, sequenceNum, note, _CreatedBy_key, _ModifiedBy_key)
values(@noteKey,1,'\Link(https://ndp.jax.org/NDPServe.dll?ViewItem?ItemID=19855&XPos=19464953&YPos=7550599&ZPos=0&Lens=8.322464221082296&SignIn=Sign%20in%20as%20Guest|Full Image|)',1001,1001)
select @noteKey = @noteKey + 1

commit transaction
gp

begin transaction
update IMG_Image set _ModifiedBy_key = 1001, modification_date = getdate() where _Image_key = 442086
declare @noteKey int
select @noteKey = max(_Note_key) + 1 from MGI_Note
if @noteKey is NULL or @noteKey = 0
begin
select @noteKey = 1000
end
insert MGI_Note (_Note_key, _Object_key, _MGIType_key, _NoteType_key, _CreatedBy_key, _ModifiedBy_key)
values(@noteKey,442086,9,1039,1001,1001)
insert MGI_NoteChunk (_Note_key, sequenceNum, note, _CreatedBy_key, _ModifiedBy_key)
values(@noteKey,1,'\Link(http://connectivity.brain-map.org/transgenic/search?exact_match=false&search_term=Calb2-IRES-cre&search_type=line|Full Image|)',1001,1001)
select @noteKey = @noteKey + 1

commit transaction
go

checkpoint
go

end

EOSQL

update image set external_link = '\\Link(https://ndp.jax.org/NDPServe.dll?ViewItem?ItemID=29307&XPos=-11951804&YPos=-4048671&ZPos=0&Lens=0.6912477047653858&SignIn=Sign%20in%20as%20Guest|Full Image|)'
where image_key = 442054

update image set external_link = '\\Link(https://ndp.jax.org/NDPServe.dll?ViewItem?ItemID=19855&XPos=19464953&YPos=7550599&ZPos=0&Lens=8.322464221082296&SignIn=Sign%20in%20as%20Guest|Full Image|)'
where image_key = 442058 

update image set external_link = '\\Link(http://connectivity.brain-map.org/transgenic/search?exact_match=false&search_term=Calb2-IRES-cre&search_type=line|Full Image|)'
where image_key = 442086 

date |tee -a $LOG

