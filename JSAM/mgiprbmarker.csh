#!/bin/csh -f

#
# Migration for PRB_Marker
#
# 12/02/2003
#	- addressed migrating mult ref w/ mult markers
#	- our strategy is to use other marker/reference relationships by
#	- building a marker/reference cache
#	- and by checking RFLP/GXD relationships as well
#	- 11 records remain where the probe has no reference
#
# 11/20/2003
#	- sent Richard email
#	- we need to address how to migrate multiple references w/ multiple markers
#

cd `dirname $0` && source ./Configuration

setenv LOG $0.log
rm -rf ${LOG}
touch ${LOG}
 
date >> ${LOG}
echo "PRB_Marker Migration..." | tee -a ${LOG}
 
cat - <<EOSQL | doisql.csh $0 >> ${LOG}

use ${DBNAME}
go

sp_rename PRB_Marker, PRB_Marker_Old
go

end

EOSQL

#
# Use new schema product to create new table
#
${newmgddbschema}/table/PRB_Marker_create.object >> ${LOG}
${newmgddbschema}/default/PRB_Marker_bind.object >> ${LOG}
${oldmgddbschema}/index/MRK_Reference_drop.object >> ${LOG}
${newmgddbschema}/index/MRK_Reference_create.object >> ${LOG}

cat - <<EOSQL | doisql.csh $0 >> ${LOG}

use ${DBNAME}
go

dump tran ${DBNAME} with truncate_only
go

update statistics PRB_Marker_Old
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

/* create a marker/reference cache table */

use tempdb
go

drop table MRK_RefNoAuto
go

drop table MRK_RefNew
go

use ${DBNAME}
go

select distinct _Marker_key, _Refs_key into tempdb..MRK_RefNoAuto
from MRK_Reference (index idx_auto)
where auto = 0 and _Refs_key is not null
go
 
create nonclustered index idx_Marker_key on tempdb..MRK_RefNoAuto(_Marker_key)
go

create nonclustered index idx_Refs_key on tempdb..MRK_RefNoAuto(_Refs_key)
go

create nonclustered index idx_Marker_Refs_key on tempdb..MRK_RefNoAuto(_Marker_key, _Refs_key)
go

select distinct m._Marker_key, h._Refs_key 
into tempdb..MRK_RefNew 
from MRK_Marker m, HMD_Homology_Marker hm, HMD_Homology h (index index_Homology_key) 
where m._Organism_key = 1 and m._Marker_key = hm._Marker_key and hm._Homology_key = h._Homology_key 
union
select distinct _Marker_key, _Refs_key 
from MRK_History (index idx_Marker_key) 
where _Refs_key is not null 
union
select distinct _Marker_key, _Refs_key 
from MLD_Marker (index idx_Marker_key) 
union
select distinct _Marker_key, _Refs_key 
from GXD_Index (index idx_Marker_key) 
union
select distinct _Marker_key, _Refs_key 
from GXD_Assay (index idx_Marker_key) 
union
select distinct _Marker_key, _Refs_key 
from MRK_Other (index index_Marker_key) 
where _Refs_key is not null 
union
select distinct a._Object_key, ar._Refs_key 
from MRK_Marker m (index idx_Marker_key), ACC_Accession a, ACC_AccessionReference ar 
where m._Organism_key = 1 and m._Marker_key = a._Object_key 
and a._MGIType_key = 2 and a.private = 0 and a._Accession_key = ar._Accession_key 
union
select distinct a._Marker_key, r._Refs_key 
from ALL_Allele a (index idx_Marker_key), ALL_Reference r 
where a._Marker_key is not null and a._Allele_key = r._Allele_key 
union
select distinct a._Object_key, r._Refs_key 
from VOC_Annot a (index index_Object_key), VOC_Evidence r 
where a._AnnotType_key = 1000 and a._Annot_key = r._Annot_key 
union
select distinct _Marker_key, _Refs_key 
from tempdb..MRK_RefNoAuto r (index idx_Marker_Refs_key) 
go

create nonclustered index idx_Marker_key on tempdb..MRK_RefNew(_Marker_key)
go

create nonclustered index idx_Refs_key on tempdb..MRK_RefNew(_Refs_key)
go

create nonclustered index idx_Marker_Refs_key on tempdb..MRK_RefNew(_Marker_key, _Refs_key)
go

/* set of all multiple references with multiple markers */

select distinct _Marker_key, _Probe_key
into #multMark1
from #markers
group by _Probe_key having count(*) > 1
go

create nonclustered index idx_probe on #multMark1(_Probe_key)
go

/* select all multiple markers/multiple references where the marker/reference is in the cache table */
/* note that #multMark1 already contains the min reference key */

select m.*, r._Refs_key
into #multMark2
from #multMark1 m, PRB_Reference pr, tempdb..MRK_RefNew r
where m._Probe_key = pr._Probe_key
and m._Marker_key = r._Marker_key
and pr._Refs_key = r._Refs_key
go

