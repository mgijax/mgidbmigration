#!/bin/csh -f

#
# Migration for PRB_Marker
#

cd `dirname $0` && source ./Configuration

setenv LOG $0.log
rm -rf $LOG
touch $LOG
 
date >> $LOG
echo "PRB_Marker Migration..." | tee -a $LOG
 
cat - <<EOSQL | doisql.csh $0 >> $LOG

use $DBNAME
go

sp_rename PRB_Marker, PRB_Marker_Old
go

end

EOSQL

#
# Use new schema product to create new table
#
${newmgddbschema}/table/PRB_Marker_create.object >> $LOG
${newmgddbschema}/default/PRB_Marker_bind.object >> $LOG

cat - <<EOSQL | doisql.csh $0 >> $LOG

use $DBNAME
go

select distinct r._Probe_key, r._Refs_key
into #probe
from PRB_Reference r, PRB_Marker_Old pm
where r._Probe_key = pm._Probe_key
go

create nonclustered index idx_probe on #probe(_Probe_key)
go

/* set of probes with single references */

select *
into #singleRefs
from #probe
group by _Probe_key having count(*) = 1
go

create nonclustered index idx_probe on #singleRefs(_Probe_key)
go

/* set of probes with multiple references */

select *
into #multipleRefs
from #probe
group by _Probe_key having count(*) > 1
go

create nonclustered index idx_probe on #multipleRefs(_Probe_key)
go

select _Probe_key, _Refs_key = min(_Refs_key) 
into #pickOneRef
from #multipleRefs
group by _Probe_key
go

/* set of probes with multiple references and single markers */

select distinct r.*, pm._Marker_key, pm.relationship
into #markers
from #pickOneRef r, PRB_Marker_Old pm
where r._Probe_key = pm._Probe_key
go

create nonclustered index idx_probe on #markers(_Probe_key)
go

select *
into #singleMarkers
from #markers
group by _Probe_key having count(*) = 1
go

create nonclustered index idx_probe on #singleMarkers(_Probe_key)
go

/* set of all multiple references with multiple markers */

select *
into #multMark1
from #markers
group by _Probe_key having count(*) > 1
go

create nonclustered index idx_probe on #multMark1(_Probe_key)
go

select *
into #multMark2
from #multMark1
group by _Probe_key, relationship having count(*) > 1
go

select *
into #multMark3
from #multMark1
group by _Probe_key, relationship having count(*) = 1
go

create nonclustered index idx_probe on #multMark2(_Probe_key)
go

create nonclustered index idx_probe on #multMark3(_Probe_key)
go

/* report all multiple references with multiple markers */

print ""
print "Molecular Segments with Multiple Markers and Multiple References"
print "(several types of relationship)"
print ""

select distinct a.accID
from PRB_Acc_View a, #multMark2 m
where m._Probe_key = a._Object_key
and a._LogicalDB_key = 1
and a.prefixPart = "MGI:"
and a.preferred = 1
order by a.numericPart
go

print ""
print "Molecular Segments with Multiple Markers and Multiple References"
print "(one type of relationship)"
print ""

select distinct a.accID
from PRB_Acc_View a, #multMark3 m
where m._Probe_key = a._Object_key
and a._LogicalDB_key = 1
and a.prefixPart = "MGI:"
and a.preferred = 1
order by a.numericPart
go

/* insert all prb_markers into new table */

/* those with single references */
insert into PRB_Marker
select pm._Probe_key, pm._Marker_key, s._Refs_key, pm.relationship,
${CREATEDBY}, ${CREATEDBY}, pm.creation_date, pm.modification_date
from PRB_Marker_Old pm, #singleRefs s
where pm._Probe_key = s._Probe_key
go

/* those with multiple references and single markers */
insert into PRB_Marker
select pm._Probe_key, pm._Marker_key, s._Refs_key, pm.relationship,
${CREATEDBY}, ${CREATEDBY}, pm.creation_date, pm.modification_date
from PRB_Marker_Old pm, #singleMarkers s
where pm._Probe_key = s._Probe_key
go


dump tran ${DBNAME} with truncate_only
go

checkpoint
go

quit

EOSQL

${newmgddbschema}/index/PRB_Marker_create.object >> $LOG

cat - <<EOSQL | doisql.csh $0 >> $LOG

use $DBNAME
go

drop table PRB_Marker_Old
go

end

EOSQL

date >> $LOG

