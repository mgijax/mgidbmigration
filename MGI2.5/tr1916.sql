#!/bin/csh -f

#
# Migration for TR 1916 & 1966
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

declare nomen_cursor cursor for
select _Nomen_key, mgiAccID
from MRK_Nomen
where mgiAccID is not null
for read only
go

open nomen_cursor

declare @nomenKey integer
declare @accID varchar(30)

fetch nomen_cursor into @nomenKey, @accID

while (@@sqlstatus = 0)
begin
	exec ACC_insert @nomenKey, @accID, 1, "Nomenclature"
	fetch nomen_cursor into @nomenKey, @accID
end

close nomen_cursor
deallocate cursor nomen_cursor
go

checkpoint
go

sp_rename MRK_Nomen, MRK_Nomen_Save
go

create table MRK_Nomen (
        _Nomen_key int not null,
        _Marker_Type_key int not null,
        _Marker_Status_key int not null,
        _Marker_Event_key int not null,
        _Marker_EventReason_key int not null,
        submittedBy varchar(30) not null,
        broadcastBy varchar(30) null,
        symbol varchar ( 25 ) not null,
        name varchar ( 255 ) not null,
        chromosome varchar ( 8 ) not null,
        humanSymbol varchar ( 25 ) null,
        statusNote varchar ( 255 ) null,
        broadcast_date datetime null,
        creation_date datetime not null,
        modification_date datetime not null 
)
go

insert MRK_Nomen
(_Nomen_key, _Marker_Type_key, _Marker_Status_key, _Marker_Event_key, _Marker_EventReason_key,
submittedBy, broadcastBy, symbol, name, chromosome, humanSymbol, statusNote,
broadcast_date, creation_date, modification_date)
select s._Nomen_key, s._Marker_Type_key, s._Marker_Status_key, s._Marker_Event_key, s._Marker_EventReason_key,
l1.name, l2.name, s.symbol, s.name, s.chromosome, s.humanSymbol, s.statusNote,
s.broadcast_date, s.creation_date, s.modification_date
from MRK_Nomen_Save s, master..syslogins l1, master..syslogins l2
where s._Suid_key = l1.suid
and s._Suid_broadcast_key *= l2.suid
go

/* defaults */

exec sp_bindefault current_date_default, "MRK_Nomen.creation_date"
go

exec sp_bindefault current_date_default, "MRK_Nomen.modification_date"
go

/* keys */

sp_primarykey MRK_Nomen, _Nomen_key
go

sp_foreignkey MRK_Nomen, MRK_Status, _Marker_Status_key
go

/* indexes */

create unique clustered  index _Nomen_key_index on MRK_Nomen ( _Nomen_key )
go

create nonclustered  index _Marker_Event_index on MRK_Nomen ( _Marker_Event_key )
go

create nonclustered  index index_modification_date on MRK_Nomen ( modification_date )
go

create nonclustered  index _Marker_EventReason_key_index on MRK_Nomen ( _Marker_EventReason_key )
go

create nonclustered  index _Marker_Status_key_Index on MRK_Nomen ( _Marker_Status_key )
go

create nonclustered  index submittedBy_index on MRK_Nomen ( submittedBy )
go

create nonclustered  index broadcastBy_index on MRK_Nomen ( broadcastBy )
go

create nonclustered  index _Marker_Type_Index on MRK_Nomen ( _Marker_Type_key )
go

create nonclustered  index index_symbol on MRK_Nomen ( symbol )
go

create nonclustered  index index_chromosome on MRK_Nomen ( chromosome )
go

create nonclustered  index index_broadcast_date on MRK_Nomen ( broadcast_date )
go

/* permissions */

grant all on MRK_Nomen to dbradt, djr, dph, lhg, ljm, lmm, rmb, sr, tc, tier2, tier3, tier4

go

grant select on MRK_Nomen to public
go

/* remove when migrating to production */

grant all on MRK_Nomen to progs
go

drop table MRK_Nomen_Save
go

checkpoint
go

quit
 
EOSQL
  
$scripts/dbo_sql $sql >> $LOG
rm $sql
   
date >> $LOG
