#!/bin/csh -f

#
# Migration for MGI 2.2/March 1999 Release
#

setenv DSQUERY $1
setenv MGD $2

setenv LOG `pwd`/MGI.log

rm -rf $LOG
touch $LOG
 
date >> $LOG
 
MappingText.sql $DSQUERY $MGD

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
 
/* This SP is obsolete and was replaced by MGI_resetSequenceNum in 7/28/1998 */

drop procedure GXD_resetSequenceNum
go

/* 
 * TR# 120
 *
 * Execute breakpoint split for all insertions, inversions, deletions
 * or duplications which have identified more than one breakpoint within
 * the same chromosome. 
 *
 * band1 & band2
 *
*/

/* As of 03/05/1999, no Insertions are eligible for this migration */

declare marker_cursor cursor for
select _Marker_key 
from MRK_Marker
where cytogeneticOffset like '%&%'
and symbol not like 'Is(%'
go

declare @markerKey integer

open marker_cursor
fetch marker_cursor into @markerKey

while (@@sqlstatus = 0)
begin
	execute MRK_breakpointSplit @markerKey
	fetch marker_cursor into @markerKey
end

close marker_cursor
deallocate cursor marker_cursor
go

/* End TR# 120 */

checkpoint
go

/* 
 * TR# 327
 *
 * Migrate TEXT Experiment Types to new TEXT Experiment Types
 *
*/

select e._Expt_key, type = "physical"
into #all
from MLD_Expts e, MLD_Expt_Notes n
where e.exptType = "TEXT"
and e._Expt_key = n._Expt_key
and (n.note like '%physical%' or n.note like '%overlapping%')
union
select e._Expt_key, type = "cyto"
from MLD_Expts e, MLD_Expt_Notes n
where e.exptType = "TEXT"
and e._Expt_key = n._Expt_key
and (n.note like '%somatic%' or n.note like '%fish%' or n.note like '%situ%')
union
select e._Expt_key, type = "qtl"
from MLD_Expts e, MLD_Expt_Notes n
where e.exptType = "TEXT"
and e._Expt_key = n._Expt_key
and (n.note like '%QTL%' or n.note like '%quantitative%')
union
select e._Expt_key, type = "cross"
from MLD_Expts e, MLD_Expt_Notes n
where e.exptType = "TEXT"
and e._Expt_key = n._Expt_key
and (n.note like '%cross%' or n.note like '%EUCIB%' or n.note like '%JAX%')
go

/* Select Experiments of type TEXT which belong to more than one category */

select distinct _Expt_key, type
into #exclude
from #all
group by _Expt_key
having count(*) > 1
go

/* Select all Experiments of type TEXT */

select _Expt_key
into #migrate
from MLD_Expts
where exptType = "TEXT"
go

/* Do not migrate Experiment Types for those which contain search terms from more than one categor */

delete #migrate
from #migrate m, #exclude e
where e._Expt_key = m._Expt_key
go

update MLD_Expts
set exptType = "TEXT-Physical Mapping"
from #migrate m, MLD_Expts e, MLD_Expt_Notes n
where m._Expt_key = e._Expt_key
and e._Expt_key = n._Expt_key
and (n.note like '%physical%' or n.note like '%overlapping%')
go

update MLD_Expts
set exptType = "TEXT-Cytogenetic Localization"
from #migrate m, MLD_Expts e, MLD_Expt_Notes n
where m._Expt_key = e._Expt_key
and e._Expt_key = n._Expt_key
and (n.note like '%somatic%' or n.note like '%fish%' or n.note like '%situ%')
go

update MLD_Expts
set exptType = "TEXT-QTL"
from #migrate m, MLD_Expts e, MLD_Expt_Notes n
where m._Expt_key = e._Expt_key
and e._Expt_key = n._Expt_key
and (n.note like '%QTL%' or n.note like '%quantitative%')
go

update MLD_Expts
set exptType = "TEXT-Genetic Cross"
from #migrate m, MLD_Expts e, MLD_Expt_Notes n
where m._Expt_key = e._Expt_key
and e._Expt_key = n._Expt_key
and (n.note like '%cross%' or n.note like '%EUCIB%' or n.note like '%JAX%')
go

/* End TR# 327 */

