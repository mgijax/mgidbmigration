#!/bin/sh

echo "running $0..."

DATABASE=$MGD
DBUSER=mgd_dbo 

SQL_FILE=$$.sql
DBO_SCRIPTS=$SYBASE/admin
        
rm -f $SQL_FILE
touch $SQL_FILE

DB_PWD_FILE=$DBO_SCRIPTS/.mgd_dbo_password

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

--4.4 ES Cell Line/Master Allele
--1.
--Includes modifications made in conjunction with both tr2217 and tr1939
sp_rename ALL_Allele, ALL_Allele_Save
go

--2.
create table ALL_CellLine
(
   _CellLine_key     int          not null
  ,cellLine          varchar(255) not null
  ,_Strain_key       int          not null
  ,creation_date     datetime     not null
  ,modification_date datetime     not null
)
on mgd_seg_0
go

create table ALL_Allele 
(
   _Allele_key        int           not null
  ,_Marker_key        int           null
  ,_Strain_key        int           not null
  ,_Mode_key          int           not null
  ,_Allele_Type_key   int           not null
  ,_CellLine_key      int           not null
  ,_Allele_Status_key int           not null
  ,symbol             varchar (50)  not null
  ,name               varchar (255) not null
  ,nomenSymbol        varchar (30)  null
  ,createdBy          varchar (30)  not null
  ,modifiedBy         varchar (30)  not null
  ,approvedBy         varchar (30)  null
  ,approval_date      datetime      null
  ,creation_date      datetime      not null
  ,modification_date  datetime      not null
)
on mgd_seg_0
go
--tr1939 addition
create table ALL_Status
(
   _Allele_Status_key int          not null,
   status             varchar(255) not null,
   creation_date      datetime     not null,
   modification_date  datetime     not null
)
on mgd_seg_0
go

--3.
sp_primarykey ALL_CellLine, _CellLine_key
go
sp_primarykey ALL_Allele,_Allele_key
go 
sp_foreignkey ALL_CellLine, PRB_Strain, _Strain_key
go

sp_foreignkey ALL_Allele, ALL_Inheritance_Mode, _Mode_key
go
sp_foreignkey ALL_Allele, ALL_Type, _Allele_Type_key
go
sp_foreignkey ALL_Allele, MRK_Marker, _Marker_key
go
sp_foreignkey ALL_Allele, PRB_Strain, _Strain_key
go
sp_foreignkey ALL_Allele, ALL_CellLine, _CellLine_key
go
sp_foreignkey ALL_Allele_Mutation, ALL_Allele, _Allele_key
go
sp_foreignkey MLD_Expt_Marker, ALL_Allele, _Allele_key
go
sp_foreignkey ALL_Synonym, ALL_Allele, _Allele_key
go
sp_foreignkey ALL_Note, ALL_Allele, _Allele_key
go
sp_foreignkey GXD_AllelePair, ALL_Allele, _Allele_key_1
go
sp_foreignkey GXD_AllelePair, ALL_Allele, _Allele_key_2
go



--tr1939 addition
sp_primarykey ALL_Status, _Allele_Status_key
go
--tr1939 addition 8.
sp_foreignkey ALL_Allele, ALL_Status, _Allele_Status_key
go

--4.
exec sp_bindefault current_date_default, "ALL_CellLine.creation_date"
go
exec sp_bindefault current_date_default, "ALL_CellLine.modification_date"
go
exec sp_bindefault current_date_default, "ALL_Allele.creation_date"
go
exec sp_bindefault current_date_default, "ALL_Allele.modification_date"
go
--tr1939 addition 9.
exec sp_bindefault current_date_default, "ALL_Allele.approval_date"
go
--tr1939 addition
exec sp_bindefault current_date_default, "ALL_Status.creation_date"
go
exec sp_bindefault current_date_default, "ALL_Status.modification_date"
go


--5.
create unique clustered  index index_CellLine_key on ALL_CellLine ( _CellLine_key ) 
on mgd_seg_0
go     
create nonclustered index index_Strain_key on ALL_CellLine ( _Strain_key ) 
on mgd_seg_1
go
create nonclustered index index_cellLine on ALL_CellLine ( cellLine ) 
on mgd_seg_1
go
create nonclustered index index_modification_date on ALL_CellLine ( modification_date ) 
on mgd_seg_1
go

