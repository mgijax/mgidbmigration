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

--4.2 Allele References
--2
create table ALL_ReferenceType
(
    _RefsType_key     int          NOT NULL
   ,referenceType     varchar(255) NOT NULL
   ,allowOnlyOne      bit          NOT NULL
   ,creation_date     datetime     NOT NULL
   ,modification_date datetime     NOT NULL
)
on mgd_seg_0
go

create table ALL_Reference
(
   _Allele_key       int      not null
  ,_Refs_key         int      not null
  ,_RefsType_key     int      not null
  ,creation_date     datetime not null
  ,modification_date datetime not null
)
on mgd_seg_0
go

--3
sp_primarykey ALL_ReferenceType, _RefsType_key
go

sp_primarykey ALL_Reference, _Allele_key, _Refs_key, _RefsType_key
go

sp_foreignkey ALL_Reference, ALL_Allele, _Allele_key
go

sp_foreignkey ALL_Reference, BIB_Refs, _Refs_key
go

sp_foreignkey ALL_Reference, ALL_ReferenceType, _RefsType_key
go

--4
exec sp_bindefault current_date_default, "ALL_ReferenceType.creation_date"
go
exec sp_bindefault current_date_default, "ALL_ReferenceType.modification_date"
go
exec sp_bindefault current_date_default, "ALL_Reference.creation_date"
go
exec sp_bindefault current_date_default, "ALL_Reference.modification_date"
go


--5
create unique clustered index index_RefsType_key on ALL_ReferenceType ( _RefsType_key ) 
on mgd_seg_0
go
create nonclustered index index_referenceType on ALL_ReferenceType ( referenceType ) 
on mgd_seg_1
go
create nonclustered index index_modification_date on ALL_ReferenceType ( modification_date ) 
on mgd_seg_1
go
create unique clustered index index_Allele_key_Refs_key on ALL_Reference ( _Allele_key, _Refs_key, _RefsType_key ) 
on mgd_seg_0
go
create nonclustered index index_Allele_key on ALL_Reference ( _Allele_key ) 
on mgd_seg_1
go
create nonclustered index index_Refs_key on ALL_Reference ( _Refs_key ) 
on mgd_seg_1
go
create nonclustered index index_RefsType_key on ALL_Reference ( _RefsType_key ) 
on mgd_seg_1
go
create nonclustered index index_modification_date on ALL_Reference ( modification_date ) 
on mgd_seg_1
go


--6.
grant select on ALL_ReferenceType to public
go
   -- DEVELOPMENT ONLY TAKE OUT FOR PRODUCTION!!!!
grant all    on ALL_ReferenceType to progs
go
grant all    on ALL_ReferenceType to cml, csmith
go
grant all on ALL_Reference to editors
go
   -- DEVELOPMENT ONLY TAKE OUT FOR PRODUCTION!!!!
grant all on ALL_Reference to progs
go
grant select on ALL_Reference to public
go

--7.
insert into ALL_ReferenceType values ( -1, 'Not Applicable', 1, getdate(), getdate() )
go
insert into ALL_ReferenceType values ( -2, 'Not Specified' , 1, getdate(), getdate() )
go
insert into ALL_ReferenceType values ( 1, 'Original'       , 1, getdate(), getdate() )
go
insert into ALL_ReferenceType values ( 2, 'Molecular'      , 1, getdate(), getdate() )
go
insert into ALL_ReferenceType values ( 3, 'Additional'     , 0, getdate(), getdate() )
go

--8.
insert ALL_Reference (_Allele_key, _Refs_key, _RefsType_key)
select _Allele_key, _Refs_key, 1
from   ALL_Allele
where  _Refs_key <> NULL
go

--9.
insert ALL_Reference (_Allele_key, _Refs_key, _RefsType_key)
select _Allele_key, _Molecular_Refs_key, 2
from   ALL_Allele
where  _Molecular_Refs_key <> NULL
go

--10
update ALL_Reference 
set    _RefsType_key = 3
from   ALL_Allele a, ALL_Reference r
where  a.symbol in 
(
   'hop<hpy>',
   'hr<ba>',
   'ic',
   'Atp7a<Mo-dp>',
   'Pax6<Sey>',
   'T<c>',
   'Galc<twi>',
   'Gli3<Xt-bph>',
   'Tyr<c-3H>',
   'fh',
   'fld',
   'lt',
   'Sha',
   'ti',
   'soc',
   'cg',
   'cr',
   'Prop1<df>',
   'fa',
   'fr',
   'ft',
   'oe',
   'pk',
   'pn',
   'rg',
   'ro',
   'Heph<sla>',
   'srn',
   'stb',
   'tk',
   'Wnt3a<vt>',
   'Phex<Gy>',
   'Hoxa13<Hd>',
   't<Lmb>',
   'Dst<dt-alb>',
   'hubb',
   'Lop4',
   'Lop5',
   'Lop6',
   'Lop7',
   'Lop9',
   'Lop8',
   'Cd80<tm1Shr>'
)
and a._Allele_key         = r._Allele_key
and a._Molecular_Refs_key = r._Refs_key
and r._RefsType_key       = 2
go

--11.
dump transaction $DATABASE with no_log
go 

EOSQL

echo Running DBO Script...
$DBO_SCRIPTS/dbo_sql $SQL_FILE >> $LOG_FILE

rm -rf $SQL_FILE

echo "$0 Script Completed..." >> $LOG_FILE
date >> $LOG_FILE
