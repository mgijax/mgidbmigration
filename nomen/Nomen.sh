#!/bin/csh -f

#
# amber
# Lori (leo)
#
# TR 156
# Migration Nomen DB into new Nomen database structures
#

setenv DSQUERY	$1
setenv NOMEN	$2
setenv MGD	$3

#
# Used by nomen_drop_indices and nomen_create_indices...
#

setenv MGD_DST_SRV $DSQUERY
setenv MGD_DST_DB  $NOMEN

setenv LOG `pwd`/$0.log

rm -rf $LOG
touch $LOG

date >> $LOG

set scripts = $SYBASE/admin
set sql = /tmp/$$.sql
 
# Remove indexes
$scripts/nomen/nomen_drop_indices >> $LOG

cat > $sql << EOSQL
 
use master
go
 
sp_dboption tempdb, "select into", true
go
  
use tempdb
go
   
checkpoint
go

use master
go

sp_dboption $NOMEN, "select into", true
go
  
use $NOMEN
go
   
checkpoint
go
 
drop table tempdb..NomenAll
go

create table tempdb..NomenAll
(
chromosome 	varchar(5) not null,
approvedSymbol	varchar(25) null,
nomenType 	varchar(5) null,
markerType 	varchar(5) null,
markerName 	varchar(255) null,
jnum 		varchar(25) null,
proposedSymbol	varchar(25) null,
approvDate	datetime null,
firstAuthor	varchar(50) null,
otherNames	varchar(255) null,
submitDate	datetime null,
correspondence	varchar(25) null,
completed	varchar(25) null,
citation	varchar(255) null,
authorSays	varchar(100) null,
note		text null,
oldSymbol	varchar(25) null,
humanSymbol	varchar(50) null,
categoryLetter	varchar(25) null,
unknownField	varchar(5) null,
nowField	varchar(10) null,
ECnumber	varchar(25) null,
status		varchar(25) null,
proposedName 	varchar(255) null,
pendingStatus	varchar(5) null,
corrDate1	datetime null,
corrDate2	datetime null,
corrDate3	datetime null,
corrDate4	datetime null,
corrCategory	varchar(100) null
)
go

checkpoint
go

quit
 
EOSQL
 
$scripts/dbo_sql $sql >> $LOG
rm $sql

cat $scripts/.mgd_dbo_password | bcp tempdb..NomenAll in nomenAll.bcp -c -t\\t -Umgd_dbo >> $LOG

cat > $sql << EOSQL
 
use $NOMEN
go
   
truncate table MRK_Status
go

truncate table MRK_Event
go

truncate table MRK_GeneFamily
go

truncate table MRK_Nomen
go

truncate table MRK_Nomen_Other
go

truncate table MRK_Nomen_Reference
go

truncate table MRK_Nomen_Notes
go

checkpoint
go

/* Clean up some things from the Nomen DB */

update tempdb..NomenAll 
set approvedSymbol = substring(approvedSymbol, 1, char_length(approvedSymbol) - 1)
where approvedSymbol like '%%'
go

update tempdb..NomenAll set approvedSymbol = proposedSymbol 
where approvedSymbol is null
go

update tempdb..NomenAll set markerType = "G" where markerType = "Gene"
go

update tempdb..NomenAll set markerType = "Q" where markerType = "QTL"
go

update tempdb..NomenAll set markerType = "D" where markerType is null and approvedSymbol like 'D[0-9]%'
go

update tempdb..NomenAll set markerType = "G" where markerType is null
go

update tempdb..NomenAll set status = "APPROVED" where status like "%APPROVED%"
go

update tempdb..NomenAll set status = "PENDING" where status like "%PENDING%"
go

update tempdb..NomenAll set nomenType = "c" where nomenType like "%c%"
go

update tempdb..NomenAll set nomenType = "n" where nomenType like "%n%"
go

update tempdb..NomenAll set nomenType = "p" where nomenType like "%p%"
go

update tempdb..NomenAll set nomenType = "w" where nomenType like "%w%"
go

update tempdb..NomenAll set jnum = "J:11593" where jnum = "J11593"
go

update tempdb..NomenAll set jnum = "J:1243" where jnum = "1243"
go

update tempdb..NomenAll set jnum = "J:1670" where jnum = "1670"
go

update tempdb..NomenAll set jnum = "J:1218" where jnum = " J:1218"
go

update tempdb..NomenAll set jnum = "J:18109" where jnum = "18109"
go

update tempdb..NomenAll set jnum = "J:20474" where jnum = "J20474"
go

update tempdb..NomenAll set jnum = "J:3100" where jnum = "J3100"
go

update tempdb..NomenAll set jnum = "J:37710" where jnum = "37710"
go

update tempdb..NomenAll set jnum = "J:48150" where jnum = "J48150"
go

update tempdb..NomenAll set jnum = null where jnum = "J:"
go

update tempdb..NomenAll set jnum = null where jnum = "jte"
go

update tempdb..NomenAll set jnum = null where jnum = " "
go

update tempdb..NomenAll set submitDate = "01/15/1994" where submitDate = "01/15/2004"
go

update tempdb..NomenAll set chromosome = "UN" where chromosome = " "
go

checkpoint
go

go

quit
 
EOSQL
 
$scripts/dbo_sql $sql >> $LOG
rm $sql

#
# Create bcp files
#
nomenBCP.py >> $LOG