create unique clustered  index index_Allele_key on ALL_Allele ( _Allele_key ) 
with sorted_data 
on mgd_seg_0
go     
create nonclustered  index index_Allele_Type_key on ALL_Allele ( _Allele_Type_key ) 
on mgd_seg_1
go
create nonclustered  index index_Strain_key on ALL_Allele ( _Strain_key ) 
on mgd_seg_1
go
create nonclustered  index index_Mode_key on ALL_Allele ( _Mode_key ) 
on mgd_seg_1
go
create nonclustered  index index_name on ALL_Allele ( name ) 
on mgd_seg_1
go
create nonclustered  index index_modification_date on ALL_Allele ( modification_date ) 
on mgd_seg_1
go
create nonclustered  index index_Marker_key on ALL_Allele ( _Marker_key ) 
on mgd_seg_1
go            
create nonclustered  index index_symbol on ALL_Allele ( symbol ) 
on mgd_seg_1
go
create nonclustered  index index_CellLine_key on ALL_Allele ( _CellLine_key ) 
on mgd_seg_1
go

--tr1939 additions 6.
create nonclustered  index index_Allele_Status_key on ALL_Allele ( _Allele_Status_key ) 
on mgd_seg_1
go
--tr1939 additions 7.
create nonclustered  index index_nomenSymbol on ALL_Allele ( nomenSymbol ) 
on mgd_seg_1
go
--tr1939 additions 8.
create nonclustered  index index_creation_date on ALL_Allele ( creation_date ) 
on mgd_seg_1
go
--tr1939 additions 9.
create nonclustered  index index_createdBy on ALL_Allele ( createdBy ) 
on mgd_seg_1
go

--tr1939 additions
create unique clustered  index index_Allele_Status_key on ALL_Status ( _Allele_Status_key ) 
with sorted_data 
on mgd_seg_0
go     
--tr1939 additions
create nonclustered  index index_status on ALL_Status ( status ) 
on mgd_seg_1
go
--tr1939 additions
create nonclustered  index index_modification_date on ALL_Status ( modification_date ) 
on mgd_seg_1
go




--6.
grant all on ALL_CellLine to cml, csmith
go
   -- DEVELOPMENT ONLY TAKE OUT FOR PRODUCTION!!!!
grant all on ALL_CellLine to progs
go
grant select on ALL_CellLine to public
go
grant all on ALL_Allele to editors
go
   -- DEVELOPMENT ONLY TAKE OUT FOR PRODUCTION!!!!
grant all on ALL_Allele to progs
go
grant select on ALL_Allele to public
go
   -- DEVELOPMENT ONLY TAKE OUT FOR PRODUCTION!!!!
grant all on ALL_Status to progs
go
grant select on ALL_Status to public
go

--7.
insert ALL_Allele (_Allele_key, _Marker_key, _Strain_key, _Mode_key, _Allele_Type_key, _CellLine_key, _Allele_Status_key, symbol, name, createdBy, modifiedBy, approvedBy, approval_date, creation_date, modification_date  )
select             _Allele_key, _Marker_key, _Strain_key, _Mode_key, _Allele_Type_key, -2,             4,                 symbol, name, "cml",     userID,     "cml",      creation_date, creation_date, modification_date 
from   ALL_Allele_Save
go

--tr1939 additions
insert into ALL_Status values ( -2, 'Not Applicable', getdate(), getdate() )
go
insert into ALL_Status values ( -1, 'Not Specified', getdate(), getdate() )
go
insert into ALL_Status values ( 1, 'Pending', getdate(), getdate() )
go
insert into ALL_Status values ( 2, 'Deleted', getdate(), getdate() )
go
insert into ALL_Status values ( 3, 'Reserved', getdate(), getdate() )
go
insert into ALL_Status values ( 4, 'Approved', getdate(), getdate() )
go

--8.
drop table ALL_Allele_Save
go

--9.
dump transaction $DATABASE with no_log
go 

EOSQL


echo "Running DBO Script..."
$DBO_SCRIPTS/dbo_sql $SQL_FILE >> $LOG_FILE
echo "Running DBO Script..."

rm -rf $SQL_FILE

echo "Loading BCP Files..."
cat $DB_PWD_FILE
cat $DB_PWD_FILE | bcp $DATABASE..ALL_CellLine in $MIGRATION/ESCellLine.bcp -S$DSQUERY -U$DBUSER -c -t"\t" -r"\n"
echo "Loading BCP Files Completed..."

echo "$0 Script Completed..." >> $LOG_FILE
date >> $LOG_FILE
