#!/bin/csh -f

#
# Migration for TR 1343
#

setenv SYBASE	/opt/sybase
setenv PYTHONPATH       /usr/local/lib/python1.4:/usr/local/etc/httpd/python
set path = ($path $SYBASE/bin)

setenv DSQUERY $1
setenv MGD $2

setenv LOG $0.log

rm -rf $LOG
touch $LOG
 
date >> $LOG
 
set scripts = $SYBASE/admin

set sql = /tmp/$$.sql
 
cat > $sql << EOSQL
 
use master
go
 
sp_dboption $MGD, "select into", true
go
  
use $MGD
go
   
checkpoint
go
 
drop table tempdb..MRK_Marker1343
go

drop table tempdb..HMD_Homology_Marker1343
go

drop table tempdb..HMD_Homology1343
go

drop table tempdb..HMD_Homology_Assay1343
go

drop table tempdb..HMD_Class1343
go

drop table tempdb..BIB_Refs1343
go

drop table tempdb..ACC_Accession1343
go

drop table tempdb..MRK_Species1343
go

select h._Class_key, m._Marker_key
into #all
from HMD_Homology h, HMD_Homology_Marker m
where h._Homology_key = m._Homology_key
go

select *
into #single
from #all
group by _Class_key
having count(*) = 1
go

select * 
into #singlereference
from HMD_Homology_Marker
group by _Homology_key
having count(*) = 1
go

select m.*
into #marker
from #single s, HMD_Homology h, HMD_Homology_Marker hm, MRK_Marker m
where s._Class_key = h._Class_key
and h._Homology_key = hm._Homology_key
and hm._Marker_key = m._Marker_key
go

select hm.*
into #homologymarker
from #single s, HMD_Homology h, HMD_Homology_Marker hm
where s._Class_key = h._Class_key
and h._Homology_key = hm._Homology_key
union
select *
from #singlereference
go

select h.*
into #homology
from #single s, HMD_Homology h
where s._Class_key = h._Class_key
union
select h.*
from #singlereference s, HMD_Homology h
where s._Homology_key = h._Homology_key
go

select a.*
into #homologyassay
from #homology h, HMD_Homology_Assay a
where h._Homology_key = a._Homology_key
go

select c.*
into #homologyclass
from #single s, HMD_Class c
where s._Class_key = c._Class_key
go

select *
into tempdb..MRK_Marker1343
from #marker
go

select *
into tempdb..HMD_Homology_Marker1343
from #homologymarker
go

select *
into tempdb..HMD_Homology1343
from #homology
go

select *
into tempdb..HMD_Homology_Assay1343
from #homologyassay
go

select *
into tempdb..HMD_Class1343
from #homologyclass
go

quit

EOSQL

$scripts/dbo_sql $sql >> $LOG
rm $sql

cat $scripts/.mgd_dbo_password | bcp tempdb..MRK_Marker1343 out MRK_Marker1343.bcp -c -t\\t -Umgd_dbo >> $LOG
cat $scripts/.mgd_dbo_password | bcp tempdb..HMD_Homology_Marker1343 out HMD_Homology_Marker1343.bcp -c -t\\t -Umgd_dbo >> $LOG
cat $scripts/.mgd_dbo_password | bcp tempdb..HMD_Homology1343 out HMD_Homology1343.bcp -c -t\\t -Umgd_dbo >> $LOG
cat $scripts/.mgd_dbo_password | bcp tempdb..HMD_Homology_Assay1343 out HMD_Homology_Assay1343.bcp -c -t\\t -Umgd_dbo >> $LOG
cat $scripts/.mgd_dbo_password | bcp tempdb..HMD_Class1343 out HMD_Class1343.bcp -c -t\\t -Umgd_dbo >> $LOG

set sql = /tmp/$$.sql
 
cat > $sql << EOSQL
 
use master
go
 
sp_dboption $MGD, "select into", true
go
  
use $MGD
go
   
checkpoint
go
 
/* delete single homology classes */

select h._Class_key, m._Marker_key
into #homology
from HMD_Homology h, HMD_Homology_Marker m
where h._Homology_key = m._Homology_key
go

select *
into #single
from #homology
group by _Class_key
having count(*) = 1
go

/* save references of classes which will be deleted */

select distinct h._Refs_key
into #references1
from #single s, HMD_Homology h
where s._Class_key = h._Class_key
go

delete HMD_Class
from #single s, HMD_Class c
where s._Class_key = c._Class_key
go

drop table #single
go

checkpoint
go

/* delete single homology references */

select * 
into #single
from HMD_Homology_Marker
group by _Homology_key
having count(*) = 1
go

/* save references of classes which will be deleted */

select distinct h._Refs_key
into #references2
from #single s, HMD_Homology h
where s._Homology_key = h._Homology_key
go

delete HMD_Homology
from #single s, HMD_Homology h
where s._Homology_key = h._Homology_key
go

delete HMD_Homology_Marker
from #single s, HMD_Homology_Marker h
where s._Homology_key = h._Homology_key
go

checkpoint
go

/* delete markers with no homologies */

select m._Marker_key, m.symbol, m._Species_key
into #markers
from MRK_Marker m
where _Species_key != 1
and not exists (select 1 from HMD_Homology_Marker h
where m._Marker_key = h._Marker_key)
go

