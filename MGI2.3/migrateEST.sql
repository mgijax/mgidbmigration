
/* R. Palazola */
/* 7/12/1999   */
/* SQL commands to handle the migration for EST consolidation.  */

/* sqsh -S MGD_DEV -L MGD=mgi_release -L blockSize=10000 -e \   */
/*      -a 2 -i migrateEST.sql |& tee logfile                      */

/****************************************************************************/
/*                                                                          */
/* run any pre-migration report select statments prior to this script!      */
/*                                                                          */
/****************************************************************************/

use $MGD
/*
set noexec on
set parseonly on
*/
go

select started=getdate() 
into tempdb..startMigration
go
select "Database=$MGD", "Server=" + @@servername, started 
from tempdb..startMigration
go

print ""
print "Remove all Putative relationships"
delete from PRB_Marker where relationship = 'P'
go


print ""
print "Change 'free-standing' ESTs to cDNAs"
go
update PRB_Probe
set DNAType = "cDNA"
where DNAType = "EST"
and derivedFrom is NULL
go

print ""
print "Remove all dbEST IDs for WashU ESTs:"
go

select "accum. time"=
       datediff ( ss, started, getdate() )
       from tempdb..startMigration
go

select _Accession_key
into #acckeys
from ACC_Accession a, PRB_Probe p
where _MGIType_key = 3
and _LogicalDB_key = 14  /* dbEST */
and a._Object_key = p._Probe_key
and p.DNAType = 'EST'
and p.name in ( 'WashU/HHMI Mouse EST', 'Withdrawn EST' )
go

declare acckey cursor
for select _Accession_key from #acckeys
for read only
go

open acckey
go

set nocount on
go

declare @key int, @cnt int, @total int, @cursorCnt int
select @cnt = 0, @total = 0
fetch acckey into @key
while ( @@sqlstatus = 0 )
BEGIN
    begin transaction
    delete from ACC_Accession where _Accession_key = @key
    if ( @@error = 0 )
      BEGIN
        commit transaction
        select @cnt = @cnt + 1
      END
    else
      BEGIN
        print "Delete dbEST Accession IDs failed at key %1!", @key
        rollback transaction
        return
      END

    fetch acckey into @key
    if ( @cnt = $blockSize or @@sqlstatus > 0)
      BEGIN
        select @total = @total + @cnt
        print "%1! dbEST accession IDs deleted (total %2!).", @cnt, @total
        select @cnt = 0
        dump transaction $MGD with no_log
      END
END
if @@sqlstatus = 1
    print "Cursor Failed"
print "TOTAL: %1! dbEST accession IDs deleted.", @total
go

select "accum. time"=
       datediff ( ss, started, getdate() )
       from tempdb..startMigration
go

close acckey
go
deallocate cursor acckey
go

drop table #acckeys
dump transaction $MGD with no_log
set nocount off
go

print ""
print "Get list of  WashU ESTs with multiple GenBank SIDs..."
select _Probe_key, derivedFrom, gbIDs=count(*),
       washUsid=min(_Accession_key)
into #extraSIDs
from PRB_Probe p, ACC_Accession a
where p._Probe_key = a._Object_key
and _LogicalDB_key = 9
and _MGIType_key = 3
and p.name = "WashU/HHMI mouse EST"
and p.DNAType = "EST"
group by derivedFrom, _Probe_key
having count(*) > 1
go

