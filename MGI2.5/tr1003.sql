#!/bin/csh -f

#
# Migration for TR 1003
#

setenv SYBASE   /opt/sybase

setenv DSQUERY	 $1
setenv DATABASE	$2

setenv LOG $0.log

set scripts = $SYBASE/admin

rm -rf $LOG
touch $LOG
 
date >> $LOG
 
set sql = /tmp/$$.sql

cat > $sql << EOSQL
   
use $DATABASE
go

checkpoint
go

sp_rename GXD_Antibody, GXD_Antibody_Save
go

create table GXD_Antibody (
        _Antibody_key int not null,
        _Refs_key int null,
        _AntibodyClass_key int not null,
        _AntibodyType_key int not null,
	_AntibodySpecies_key int not null,
        _Antigen_key int null,
        antibodyName varchar ( 255 ) not null,
        antibodyNote varchar ( 255 ) null,
        recogWestern varchar ( 15 ) not null,
        recogImmunPrecip varchar ( 15 ) not null,
        recogNote varchar ( 255 ) null,
        creation_date datetime not null,
        modification_date datetime not null 
)
on mgd_seg_0 
go

create table GXD_AntibodySpecies (
	_AntibodySpecies_key int not null,
	antibodySpecies varchar(80) not null,
        creation_date datetime not null,
        modification_date datetime not null 
)
on mgd_seg_0 
go

select distinct(antibodySpecies), seq = identity(5)
into #speciesTemp
from GXD_Antibody_Save
where antibodySpecies not like 'not %'
go

insert into GXD_AntibodySpecies values (-2, "Not Applicable", getdate(), getdate())
go

insert into GXD_AntibodySpecies values (-1, "Not Specified", getdate(), getdate())
go

declare @maxKey int
select @maxKey = 0

insert into GXD_AntibodySpecies
select @maxKey + seq, antibodySpecies, getdate(), getdate()
from #speciesTemp
go

insert GXD_Antibody
(_Antibody_key, _AntibodyClass_key, _Refs_key, _AntibodyType_key, _AntibodySpecies_key,
_Antigen_key, antibodyName, antibodyNote, recogWestern, recogImmunPrecip, recogNote,
creation_date, modification_date)
select a._Antibody_key, a._AntibodyClass_key, a._Refs_key, a._AntibodyType_key, s._AntibodySpecies_key,
a._Antigen_key, a.antibodyName, a.antibodyNote, a.recogWestern, a.recogImmunPrecip, a.recogNote,
a.creation_date, a.modification_date
from GXD_Antibody_Save a, GXD_AntibodySpecies s
where a.antibodySpecies = s.antibodySpecies
go

/* defaults */

exec sp_bindefault current_date_default, "GXD_Antibody.creation_date"
go

exec sp_bindefault current_date_default, "GXD_Antibody.modification_date"
go

exec sp_bindefault current_date_default, "GXD_AntibodySpecies.creation_date"
go

exec sp_bindefault current_date_default, "GXD_AntibodySpecies.modification_date"
go

/* keys */

sp_primarykey GXD_Antibody,_Antibody_key
go

sp_primarykey GXD_AntibodySpecies,_AntibodySpecies_key
go

sp_foreignkey GXD_Antibody, BIB_Refs, _Refs_key
go

sp_foreignkey GXD_AntibodyMarker, GXD_Antibody, _Antibody_key
go

sp_foreignkey GXD_AntibodyPrep, GXD_Antibody, _Antibody_key
go

sp_foreignkey GXD_AntibodyAlias, GXD_Antibody, _Antibody_key
go

sp_foreignkey GXD_Antibody, GXD_AntibodyClass, _AntibodyClass_key
go

sp_foreignkey GXD_Antibody, GXD_AntibodyType, _AntibodyType_key
go

sp_foreignkey GXD_Antibody, GXD_AntibodySpecies, _AntibodySpecies_key
go

/* indexes */

create unique clustered index index_Antibody_key on GXD_Antibody ( _Antibody_key ) 
on mgd_seg_0
go

create nonclustered index index_modification_date on GXD_Antibody ( modification_date ) 
on mgd_seg_1
go

create nonclustered index index_AntibodyClass_key on GXD_Antibody ( _AntibodyClass_key ) 
on mgd_seg_1
go

create nonclustered index index_AntibodyType_key on GXD_Antibody ( _AntibodyType_key ) 
on mgd_seg_1
go

create nonclustered index index_AntibodySpecies_key on GXD_Antibody ( _AntibodySpecies_key ) 
on mgd_seg_1
go

create nonclustered index index_Antigen_key on GXD_Antibody ( _Antigen_key ) 
on mgd_seg_1
go

create nonclustered index index_Refs_key on GXD_Antibody ( _Refs_key ) 
on mgd_seg_1
go

create unique clustered index index_AntibodySpecies_key on GXD_AntibodySpecies (_AntibodySpecies_key)
with sorted_data on mgd_seg_0
go

create nonclustered index index_modification_date on GXD_AntibodySpecies ( modification_date ) 
on mgd_seg_1
go

/* permissions */

grant all on GXD_Antibody to dab, dph, ijm
go

grant select on GXD_Antibody to public
go

grant all on GXD_AntibodySpecies to dab, dph, ijm
go

grant select on GXD_AntibodySpecies to public
go

/* remove when migrating to production */

grant all on GXD_Antibody to progs
go

grant all on GXD_AntibodySpecies to progs
go

drop table GXD_Antibody_Save
go

checkpoint
go

quit
 
EOSQL
  
$scripts/dbo_sql $sql >> $LOG
rm $sql
   
date >> $LOG
