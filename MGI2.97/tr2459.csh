#!/bin/csh -f

#
# Migration for TR 2459, 3711 (GXD Index Tables)
#

cd `dirname $0` && source ./Configuration

setenv LOG $0.log
rm -rf $LOG
touch $LOG
 
date >> $LOG
 
cat - <<EOSQL | doisql.csh $0 >> $LOG

use $DBNAME
go

sp_rename GXD_Index, GXD_Index_Old
go

sp_rename GXD_Index_Stages, GXD_Index_Stages_Old
go

end

EOSQL

#
# Use new schema product to create new table
#
${newmgddbschema}/table/GXD_Index_create.object >> $LOG
${newmgddbschema}/default/GXD_Index_bind.object >> $LOG
${newmgddbschema}/table/GXD_Index_Stages_create.object >> $LOG
${newmgddbschema}/default/GXD_Index_Stages_bind.object >> $LOG
${newmgddbschema}/view/VOC_Term_View_drop.object >> $LOG
${newmgddbschema}/view/VOC_Term_View_create.object >> $LOG

cat - <<EOSQL | doisql.csh $0 >> $LOG

use $DBNAME
go

/* initialize all to low priority */

declare @lowpriorityKey integer
select @lowpriorityKey = _Term_key 
from VOC_Term_View where vocabName = 'GXD Index Priority' and term = 'Low'

insert into GXD_Index
select g.index_id, g._Refs_key, g._Marker_key, @lowpriorityKey, g.comments, 
"${CREATEDBY}", "${CREATEDBY}", g.creation_date, g.modification_date
from GXD_Index_Old g, BIB_Refs r
where g._Refs_key = r._Refs_key
go

/* update to medium priority */

declare @medpriorityKey integer
select @medpriorityKey = _Term_key 
from VOC_Term_View where vocabName = 'GXD Index Priority' and term = 'Medium'

update GXD_Index
set _Priority_key = @medpriorityKey
from GXD_Index g, BIB_Refs r
where g._Refs_key = r._Refs_key
and r.journal in ("Development", "Dev Biol", "Mech Dev")
go

/* upgrade to high priority */

declare @highpriorityKey integer
select @highpriorityKey = _Term_key 
from VOC_Term_View where vocabName = 'GXD Index Priority' and term = 'High'

select distinct i._Refs_key
into #refs
from GXD_Index_Old i, GXD_Index_Stages_Old s, BIB_Refs b
where i._Refs_key = b._Refs_key
and b.journal in ("Development", "Dev Biol", "Mech Dev")
and (insitu_protein_section = 1
     or insitu_rna_section = 1
     or insitu_protein_mount = 1 
     or insitu_rna_mount = 1
     or rnase = 1 
     or nuclease = 1
     or primer_extension =1
     or northern = 1
     or western = 1
     or rt_pcr = 1
)
and not exists (select 1 from GXD_Assay a where i._Refs_key = a._Refs_key)

delete #refs
from #refs r, GXD_Index_Old i, GXD_Index_Stages_Old s
where r._Refs_key = i._Refs_key
and i.index_id = s.index_id
and s.stage_id between 40 and 41

update GXD_Index
set _Priority_key = @highpriorityKey
from #refs r, GXD_Index i
where r._Refs_key = i._Refs_key
go

/* Stages */

select stage_id = identity(5), t._Term_key
into #stages
from VOC_Term_View t
where vocabName = "GXD Index Stages"
order by sequenceNum
go

declare @assayKey integer
select @assayKey = _Term_key from VOC_Term where term = 'Prot-sxn'
insert into GXD_Index_Stages
select o.index_id, @assayKey, s._Term_key, "${CREATEDBY}", "${CREATEDBY}", o.creation_date, o.modification_date
from GXD_Index_Stages_Old o, #stages s
where o.insitu_protein_section = 1
and o.stage_id = s.stage_id - 1
go

declare @assayKey integer
select @assayKey = _Term_key from VOC_Term where term = 'RNA-sxn'
insert into GXD_Index_Stages
select o.index_id, @assayKey, s._Term_key, "${CREATEDBY}", "${CREATEDBY}", o.creation_date, o.modification_date
from GXD_Index_Stages_Old o, #stages s
where o.insitu_rna_section = 1
and o.stage_id = s.stage_id - 1
go

