#!/bin/csh -f

#
# Migration for TR 2237/Marker History
#

echo "running $0..."

setenv SYBASE   /opt/sybase

setenv DSQUERY	 $1
setenv MGD	$2

setenv LOG $0.log

set scripts = $SYBASE/admin

rm -rf $LOG
touch $LOG
 
date >> $LOG
 
set sql = /tmp/$$.sql

cat > $sql << EOSQL
   
use $MGD
go

/* Migrate Data */

select distinct h._Marker_key, h.history, h._Refs_key, seq = identity(5)
into #newother
from MRK_History_View h
where h._Marker_key != h._History_key
and h._Marker_Event_key = 1
and not exists (select 1 from MRK_Other o
where h._Marker_key = o._Marker_key
and h.symbol = o.name)
go

declare @maxKey int
select @maxKey = max(_Other_key) from MRK_Other

insert into MRK_Other
select @maxKey + seq, _Marker_key, _Refs_key, history, getdate(), getdate()
from #newother
go

checkpoint
go

dump transaction $MGD with no_log
go

quit
 
EOSQL
  
$scripts/dbo_sql $sql >> $LOG
rm $sql
   
date >> $LOG
