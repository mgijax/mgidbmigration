#!/bin/csh -f

#
# Migrate MGD3.3 Miscellaneous data
#

setenv DSQUERY $1
setenv MGD $2

set scripts = $SYBASE/admin

set sql = /tmp/$$.sql
 
date

cat > $sql << EOSQL
 
use master
go
 
sp_dboption $MGD, "select into", true
go
  
use $MGD
go
   
checkpoint
go
 
quit
 
EOSQL
 
$scripts/dbo_sql $sql
rm $sql

# Load BIB_ReviewStatus

cat $scripts/.mgd_dbo_password | bcp $MGD..BIB_ReviewStatus in data/BIB_ReviewStatus.bcp -c -t\| -Umgd_dbo

set sql = /tmp/$$.sql
 
cat > $sql << EOSQL

use $MGD
go

/* Probe updates */

exec sp_unbindrule 'PRB_Probe.DNAtype'
go
 
drop rule check_DNAtype
go
 
CREATE RULE check_DNAtype AS @col IN ('DNA (construct)', 'EST', 'RNA', 'cDNA', 'genomic', 'mitochondrial', 'oligo', 'primer', 'Not Specified')
go

update PRB_Probe set DNAtype = 'Not Specified' where DNAtype = 'unspecified'
go

exec sp_bindrule check_DNAtype, 'PRB_Probe.DNAtype'
go
 
/* _Vector_key of 5 must be re-assigned a value of -1 */

insert into PRB_Vector_Types values (-1, 'Not Specified', getdate(), getdate())
go

update PRB_Probe set _Vector_key = -1 where _Vector_key = 5
go

delete from PRB_Vector_Types where _Vector_key = 5
go

checkpoint
go

/* Reference updates */

update BIB_Refs
set _ReviewStatus_key = 1
where journal like 'Personal Comm%'
go

update BIB_Refs
set _ReviewStatus_key = 1
where journal like '%Database%'
go

update BIB_Refs
set _ReviewStatus_key = 1
where journal = 'Mouse News Lett'
go

update BIB_Refs
set _ReviewStatus_key = 1
where title like '%abstr%'
go

update BIB_Refs
set _ReviewStatus_key = 1
where title like 'Personal Comm%'
go

/* Miscellanous updates */

update ACC_ActualDB set name = 'I.M.A.G.E. home page' where _ActualDB_key = 25
go

update ACC_ActualDB set name = 'WashU home page' where _ActualDB_key = 24
go

update ACC_ActualDB set name = 'GenBank' where _ActualDB_key = 12
go

update ACC_ActualDB set name = 'GenBank (nid)' where _ActualDB_key = 16
go

update ACC_ActualDB set name = 'GenBank (pid)' where _ActualDB_key = 17
go

update ACC_ActualDB set _LogicalDB_key = 13 where _ActualDB_key = 20
go

update MRK_Species set name = 'cattle' where _Species_key = 11
go

update PRB_Source set species = 'cattle' where species = 'cow'
go

checkpoint
go

checkpoint
go

update GXD_Index set creation_date = modification_date
go

checkpoint
go

/* Add Non-Fatal Error Message */

sp_addmessage 99999, "Deletion of record failed"
go

sp_addmessage 88888, "Non-fatal error"
go

/* Remove obsolete stored procedures */

drop procedure ACC_fetch
go

drop procedure PRB_Parent
go

drop procedure procs
go

drop procedure rpctest
go

drop procedure MapAnchor
go

drop procedure Map1Marker
go

quit
 
EOSQL
 
$scripts/dbo_sql $sql
rm $sql

date