#
# Load bcp files
#
cat $scripts/.mgd_dbo_password | bcp $NOMEN..MRK_Status in MRK_Status.bcp -c -t\| -Umgd_dbo >> $LOG
cat $scripts/.mgd_dbo_password | bcp $NOMEN..MRK_Event in MRK_Event.bcp -c -t\| -Umgd_dbo >> $LOG
cat $scripts/.mgd_dbo_password | bcp $NOMEN..MRK_GeneFamily in MRK_GeneFamily.bcp -c -t\| -Umgd_dbo >> $LOG
cat $scripts/.mgd_dbo_password | bcp $NOMEN..MRK_Nomen in MRK_Nomen.bcp -c -t\\t -Umgd_dbo >> $LOG
cat $scripts/.mgd_dbo_password | bcp $NOMEN..MRK_Nomen_Other in MRK_Nomen_Other.bcp -c -t\\t -Umgd_dbo >> $LOG
cat $scripts/.mgd_dbo_password | bcp $NOMEN..MRK_Nomen_Reference in MRK_Nomen_Reference.bcp -c -t\\t -Umgd_dbo >> $LOG
cat $scripts/.mgd_dbo_password | bcp $NOMEN..MRK_Nomen_Notes in MRK_Nomen_Notes.bcp -c -t\\t -Umgd_dbo >> $LOG

#
# Create indexes
#
$scripts/nomen/nomen_create_indices >> $LOG

set sql = /tmp/$$.sql
 
cat > $sql << EOSQL
 
use $MGD
go

/* Insert Missing Primary References */

select _Nomen_key, proposedSymbol, approvedSymbol
into #noref
from nomen..MRK_Nomen n 
where not exists (select r.* from nomen..MRK_Nomen_Reference r
where n._Nomen_key = r._Nomen_key and r.isPrimary = 1)
go

print ""
print "No Match in MGD"
print ""

select distinct r._Nomen_key, r.approvedSymbol
from #noref r
where not exists (select m.* from MRK_Marker m
where r.approvedSymbol = m.symbol
and m._Species_key = 1)
go

print ""
print "Withdrawn in MGD"
print ""

select distinct r._Nomen_key, r.approvedSymbol
from #noref r, MRK_Marker m
where r.approvedSymbol = m.symbol
and m._Species_key = 1
and m.chromosome = "W"
go

print ""
print "No History in MGD"
print ""

select distinct r._Nomen_key, r.approvedSymbol
from #noref r, MRK_Marker m
where r.approvedSymbol = m.symbol
and m._Species_key = 1
and m.chromosome != "W"
and not exists (select h.* from MRK_History h
where m._Marker_key = h._Marker_key)
go

print ""
print "Missing Reference in MGD"
print ""

select distinct r._Nomen_key, r.approvedSymbol
from #noref r, MRK_Marker m, MRK_History h
where r.approvedSymbol = m.symbol
and m._Species_key = 1
and m.chromosome != "W"
and m._Marker_key = h._Marker_key
and h._Refs_key is null
go

select distinct r._Nomen_key, r.approvedSymbol, h._Refs_key
into #primaryref
from #noref r, MRK_Marker m, MRK_History h
where r.approvedSymbol = m.symbol
and m._Species_key = 1
and m.chromosome != "W"
and m._Marker_key = h._Marker_key
and h._Refs_key is not null
and not exists (select nr.* from nomen..MRK_Nomen_Reference nr
where r._Nomen_key = nr._Nomen_key
and nr.isPrimary = 1)
go

select * 
into #addprimary
from #primaryref
group by _Nomen_key
having count(*) = 1
go

insert into nomen..MRK_Nomen_Reference
(_Nomen_key, _Refs_key, isPrimary)
select _Nomen_key, _Refs_key, 1
from #addprimary
go

checkpoint
go

/* Update BIB_Refs.dbs to include dataset Nomen */

declare ref_cursor cursor for
select distinct _Refs_key
from $NOMEN..MRK_Nomen_Reference
for read only
go

declare @refKey integer
declare @dbs varchar(60)

open ref_cursor
 
fetch ref_cursor into @refKey
  
while (@@sqlstatus = 0)
begin
 
	select @dbs = dbs
	from $MGD..BIB_Refs
	where _Refs_key = @refKey
 
	if (charindex("Nomen", @dbs) = 0)
	begin
        	if substring(@dbs, char_length(@dbs), char_length(@dbs)) = "/"
        	begin
                	select @dbs = @dbs + "Nomen/"
        	end
        	else
        	begin
                	select @dbs = @dbs + "/Nomen/"
        	end
        	update $MGD..BIB_Refs
        	set dbs = @dbs
        	from $MGD..BIB_Refs
        	where _Refs_key = @refKey
	end
 
	fetch ref_cursor into @refKey
end

close ref_cursor
deallocate cursor ref_cursor

print ""
print "Nomen References which are not selected for in Master Bib"
print ""

select r._Refs_key, b.dbs from nomen..MRK_Nomen_Reference r, BIB_Refs b
where r._Refs_key = b._Refs_key and b.dbs not like '%Nomen%'
go

checkpoint
go
 
dump tran $NOMEN with no_log
go

quit
 
EOSQL
 
$scripts/dbo_sql $sql >> $LOG
rm $sql

#
# Re-create triggers, stored procedures, views
#

$scripts/triggers/nomen/NOMEN.tr $DSQUERY $NOMEN $MGD >> $LOG
$scripts/procedures/nomen/procedures.sh $DSQUERY $NOMEN $MGD >> $LOG
$scripts/views/nomen/NOMEN.view $DSQUERY $NOMEN $MGD >> $LOG

date >> $LOG
