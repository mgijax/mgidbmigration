#!/bin/csh -f

#
# Migration for PRB_Source (add _Vector_key)
#

cd `dirname $0` && source ./Configuration

setenv LOG $0.log
rm -rf $LOG
touch $LOG
 
date | tee -a $LOG
 
cat - <<EOSQL | doisql.csh $0 | tee -a $LOG

use $DBNAME
go

sp_rename PRB_Source, PRB_Source_Old
go

end

EOSQL

#
# Use new schema product to create new table
#
${newmgddbschema}/table/PRB_Source_create.object | tee -a $LOG
${newmgddbschema}/default/PRB_Source_bind.object | tee -a $LOG

cat - <<EOSQL | doisql.csh $0 | tee -a $LOG

use $DBNAME
go

declare @vectorKey int
select @vectorKey = _Vector_key from PRB_Vector_Types where vectorType = "Not Specified"
declare @segmentTypeKey int
select @segmentTypeKey = t._Term_key 
from VOC_Vocab v, VOC_Term t
where v.name = 'Segment Type'
and v._Vocab_key = t._Vocab_key
and t.term = "Not Specified"

insert into PRB_Source
select _Source_key, @segmentTypeKey, @vectorKey, _ProbeSpecies_key,
_Strain_key, _Tissue_key, _Refs_key, name, description,
age, ageMin, ageMax, sex, cellLine, creation_date, modification_date
from PRB_Source_Old
go

/* select all named sources */

select _Source_key, name 
into #source 
from PRB_Source 
where name is not null
go

create nonclustered index idx_source_key on #source (_Source_key)
go

/* select all unique source/vector pairs where the probe is not a child probe */

select distinct p._Vector_key, p._Source_key, name = substring(s.name, 1, 50)
into #a
from PRB_Probe p, #source s
where s._Source_key = p._Source_key
and p._Vector_key > 0
and p.derivedFrom = null
go

/* select those sources that have no conflicting vector types */

select * 
into #ok1
from #a
group by _Source_key
having count(*) = 1
go

/* update the source record with its default vector type */

update PRB_Source
set _Vector_key = o._Vector_key
from PRB_Source s, #ok1 o
where s._Source_key = o._Source_key
go

/* select all unique source/segment type pairs where the probe is not a child probe */

select distinct t._Term_key, p.DNAType, p._Source_key, name = substring(s.name, 1, 50)
into #b
from PRB_Probe p, #source s, VOC_Vocab v, VOC_Term t
where s._Source_key = p._Source_key
and p.derivedFrom = null
and p.DNAType = t.term
and t._Vocab_key = v._Vocab_key
and v.name = 'Segment Type'
go

/* select those sources that have no conflicting segment types */

select * 
into #ok2
from #b
group by _Source_key
having count(*) = 1
go

/* update the source record with its default segment type */

update PRB_Source
set _SegmentType_key = o._Term_key
from PRB_Source s, #ok2 o
where s._Source_key = o._Source_key
go

checkpoint
go

quit

EOSQL

${newmgddbschema}/index/PRB_Source_create.object | tee -a $LOG

date | tee -a $LOG

