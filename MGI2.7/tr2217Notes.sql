#!/bin/sh

echo "running $0..."

DATABASE=$MGD

SQL_FILE=$$.sql
DBO_SCRIPTS=$SYBASE/admin

rm -f $SQL_FILE
touch $SQL_FILE

echo "$0 Script Starting..." >> $LOG_FILE
date >> $LOG_FILE

cat > $SQL_FILE << EOSQL

--Database call
use $DATABASE
go

checkpoint
go

dump transaction $DATABASE with no_log
go



--4.3 Allele Notes
--1.
sp_rename ALL_Note, ALL_Note_Save
go

--2.
create table ALL_NoteType
(
   _NoteType_key     int          not null
  ,noteType          varchar(255) not null
  ,private           bit          not null
  ,creation_date     datetime     not null
  ,modification_date datetime     not null
)
on mgd_seg_0
go

create table ALL_Note 
(
   _Allele_key       int          not null
  ,_NoteType_key     int          not null
  ,sequenceNum       int          not null
  ,private           bit          not null
  ,note              char ( 255 ) not null
  ,creation_date     datetime     not null
  ,modification_date datetime     not null
)
on mgd_seg_0
go                                                                             

--3.
sp_primarykey ALL_NoteType, _NoteType_key
go
sp_primarykey ALL_Note, _Allele_key, sequenceNum, _NoteType_key
go
sp_foreignkey ALL_Note, ALL_NoteType, _NoteType_key
go

--4.
exec sp_bindefault current_date_default, "ALL_Note.creation_date"
go
exec sp_bindefault current_date_default, "ALL_Note.modification_date"
go
exec sp_bindefault current_date_default, "ALL_NoteType.creation_date"
go
exec sp_bindefault current_date_default, "ALL_NoteType.modification_date"
go

--5.
create unique clustered index index_NoteType_key on ALL_NoteType ( _NoteType_key ) 
on mgd_seg_0
go
create nonclustered index index_modification_date on ALL_NoteType ( modification_date ) 
on mgd_seg_1
go
create nonclustered index index_noteType on ALL_NoteType ( noteType ) 
on mgd_seg_1
go

create unique clustered index index_Allele_key_sequenceNum on ALL_Note ( _Allele_key, sequenceNum, _NoteType_key ) 
on mgd_seg_0
go
create nonclustered  index index_NoteType_key on ALL_Note ( _NoteType_key ) 
on mgd_seg_1
go
create nonclustered  index index_note on ALL_Note ( note ) 
on mgd_seg_1
go
create nonclustered  index index_modification_date on ALL_Note ( modification_date ) 
on mgd_seg_1 
go
create nonclustered  index index_Allele_key on ALL_Note ( _Allele_key ) 
on mgd_seg_1 
go


-- 6.
   -- DEVELOPMENT ONLY TAKE OUT FOR PRODUCTION!!!!
grant select on ALL_NoteType to public
go
grant all on ALL_NoteType to progs
go
grant all on ALL_NoteType to cml, csmith
go
grant all on ALL_Note to editors
go
   -- DEVELOPMENT ONLY TAKE OUT FOR PRODUCTION!!!!
grant all on ALL_Note to progs
go
grant select on ALL_Note to public
go

-- 7.
insert into ALL_NoteType values ( -1, 'Not Applicable', 0, getdate(), getdate() )
go
insert into ALL_NoteType values ( -2, 'Not Specified', 0, getdate(), getdate() )
go
insert into ALL_NoteType values ( 1, 'General', 0, getdate(), getdate() )
go
insert into ALL_NoteType values ( 2, 'Molecular', 0, getdate(), getdate() )
go
insert into ALL_NoteType values ( 3, 'Promoter', 0, getdate(), getdate() )
go
insert into ALL_NoteType values ( 4, 'Nomenclature', 1, getdate(), getdate() )
go


-- 8.
insert ALL_Note (_Allele_key, sequenceNum, _NoteType_key, private, note, creation_date, modification_date)
select _Allele_key, sequenceNum, 1, 0, note, creation_date, modification_date
from   ALL_Note_Save
go

-- 9.
insert ALL_Note (_Allele_key, sequenceNum, _NoteType_key, private, note, creation_date, modification_date)
select _Allele_key, sequenceNum, 2, 0, note, creation_date, modification_date
from   ALL_Molecular_Note
go

-- 10.
drop table ALL_Molecular_Note
go


--11.
drop table ALL_Note_Save
go

--12.
dump transaction $DATABASE with no_log
go 

EOSQL

echo Running DBO Script...
$DBO_SCRIPTS/dbo_sql $SQL_FILE >> $LOG_FILE

rm -rf $SQL_FILE

echo "$0 Script Completed..." >> $LOG_FILE
date >> $LOG_FILE