delete MRK_Marker
from #markers m, MRK_Marker r
where m._Marker_key = r._Marker_key
go

checkpoint
go

/* delete species with no homologies */

select s.*
into #species
from MRK_Species s
where _Species_key not in (1,2)
and not exists (select 1 from HMD_Homology_Marker h, MRK_Marker m
where h._Marker_key = m._Marker_key
and m._Species_key = s._Species_key)
go

delete MRK_Species
from #species s, MRK_Species p
where s._Species_key = p._Species_key
go

select * into tempdb..MRK_Species1343
from #species
go

checkpoint
go

/* get references of homologies w/ no marker */

select distinct h._Refs_key
into #references3
from HMD_Homology h
where not exists (select 1 from HMD_Homology_Marker m
where h._Homology_key = m._Homology_key)
go

/* save references for later deletion or revision */

select b.*
into tempdb..BIB_Refs1343
from #references1 r, BIB_Refs b
where r._Refs_key = b._Refs_key
go

insert into tempdb..BIB_Refs1343
select b.*
from #references2 r, BIB_Refs b
where r._Refs_key = b._Refs_key
and not exists (select 1 from tempdb..BIB_Refs1343 t
where r._Refs_key = t._Refs_key)
go

insert into tempdb..BIB_Refs1343
select b.*
from #references3 r, BIB_Refs b
where r._Refs_key = b._Refs_key
and not exists (select 1 from tempdb..BIB_Refs1343 t
where r._Refs_key = t._Refs_key)
go

select a.*
into tempdb..ACC_Accession1343
from tempdb..BIB_Refs1343 b, ACC_Accession a
where b._Refs_key = a._Object_key
and a._MGIType_key = 1
go

checkpoint
go

quit
 
EOSQL
 
$scripts/dbo_sql $sql >> $LOG
rm $sql
 
cat $scripts/.mgd_dbo_password | bcp tempdb..BIB_Refs1343 out BIB_Refs1343.bcp -c -t\\t -Umgd_dbo >> $LOG
cat $scripts/.mgd_dbo_password | bcp tempdb..ACC_Accession1343 out ACC_Accession1343.bcp -c -t\\t -Umgd_dbo >> $LOG
cat $scripts/.mgd_dbo_password | bcp tempdb..MRK_Species1343 out MRK_Species1343.bcp -c -t\\t -Umgd_dbo >> $LOG

# Re-build MRK_Symbol, MRK_Name and MRK_Reference
# Markers were deleted in the last step and
# we want to clean up these tables before
# trying to delete references

pushd `pwd`
pushd $SYBASE/admin/utilities/MRK
./createMRK.sh $DSQUERY $MGD >> $LOG
popd

set sql = /tmp/$$.sql
 
cat > $sql << EOSQL
 
use master
go
 
sp_dboption $MGD, "select into", true
go
  
use $MGD
go
   
checkpoint
go

/* Delete HMD_Homology records w/o HMD_Homology_Marker records */

delete HMD_Homology
from HMD_Homology h
where not exists (select 1 from HMD_Homology_Marker m
where h._Homology_key = m._Homology_key)
go

/* Delete HMD_Class records w/o HMD_Homology records */

delete HMD_Class
from HMD_Class c
where not exists (select 1 from HMD_Homology h
where c._Class_key = h._Class_key)
go

/* delete or revise references */

delete BIB_Refs
from tempdb..BIB_Refs1343 r, BIB_Refs b
where r._Refs_key = b._Refs_key
and 
(b.dbs = 'Homology'
or b.dbs = 'Homology*'
or b.dbs = 'Homology/'
or b.dbs = 'Homology*/')
and not exists
(select 1 from HMD_Homology h
where r._Refs_key = h._Refs_key)
and not exists
(select 1 from MRK_Reference h
where r._Refs_key = h._Refs_key)
and not exists
(select 1 from MLC_Reference h
where r._Refs_key = h._Refs_key)
go

declare ref_cursor cursor for
select r._Refs_key, r.dbs
from tempdb..BIB_Refs1343 r
where r.dbs like '%Homology%'
and not exists
(select 1 from HMD_Homology h
where r._Refs_key = h._Refs_key)
for read only
go

declare @refKey integer
declare @dbs varchar(60)
declare @newdbs varchar(60)
declare @idx integer

open ref_cursor
 
 fetch ref_cursor into @refKey, @dbs
   
   while (@@sqlstatus = 0)
   begin
	select @idx = charindex("Homology*", @dbs)

	if (@idx > 0)
	begin
		select @newdbs = substring(@dbs, 1, @idx - 1) + 
			substring(@dbs, @idx + char_length("Homology*") + 1, char_length(@dbs))
		update BIB_Refs set dbs = @newdbs where _Refs_key = @refKey
	end

	else
	begin
	  select @idx = charindex("Homology", @dbs)
	  if (@idx > 0)
	  begin
		select @newdbs = substring(@dbs, 1, @idx - 1) + 
			substring(@dbs, @idx + char_length("Homology") + 1, char_length(@dbs))
		update BIB_Refs set dbs = @newdbs where _Refs_key = @refKey
	  end
	end

 	fetch ref_cursor into @refKey, @dbs
   end

close ref_cursor
deallocate cursor ref_cursor
go

checkpoint
go

quit
 
EOSQL
 
$scripts/dbo_sql $sql >> $LOG
rm $sql

date >> $LOG

