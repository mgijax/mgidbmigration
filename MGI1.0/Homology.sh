#!/bin/csh -f

#
# Migrate MGD3.3 Homology data into MGI1.0 structures
#

setenv DSQUERY $1
setenv MGD $2
setenv CREATEIDX $3

set scripts = $SYBASE/admin

$scripts/indexes/MGD_DEV/HMD.drop $DSQUERY $MGD
HMD.drop.tr $DSQUERY $MGD

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
 
truncate table HMD_Class
go

truncate table HMD_Homology
go

truncate table HMD_Homology_Marker
go

truncate table HMD_Assay
go

truncate table HMD_Homology_Assay
go

truncate table HMD_Notes
go

drop trigger HMD_Homology_Marker_Delete
go

drop trigger HMD_Homology_Marker_Insert
go

/* HMD_Class */

insert HMD_Class (_Class_key)
select distinct _Class_key from mgd..HMD_Homology
go

checkpoint
go

/* HMD_Homology */

insert HMD_Homology (_Homology_key, _Class_key, _Refs_key, creation_date,
modification_date)
select distinct r._Homology_key, h._Class_key, r._Refs_key,
r.creation_date, r.modification_date
from mgd..HMD_Reference r, mgd..HMD_Homology h
where r._Homology_key = h._Homology_key
go

checkpoint
go

/* HMD_Homology_Marker */

insert HMD_Homology_Marker (_Homology_key, _Marker_key)
select _Homology_key, _Marker_key
from mgd..HMD_Homology
go

checkpoint
go

/* HMD_Assay */

insert HMD_Assay (_Assay_key, assay)
select _Assay_key, assay
from mgd..HMD_Assay
go

checkpoint
go

/* HMD_Homology_Assay */

insert HMD_Homology_Assay (_Homology_key, _Assay_key)
select _Homology_key, _Assay_key
from mgd..HMD_Homology_Assay
go

checkpoint
go

/* HMD_Notes */

insert HMD_Notes (_Homology_key, sequenceNum, notes)
select _Homology_key, sequenceNum, notes
from mgd..HMD_Notes
go

checkpoint
go

/* Change HMD_Assay 'Not specified' to 'Not Specified', key = -1 */

update HMD_Assay set assay = 'to be removed' where _Assay_key = 13
go

insert into HMD_Assay values (-1, 'Not Specified', getdate(), getdate())
go

update HMD_Homology_Assay set _Assay_key = -1 where _Assay_key = 13
go

delete from HMD_Assay where _Assay_key = 13
go

/* Add an Assay of "Unreviewed" (15) for any Homology which does not have an Assay */
/* Every Homology MUST have an assay */

select distinct m._Homology_key into #noassay
from HMD_Homology_Marker m
where not exists (select * from HMD_Homology_Assay a where m._Homology_key = a._Homology_key)
go

insert into HMD_Homology_Assay (_Homology_key, _Assay_key)
select _Homology_key, 15
from #noassay
go

checkpoint
go

quit
 
EOSQL
 
$scripts/dbo_sql $sql
rm $sql

if ( $CREATEIDX == "index" ) then
	$scripts/indexes/MGD_DEV/HMD.idx $DSQUERY $MGD
endif