create nonclustered index idx_probe on #multMark2(_Probe_key)
go

create nonclustered index idx_marker on #multMark2(_Marker_key)
go

select m._Marker_key, m._Probe_key, _Refs_key = min(m._Refs_key)
into #multMark3
from #multMark2 m
group by _Probe_key, _Marker_key
go

/* select all multiple markers/multiple references where the marker/reference is not in multMark2 */

select distinct m.*
into #multMark4
from #multMark1 m, PRB_Reference pr
where m._Probe_key = pr._Probe_key
and not exists (select 1 from #multMark2 m2
where m._Probe_key = m2._Probe_key
and m._Marker_key = m2._Marker_key)
go

/* for those that have RFLP or GXD information, choose the earliest reference */

select distinct m.*, _Refs_key = min(pr._Refs_key)
into #multMark5
from #multMark4 m, PRB_Reference pr, PRB_RFLV v
where m._Probe_key = pr._Probe_key
and pr._Reference_key = v._Reference_key
and m._Marker_key = v._Marker_key
group by m._Probe_key, m._Marker_key
union
select distinct m.*, _Refs_key = min(a._Refs_key)
from #multMark4 m, GXD_ProbePrep p, GXD_Assay a
where m._Probe_key = p._Probe_key
and p._ProbePrep_key = a._ProbePrep_key
and m._Marker_key = a._Marker_key
group by m._Probe_key, m._Marker_key
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

/* those with multiple references and multiple markers */
insert into PRB_Marker
select distinct pm._Probe_key, pm._Marker_key, s._Refs_key, pm.relationship,
${CREATEDBY}, ${CREATEDBY}, pm.creation_date, pm.modification_date
from PRB_Marker_Old pm, #multMark3 s
where pm._Probe_key = s._Probe_key
and pm._Marker_key = s._Marker_key
go

/* those with multiple references and multiple markers */
/* where the probe/marker has RFLP information or GXD information */

insert into PRB_Marker
select distinct pm._Probe_key, pm._Marker_key, s._Refs_key, pm.relationship,
${CREATEDBY}, ${CREATEDBY}, pm.creation_date, pm.modification_date
from PRB_Marker_Old pm, #multMark5 s
where pm._Probe_key = s._Probe_key
and pm._Marker_key = s._Marker_key
go

/* those which still could not be migrated */
/* if RIKEN, use max(_Refs_key), else use min(_Refs_key) */

select distinct pm._Probe_key, pm._Marker_key, _Refs_key = max(r._Refs_key)
into #leftovers
from PRB_Marker_Old pm, MRK_Marker m, PRB_Probe p, PRB_Reference r
where p.name like 'RIKEN%'
and not exists (select 1 from PRB_Marker pmnew
where pm._Marker_key = pmnew._Marker_key
and pm._Probe_key = pmnew._Probe_key)
and pm._Marker_key = m._Marker_key
and pm._Probe_key = p._Probe_key
and p._Probe_key = r._Probe_key
group by pm._Probe_key, pm._Marker_key
union
select distinct pm._Probe_key, pm._Marker_key, _Refs_key = min(r._Refs_key)
from PRB_Marker_Old pm, MRK_Marker m, PRB_Probe p, PRB_Reference r
where p.name not like 'RIKEN%'
and not exists (select 1 from PRB_Marker pmnew
where pm._Marker_key = pmnew._Marker_key
and pm._Probe_key = pmnew._Probe_key)
and pm._Marker_key = m._Marker_key
and pm._Probe_key = p._Probe_key
and p._Probe_key = r._Probe_key
group by pm._Probe_key, pm._Marker_key
go

insert into PRB_Marker
select distinct pm._Probe_key, pm._Marker_key, s._Refs_key, pm.relationship,
${CREATEDBY}, ${CREATEDBY}, pm.creation_date, pm.modification_date
from PRB_Marker_Old pm, #leftovers s
where pm._Probe_key = s._Probe_key
and pm._Marker_key = s._Marker_key
go

/* print all prb_marker records which still cannot be migrated */

select distinct p.name, m.symbol, pm.relationship
from PRB_Marker_Old pm, MRK_Marker m, PRB_Probe p
where not exists (select 1 from PRB_Marker pmnew
where pm._Marker_key = pmnew._Marker_key
and pm._Probe_key = pmnew._Probe_key)
and pm._Marker_key = m._Marker_key
and pm._Probe_key = p._Probe_key
order by m.symbol
go

dump tran ${DBNAME} with truncate_only
go

checkpoint
go

quit

EOSQL

${newmgddbschema}/index/PRB_Marker_create.object >> ${LOG}

cat - <<EOSQL | doisql.csh $0 >> ${LOG}

use ${DBNAME}
go

drop table PRB_Marker_Old
go

use tempdb
go

drop table MRK_RefNoAuto
go

drop table MRK_RefNew
go

end

EOSQL

date >> ${LOG}