declare @assayKey integer
select @assayKey = _Term_key from VOC_Term where term = 'Prot-WM'
insert into GXD_Index_Stages
select o.index_id, @assayKey, s._Term_key, "${CREATEDBY}", "${CREATEDBY}", o.creation_date, o.modification_date
from GXD_Index_Stages_Old o, #stages s
where o.insitu_protein_mount = 1
and o.stage_id = s.stage_id - 1
go

declare @assayKey integer
select @assayKey = _Term_key from VOC_Term where term = 'RNA-WM'
insert into GXD_Index_Stages
select o.index_id, @assayKey, s._Term_key, "${CREATEDBY}", "${CREATEDBY}", o.creation_date, o.modification_date
from GXD_Index_Stages_Old o, #stages s
where o.insitu_rna_mount = 1
and o.stage_id = s.stage_id - 1
go

declare @assayKey integer
select @assayKey = _Term_key from VOC_Term where term = 'Northern'
insert into GXD_Index_Stages
select o.index_id, @assayKey, s._Term_key, "${CREATEDBY}", "${CREATEDBY}", o.creation_date, o.modification_date
from GXD_Index_Stages_Old o, #stages s
where o.northern = 1
and o.stage_id = s.stage_id - 1
go

declare @assayKey integer
select @assayKey = _Term_key from VOC_Term where term = 'Western'
insert into GXD_Index_Stages
select o.index_id, @assayKey, s._Term_key, "${CREATEDBY}", "${CREATEDBY}", o.creation_date, o.modification_date
from GXD_Index_Stages_Old o, #stages s
where o.western = 1
and o.stage_id = s.stage_id - 1
go

declare @assayKey integer
select @assayKey = _Term_key from VOC_Term where term = 'RT-PCR'
insert into GXD_Index_Stages
select o.index_id, @assayKey, s._Term_key, "${CREATEDBY}", "${CREATEDBY}", o.creation_date, o.modification_date
from GXD_Index_Stages_Old o, #stages s
where o.rt_pcr = 1
and o.stage_id = s.stage_id - 1
go

declare @assayKey integer
select @assayKey = _Term_key from VOC_Term where term = 'cDNA'
insert into GXD_Index_Stages
select o.index_id, @assayKey, s._Term_key, "${CREATEDBY}", "${CREATEDBY}", o.creation_date, o.modification_date
from GXD_Index_Stages_Old o, #stages s
where o.clones = 1
and o.stage_id = s.stage_id - 1
go

declare @assayKey integer
select @assayKey = _Term_key from VOC_Term where term = 'RNAse prot'
insert into GXD_Index_Stages
select o.index_id, @assayKey, s._Term_key, "${CREATEDBY}", "${CREATEDBY}", o.creation_date, o.modification_date
from GXD_Index_Stages_Old o, #stages s
where o.rnase = 1
and o.stage_id = s.stage_id - 1
go

declare @assayKey integer
select @assayKey = _Term_key from VOC_Term where term = 'S1 nuc'
insert into GXD_Index_Stages
select o.index_id, @assayKey, s._Term_key, "${CREATEDBY}", "${CREATEDBY}", o.creation_date, o.modification_date
from GXD_Index_Stages_Old o, #stages s
where o.nuclease = 1
and o.stage_id = s.stage_id - 1
go

declare @assayKey integer
select @assayKey = _Term_key from VOC_Term where term = 'Primer ex'
insert into GXD_Index_Stages
select o.index_id, @assayKey, s._Term_key, "${CREATEDBY}", "${CREATEDBY}", o.creation_date, o.modification_date
from GXD_Index_Stages_Old o, #stages s
where o.primer_extension = 1
and o.stage_id = s.stage_id - 1
go

checkpoint
go

quit

EOSQL

${newmgddbschema}/index/GXD_Index_create.object >> $LOG
${newmgddbschema}/index/GXD_Index_Stages_create.object >> $LOG

#cat - <<EOSQL | doisql.csh $0 >> $LOG
#
#use $DBNAME
#go
#
#drop table GXD_Index_Old
#go
#
#drop table GXD_Index_Stages_Old
#go
#
#end
#
#EOSQL

date >> $LOG