if 0 = (select count(*) from #extraSIDs)
BEGIN
  print "Failed to find expected Ed-added GenBank SIDs"
END
go

/* report which ones are not being locked */
print "Following ESTs' GenBank IDs appear to be added by curation:"
select "EST MGI ID"=a.accID, "GenBank ID"=g.accID
from #extraSIDs e, ACC_Accession a, ACC_Accession g
where e._Probe_key = a._Object_key
and a._MGIType_key = 3
and a.prefixPart = "MGI:"
and a.preferred = 1
and e._Probe_key = g._Object_key
and g._MGITYpe_key = 3
and g._LogicalDB_key = 9
and g._Accession_key != e.washUsid
order by derivedFrom, a.accID, g.accID
go

/* save these temp tables for acc-ref processing at end */


print ""
print "EST References"
go
select p._Probe_key, p.derivedFrom, r._Refs_key, r.hasSequence
into #estRef
from PRB_Probe p, PRB_Reference r
where p._Probe_key = r._Probe_key
and p.DNAType = "EST"
go


print ""
print "Set clones' hasSequence bit where the ESTs' value is 'true'"
go
update PRB_Reference
set hasSequence = 1
from PRB_Reference cR, #estRef e
where e.derivedFrom = cR._Probe_key
      and e._Refs_key = cR._Refs_key
      and e.hasSequence = 1 
      and cR.hasSequence = 0
go

print ""
print "Remove matching existing clone references"
go

delete #estRef
from #estRef e, PRB_Reference r
where e._Refs_key = r._Refs_key
and e.derivedFrom = r._Probe_key
go

print ""
print "Reassociate remaining EST references w/ the clone record"
go
update PRB_Reference 
set _Probe_key = e.derivedFrom
from #estRef e, PRB_Reference r
where e._Refs_key = r._Refs_key
and e._Probe_key = r._Probe_key
go

drop table #estRef
go

dump transaction $MGD with no_log
go

print ""
/* print "Remove all remaining EST Reference records" */
print "EST deletion will remove remaining EST Reference records"
go

/*
delete PRB_Reference 
from PRB_Reference pr, PRB_Probe p
where p._Probe_key = pr._Probe_key
and p.DNAType = "EST"
*/
go

dump transaction $MGD with no_log
go

print ""
print "Get list of withdrawn ESTs"
go
select est_key = _Probe_key, clone_key = derivedFrom
into #wdEST
from PRB_Probe
where DNAType = "EST"
and name = "Withdrawn EST"
go

print ""
print "Delete the withdrawn ESTs"
go
delete PRB_Probe
from PRB_Probe p, #wdEST wd 
where wd.est_key = p._Probe_key 
go

dump transaction $MGD with no_log
go


print ""
print "Are any of those clones associated with other probes?"
go
if exists (select 1 from #wdEST wd, PRB_Probe p
where p.derivedFrom = wd.clone_key )
  BEGIN
    select "Withdrawn Clone" = accID
    from ACC_Accession a, #wdEST wd, PRB_Probe p
    where a._Object_key = wd.clone_key
    and a._MGIType_key = 3 and a._LogicalDB_key = 1
    and p.derivedFrom = wd.clone_key

    delete #wdEST
    from ACC_Accession a, #wdEST wd, PRB_Probe p
    where a._Object_key = wd.clone_key
    and a._MGIType_key = 3 and a._LogicalDB_key = 1
    and p.derivedFrom = wd.clone_key
  END
else
    select "None"
go

print ""
print "Protect any withdrawn clones that have references attached"
go
delete #wdEST
from #wdEST w
where exists ( select 1 
from PRB_Reference r 
where w.clone_key = r._Probe_key
)
go

print ""
print "Delete the remaining 'orphaned' withdrawn clones"
go
delete PRB_Probe
from PRB_Probe p, #wdEST wd
where p._Probe_key = wd.clone_key
go

dump transaction $MGD with no_log
go


drop table #wdEST
go

print ""
print "Reassign EST Acc IDs to the parental clone:"
go

select "accum. time"=
       datediff ( ss, started, getdate() )
       from tempdb..startMigration
go

/* only the WashU ESTs should be left */
print "Reassign MGI:#s..."
go

select _Accession_key, p.derivedFrom, preferred, accID
into #mgiAccs
from ACC_Accession a, PRB_Probe p
where prefixPart = "MGI:"
and _MGIType_key = 3 
and _LogicalDB_key = 1
/* get em all: and preferred = 1 */
and _Object_key = _Probe_key
and p.DNAType = "EST"
go

/* report any non-preferred that will appear to mess up the count */

create unique index mgiAccIndex on #mgiAccs ( _Accession_key )
print  "Non-preferred MGI:#'s for ESTs"
select accID 
from #mgiAccs where preferred = 0
go

set nocount on

declare @minKey int, @maxKey int, @blockKey int, @total int,
@err int, @cnt int
select @minKey = min(_Accession_key),
       @maxKey = max(_Accession_key),
	   @total = 0
from #mgiAccs
while @minKey <= @maxKey
  BEGIN
    select @blockKey = @minKey + $blockSize - 1
    print  "Current block: %1! %2!", @minKey, @blockKey
    begin transaction
	update ACC_Accession 
	set _Object_key = derivedFrom, preferred = 0
	from ACC_Accession a, #mgiAccs m
	where a._Accession_key = m._Accession_key
    and m._Accession_key between @minKey and @blockKey

	select @err=@@error, @cnt = @@rowcount
	print "%1! rows affected", @cnt
    if ( @err != 0 )
      BEGIN
        rollback transaction
        return
      END
    else
	  BEGIN
	    select @total = @total + @cnt
        commit transaction
	  END

    select @minKey = @blockKey + 1
    dump transaction $MGD with no_log
  END
print "TOTAL: %1! MGI Accession IDs reassigned to clone", @total
go

select "accum. time"=
       datediff ( ss, started, getdate() )
       from tempdb..startMigration
set nocount off
go


drop table #mgiAccs
go

print "Reassign foreign accession IDs to clones..."
go

select _Accession_key, p.derivedFrom, a._LogicalDB_key
into #fAccs
from ACC_Accession a, PRB_Probe p
where _MGIType_key = 3 
and _LogicalDB_key > 1
and _Object_key = _Probe_key
and p.DNAType = "EST"
go 

create unique index fAccIndex on #fAccs (_Accession_key)
go

select _LogicalDB_key, count(*)
from #fAccs
group by _LogicalDB_key

set nocount on
go

declare @minKey int, @maxKey int, @blockKey int, @total int,
@err int, @cnt int
select @minKey = min(_Accession_key),
       @maxKey = max(_Accession_key),
	   @total = 0
from #fAccs
while @minKey <= @maxKey
  BEGIN
    select @blockKey = @minKey + $blockSize - 1
    print  "Current block: %1! %2!", @minKey, @blockKey
    begin transaction
	update ACC_Accession 
	set _Object_key = derivedFrom
	from ACC_Accession a, #fAccs f
	where a._Accession_key = f._Accession_key
    and f._Accession_key between @minKey and @blockKey

	select @err=@@error, @cnt=@@rowcount
	print "%1! rows affected", @cnt
    if ( @err != 0 )
      BEGIN
        rollback transaction
        return
      END
    else
	  BEGIN
	    select @total = @total + @cnt
        commit transaction
	  END

    select @minKey = @blockKey + 1
    dump transaction $MGD with no_log
  END
print "TOTAL: %1! foreign Accession IDs reassigned to clone", @total
go

select "accum. time"=
       datediff ( ss, started, getdate() )
       from tempdb..startMigration
go

drop table #fAccs
go

/* Could this leave any MGI:#'s still attached to ESTs? */
print ""
print "Accession IDs still associated with ESTs"
go
select accID, _LogicalDB_key, preferred
from ACC_Accession a, PRB_Probe p
where a._MGIType_key = 3
and a._Object_key = p._Probe_key
and p.DNAType = "EST"
go


dump transaction $MGD with no_log
go

set nocount off
go

print ""
print "Remove all Notes for ESTs"
go
delete PRB_Notes 
from PRB_Notes n, PRB_Probe p
where n._Probe_key = p._Probe_key
and p.DNAType = "EST"
go

dump transaction $MGD with no_log
go

dump transaction tempdb with no_log
go

print ""
print "Migrate EST relationships"
go

/* determine which Encodes relationships need to be promoted/created */
select pm._Probe_key, pm._Marker_key, relationship, p.derivedFrom
into #estRel
from PRB_Marker pm, PRB_Probe p
where p.DNAType = "EST"
and pm._Probe_key = p._Probe_key
go

print ""
print "Migrate Encodes relationships where clone has ANY other relationship"
go
update PRB_Marker
set relationship = 'E'
from PRB_Marker pm, #estRel e
where pm._Probe_key = e.derivedFrom
and pm._Marker_key = e._Marker_key
and e.relationship = 'E'
and ( pm.relationship is NULL or pm.relationship != 'E' )
go

print ""
print "Add Encodes relationships where clone has no relationship to the marker"
go
insert into PRB_Marker ( 
       _Probe_key, 
       _Marker_key, 
       relationship 
)
select derivedFrom, _Marker_key, relationship
from #estRel e
where relationship = 'E'
/* no existing relationship for the p-m pair */
and not exists ( select 1 
    from PRB_Marker cpm
    where cpm._Probe_key = e.derivedFrom
    and cpm._Marker_key = e._Marker_key
)
go
    
/* clean up the handled Encodes */
delete from #estRel
where relationship = 'E' 
print ""
print "EST non-Encodes relationships that were not migrated to clone."
go

select relationship, count(*)
from #estRel
group by relationship
go

drop table #estRel
dump transaction $MGD with no_log
go

dump transaction tempdb with no_log
go

print ""
print "Count of WashU IMAGE clones"
select count(distinct derivedFrom)
from PRB_Probe
where DNAType = "EST"	/* all remaining are WashU ESTs */

print ""
print "Remove all ESTs"
go
select "accum. time"=
       datediff ( ss, started, getdate() )
       from tempdb..startMigration
go

set nocount on
go

declare @minKey int, @maxKey int, @blockKey int, @total int,
@err int, @cnt int
select @minKey = min(_Probe_key),
       @maxKey = max(_Probe_key),
		  @total = 0
from PRB_Probe
while @minKey <= @maxKey
  BEGIN
    select @blockKey = @minKey + $blockSize - 1
    print  "Current block: %1! %2!", @minKey, @blockKey
    begin transaction
    delete from PRB_Probe
    where DNAType = "EST"
    and _Probe_key between @minKey and @blockKey

	select @err=@@error, @cnt=@@rowcount
	print "%1! rows affected", @cnt
    if ( @err != 0 )
      BEGIN
        rollback transaction
        return
      END
    else
	  BEGIN
	    select @total = @total + @cnt
        commit transaction
	  END

    select @minKey = @blockKey + 1
    dump transaction $MGD with no_log
  END
print "TOTAL: %1! EST records deleted", @total
go

select "accum. time"=
       datediff ( ss, started, getdate() )
       from tempdb..startMigration
set nocount off
go


/********************************************************************/

/* the following is for TR 611, a sub-project of 554/487.
   associate existing foreign accession IDs w/ internal WashU-dbEST 
   electronic load reference.
*/


select _Accession_key
into #accrefs
from ACC_Accession
where 1=2

select _Object_key, rowID = 0
into #clonelist
from ACC_Accession
where 1 = 2

set nocount off
go

declare @ref int
select @ref = _Object_key from ACC_Accession
where accID = "J:57656"

if ( @ref is null )
BEGIN
 print ""
 print "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
 print "!   Cannot locate a reference for WashU/dbEST electronic loads.   !"
 print "!   ACC_AccessionReference and PRB_Reference records NOT created! !"
 print "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
 print ""
END

else
BEGIN
  print "Adding Accession-References for EST foreign accession IDs..."
  select "accum. time"=
       datediff ( ss, started, getdate() )
       from tempdb..startMigration

  /* get the _Object_keys for WashU's IMAGE clones */
  /* note: we use WashU tags to insure we get only EST-loaded IMAGE clones */
  insert into #clonelist
  select distinct _Object_key, 0
  from ACC_Accession a, PRB_Probe p
  where _LogicalDB_key = 16
  and _MGIType_key = 3
  and _Object_key = _Probe_key
  and p.name = 'I.M.A.G.E. clone'

  /* get all the _Accession_key - _Object_key tuples for these clones */
  insert into #accrefs 
  select _Accession_key
  from ACC_Accession a, #clonelist p
  where _MGIType_key = 3                     /* Segment */
  and a._Object_key = p._Object_key
  and _LogicalDB_key in (9, 12, 16, 17)

  dump transaction tempdb with no_log

END
go

create unique index accrefs_index   on #accrefs (_Accession_key)
create unique index clonelist_index on #clonelist (_Object_key) 
go

/* there are some curator added GenBank IDs that should not be protected */
print ""
print "Remove GenBank Accession IDs that were added later by editors:"

/* these ESTs' clones have multiple GenBank IDs
   the min(_Accession_key) will be the original dbEST/WashU-loaded 
   GenBank ID:
*/

print "Get list of Editor-Added GenBank SIDs..."
select _Accession_key, clone=derivedFrom, gbSID = accID
into #edAdded
from #extraSIDs e, ACC_Accession a
where a._MGIType_key = 3
and a._LogicalDB_key = 9
and a._Object_key = e.derivedFrom  /* the clones not the ESTs */
and a._Accession_key != e.washUsid
go

/* report which ones are not being locked */
print "Following Clones' GenBank IDs appear to be added by curation and"
print "will NOT be protected by the dbEST Database Download reference:"
select "Clone MGI ID"=a.accID, gbSID
from #edAdded e, ACC_Accession a
where e.clone = a._Object_key
and a._MGIType_key = 3
and a.prefixPart = "MGI:"
and a.preferred = 0
order by clone, a.accID
go


/* remove the ed-Added GenBank IDs from the list of accRefs to be generated */
print "Remove editor curated GenBank accession IDs from AccessionReference."
delete #accrefs
from #accrefs ar, #edAdded ed
where ed._Accession_key = ar._Accession_key
print ""
go

drop table #edAdded
go

set nocount on
go

/* now generate acc-refs for these */

declare @ref int, @total int, @err int, @cnt int
select @total = 0, @ref = _Object_key 
from ACC_Accession
where accID = "J:57656"

if @ref is not null
BEGIN
  declare @minKey int, @maxKey int, @blockKey int
  select @minKey = min(_Accession_key),
         @maxKey = max(_Accession_key)
  from #accrefs

  while @minKey <= @maxKey
  BEGIN
    select @blockKey = @minKey + $blockSize - 1
    print  "Current block: %1! %2!", @minKey, @blockKey
    begin transaction

	insert into ACC_AccessionReference (_Accession_key, _Refs_key)
	select _Accession_key, @ref
	from #accrefs
	where _Accession_key between @minKey and @blockKey

	select @err=@@error, @cnt=@@rowcount
	print "%1! rows affected", @cnt
    if ( @err != 0 )
      BEGIN
        rollback transaction
        return
      END
    else
	  BEGIN
		select @total = @total + @cnt
        commit transaction
	  END

    select @minKey = @blockKey + 1
    dump transaction $MGD with no_log
  END
END
print "TOTAL: %1! AccessionReferences added.", @total
go

select "accum. time"=
   datediff ( ss, started, getdate() )
   from tempdb..startMigration
go

drop table #accrefs
go

/* prepare #clonelist for PRB_Reference records */

declare cloneref cursor
for select rowID from #clonelist
for update of rowID
go

open cloneref
go

declare @row int, @rowID int
select @row = max (_Reference_key) from PRB_Reference
fetch cloneref into @rowID
while ( @@sqlstatus = 0 )
  BEGIN
    select @row = @row + 1
    update #clonelist set rowID = @row
	where current of cloneref
	fetch cloneref into @rowID
  END
go

close cloneref
go

deallocate cursor cloneref
go

declare @ref int, @total int, @err int, @cnt int
select @total = 0, @ref = _Object_key 
from ACC_Accession
where accID = "J:57656"

if @ref is not null
BEGIN
  declare @minKey int, @maxKey int, @blockKey int
  select @minKey = min(_Object_key),
         @maxKey = max(_Object_key)
  from #clonelist

  while @minKey <= @maxKey
  BEGIN
    select @blockKey = @minKey + $blockSize - 1
    print  "Current block: %1! %2!", @minKey, @blockKey
    begin transaction

	insert into PRB_Reference (
		_Reference_key,
        _Probe_key,
        _Refs_key,
        holder,
        hasRmap,
        hasSequence
        )
    select rowID, 
        _Object_key,
        @ref,
        NULL,
        0,
        0
    from #clonelist
	where _Object_key between @minKey and @blockKey

	select @err = @@error, @cnt = @@rowcount
	print "%1! rows affected", @cnt
    if ( @err != 0 )
      BEGIN
        rollback transaction
        return
      END
    else
	  BEGIN
	    select @total = @total + @cnt
        commit transaction
	  END

    select @minKey = @blockKey + 1
    dump transaction $MGD with no_log
  END
END
print "TOTAL: %1! PRB_Reference records added.", @total
go

select "accum. time"=
    datediff ( ss, started, getdate() )
    from tempdb..startMigration
set nocount off
go

drop table #clonelist
go


/***********************************************************************/

/* Lori plans to create these records in production so the EI can 
   use the record keys; the checks for prior existence should prevent
   the records from being added where they already exist (UNLESS the
   name does not include "UniGene".
*/

LogicalActual:

/* add needed UniGene Logical/Actual DB records if not present */
print "Checking UniGene Logical and Actual DB"
go

declare @ldbkey int
select @ldbkey = _LogicalDB_key from ACC_LogicalDB where name like '%UniGene%'
if ( @ldbkey is null )
  BEGIN
    print "Adding UniGene Logical DB."
    select @ldbkey=max(_LogicalDB_key)+1 from ACC_LogicalDB
    insert into ACC_LogicalDB ( 
        _LogicalDB_key, 
        name,
        description, 
        _Species_key
        ) 
    values ( 
        @ldbkey, 
        "UniGene",
        "UniGene Mus musculus clustering resource",
        1
        )
  END
else
  print "UniGene Logical DB record already exists"

if not exists (select 1 from ACC_ActualDB where name like '%UniGene%')
  BEGIN
    print "Adding UniGene Actual DB."
    declare @adbkey int
    select @adbkey=max(_LogicalDB_key)+1 from ACC_ActualDB
    insert into ACC_ActualDB ( 
         _ActualDB_key, 
         _LogicalDB_key,
         name, 
         active,
         allowsMultiple,
         url 
         )
    values ( 
         @adbkey, 
         @ldbkey,
         "UniGene", 
         1,
         0,
         "http://www.ncbi.nlm.nih.gov/UniGene/clust.cgi?ORG=Mm&CID=@@@@"
         )
  END
else
  print "UniGene Actual DB record already exists"
go

print ""
print "REMINDER: update WI's ActualDB file for UniGene entry!!"
print ""
go

drop table tempdb..startMigration
go

/* 
set noexec off
set parseonly off
*/
go

/* END */