checkpoint
go

/* TR# 400 */
/* Update Modification dates for records which differ only in milliseconds */

select m.symbol, te.modification_date, tm.modification_date
from MLC_Text_Edit te, MLC_Text tm, MRK_Marker m
where te._Marker_key = tm._Marker_key 
and tm._Marker_key = m._Marker_key
and te.modification_date > tm.modification_date
and datediff(second, te.modification_date, tm.modification_date) = 0
go
            
update MLC_Text_Edit
set te.modification_date = tm.modification_date
from MLC_Text_edit te, MLC_Text tm
where te._Marker_key = tm._Marker_key
and te.modification_date > tm.modification_date
and datediff(second, te.modification_date, tm.modification_date) = 0
go

/* End TR# 400 */

checkpoint
go

/* TR# 130 */

/* Drop indexes on Accession tables */

drop index ACC_Accession.index_accID
go
 
drop index ACC_Accession.index_Object_key
go
 
drop index ACC_Accession.index_prefixPart
go
 
drop index ACC_Accession.index_MGIType_key
go
 
drop index ACC_Accession.index_numericPart
go
 
drop index ACC_Accession.index_Accession_key
go
 
drop index ACC_Accession.index_LogicalDB_key
go
 
drop index ACC_Accession.index_modification_date
go
 
drop index ACC_Accession.index_LogicalDB_MGI_Type_key
go
 
drop index ACC_AccessionReference.index_Refs_key
go
 
drop index ACC_AccessionReference.index_Acc_Refs_key
go
 
drop index ACC_AccessionReference.index_Accession_key
go
 
drop index ACC_AccessionReference.index_modification_date
go
 
checkpoint
go

quit
 
EOSQL
 
$scripts/dbo_sql $sql >> $LOG
rm $sql
 
#
# TR 130
#

tr130.py
cat $scripts/.mgd_dbo_password | bcp $MGD..ACC_Accession in ACC_Accession.bcp -c -t\| -Umgd_dbo >> $LOG
cat $scripts/.mgd_dbo_password | bcp $MGD..ACC_AccessionReference in ACC_AccessionReference.bcp -c -t\| -Umgd_dbo >> $LOG

set sql = /tmp/$$.sql
 
cat > $sql << EOSQL
 
use $MGD
go

/* TR# 130 */

/* Re-create indexes on Accession tables */

create unique clustered  index index_Accession_key on ACC_Accession (_Accession_key) 
with sorted_data on mgd_seg_0
go
 
create nonclustered  index index_Object_key on ACC_Accession (_Object_key) 
on mgd_seg_1
go
 
create nonclustered  index index_numericPart on ACC_Accession (numericPart) 
on mgd_seg_1
go
 
create nonclustered  index index_LogicalDB_key on ACC_Accession (_LogicalDB_key) 
on mgd_seg_1
go
 
create nonclustered  index index_MGIType_key on ACC_Accession (_MGIType_key) 
on mgd_seg_1
go
 
create nonclustered  index index_prefixPart on ACC_Accession (prefixPart) 
on mgd_seg_1
go
 
create nonclustered  index index_modification_date on ACC_Accession (modification_date) 
on mgd_seg_1
go
 
create nonclustered  index index_accID on ACC_Accession (accID) 
on mgd_seg_1
go
 
create nonclustered  index index_LogicalDB_MGI_Type_key on ACC_Accession (_LogicalDB_key, _MGIType_key)
on mgd_seg_1
go
 
create unique clustered  index index_Acc_Refs_key on ACC_AccessionReference (_Accession_key, _Refs_key)
on mgd_seg_1
go
 
create nonclustered  index index_Accession_key on ACC_AccessionReference (_Accession_key)
on mgd_seg_1
go
 
create nonclustered  index index_modification_date on ACC_AccessionReference (modification_date)
on mgd_seg_1
go
 
create nonclustered  index index_Refs_key on ACC_AccessionReference (_Refs_key)
on mgd_seg_1
go
 
checkpoint
go

quit
 
EOSQL
 
$scripts/dbo_sql $sql >> $LOG
rm $sql
 
$scripts/procedures/procedures.sh $DSQUERY $MGD
$scripts/views/views.sh $DSQUERY $MGD

date >> $LOG

