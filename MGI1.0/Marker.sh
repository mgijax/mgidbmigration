#!/bin/csh -f

#
# Migrate MGD3.3 Marker History data into MGI1.0 structures
#

setenv DSQUERY $1
setenv MGD $2

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
 
drop index MRK_History.index_Refs_key        
go
 
drop index MRK_History.index_Marker_key        
go
 
drop index MRK_History.index_History_key        
go
 
drop index MRK_History.index_sequenceNum_Marker_key
go
 
truncate table MRK_History
go

/* MRK_History */

insert MRK_History 
(_Marker_key, _History_key, _Refs_key, sequenceNum, name, note, event_date, creation_date)
select _Marker_key, _History_key, _Refs_key, sequenceNum, name, note, creation_date, modification_date
from mgd..MRK_History
go

checkpoint
go

create unique clustered index index_sequenceNum_Marker_key on dbo.MRK_History 
(sequenceNum,_Marker_key,_History_key)
go
 
create nonclustered index index_Refs_key on dbo.MRK_History (_Refs_key)
go
 
create nonclustered index index_Marker_key on dbo.MRK_History (_Marker_key)
go
 
create nonclustered index index_History_key on dbo.MRK_History (_History_key)
go
 
quit
 
EOSQL
 
$scripts/dbo_sql $sql
rm $sql

