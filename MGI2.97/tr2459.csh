#!/bin/csh -f

#
# Migration for TR 2459, 3711 (GXD Index Tables)
#

cd `dirname $0` && source ./Configuration

setenv LOG $0.log
rm -rf $LOG
touch $LOG
 
date | tee -a $LOG
 
cat - <<EOSQL | doisql.csh $0 | tee -a $LOG

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
${newmgddbschema}/table/GXD_Index_create.object | tee -a $LOG
${newmgddbschema}/default/GXD_Index_bind.object | tee -a $LOG
${newmgddbschema}/table/GXD_Index_Stages_create.object | tee -a $LOG
${newmgddbschema}/default/GXD_Index_Stages_bind.object | tee -a $LOG
${newmgddbschema}/view/VOC_Term_View_drop.object | tee -a $LOG
${newmgddbschema}/view/VOC_Term_View_create.object | tee -a $LOG

cat - <<EOSQL | doisql.csh $0 | tee -a $LOG

use $DBNAME
go

/* initialize all to low priority */

declare @lowpriorityKey integer
select @lowpriorityKey = _Term_key 
from VOC_Term_View where vocabName = 'GXD Index Priority' and term = 'Low'

insert into GXD_Index
select i.index_id, i._Refs_key, i._Marker_key, @lowpriorityKey, i.comments, 
"${CREATEDBY}", "${CREATEDBY}", i.creation_date, i.modification_date
from GXD_Index_Old i, BIB_Refs r
where i._Refs_key = r._Refs_key
go

/* retrieve references not fully coded */

select distinct i._Refs_key
into #notcoded
from GXD_Index i
where not exists (select 1 from GXD_Assay a where i._Refs_key = a._Refs_key)
go

/* upgrade to medium priority */
/* all high priority journals */

declare @medpriorityKey integer
select @medpriorityKey = _Term_key 
from VOC_Term_View where vocabName = 'GXD Index Priority' and term = 'Medium'

update GXD_Index
set _Priority_key = @medpriorityKey
from #notcoded n, GXD_Index i, BIB_Refs r
where n._Refs_key = i._Refs_key
and i._Refs_key = r._Refs_key
and r.journal in ('Development', 'Dev Biol', 'Dev Dyn', 'Gene Expr Patterns', 'Genes Devel', 'Mech Dev', 'Nature', 'Nat Genet')
go

/* upgrade to high priority */

declare @highpriorityKey integer
select @highpriorityKey = _Term_key 
from VOC_Term_View where vocabName = 'GXD Index Priority' and term = 'High'

/* all papers with blot only */

update GXD_Index
set _Priority_key = @highpriorityKey
from #notcoded n, GXD_Index i
where n._Refs_key = i._Refs_key
and exists (select 1 from GXD_Index_Stages_Old s
where i._Index_key = s.index_id
and (s.northern = 1 or s.western = 1 or s.nuclease = 1 or s.rnase = 1 or s.rt_pcr = 1 or s.primer_extension = 1))
and not exists (select 1 from GXD_Index_Stages_Old s
where i._Index_key = s.index_id
and (s.insitu_protein_section = 1
or s.insitu_rna_section = 1
or s.insitu_protein_mount = 1
or s.insitu_rna_mount = 1
or s.stage_id = 40))
go

/* all papers with high priority journals... */

select distinct i._Refs_key
into #refs
from #notcoded n, GXD_Index_Old i, GXD_Index_Stages_Old s, BIB_Refs b
where n._Refs_key = i._Refs_key
and i._Refs_key = b._Refs_key
and b.journal in ('Development', 'Dev Biol', 'Dev Dyn', 'Gene Expr Patterns', 'Genes Devel', 'Mech Dev', 'Nature', 'Nat Genet')
and (s.insitu_protein_section = 1
     or s.insitu_rna_section = 1
     or s.insitu_protein_mount = 1 
     or s.insitu_rna_mount = 1
     or s.primer_extension = 1
     or s.northern = 1 
     or s.western = 1 
     or s.nuclease = 1 
     or s.rnase = 1 
     or s.rt_pcr = 1
     or s.clones = 1
)
go

/* exclude: */
/*    blots with E? */
/*    in situs with E? or A */

select distinct i._Refs_key
into #todelete
from #refs r, GXD_Index i, GXD_Index_Stages_Old s
where r._Refs_key = i._Refs_key
and i._Index_key = s.index_id
and s.stage_id = 40
and s.northern = 1
union
select distinct i._Refs_key
from #refs r, GXD_Index i, GXD_Index_Stages_Old s
where r._Refs_key = i._Refs_key
and i._Index_key = s.index_id
and s.stage_id = 40
and s.western = 1
union
select distinct i._Refs_key
from #refs r, GXD_Index i, GXD_Index_Stages_Old s
where r._Refs_key = i._Refs_key
and i._Index_key = s.index_id
and s.stage_id = 40
and s.rt_pcr = 1
union
select distinct i._Refs_key
from #refs r, GXD_Index i, GXD_Index_Stages_Old s
where r._Refs_key = i._Refs_key
and i._Index_key = s.index_id
and s.stage_id = 40
and s.rnase = 1
union
select distinct i._Refs_key
from #refs r, GXD_Index i, GXD_Index_Stages_Old s
where r._Refs_key = i._Refs_key
and i._Index_key = s.index_id
and s.stage_id in (40, 41)
and s.insitu_protein_section = 1
union
select distinct i._Refs_key
from #refs r, GXD_Index i, GXD_Index_Stages_Old s
where r._Refs_key = i._Refs_key
and i._Index_key = s.index_id
and s.stage_id in (40, 41)
and s.insitu_rna_section = 1
union
select distinct i._Refs_key
from #refs r, GXD_Index i, GXD_Index_Stages_Old s
where r._Refs_key = i._Refs_key
and i._Index_key = s.index_id
and s.stage_id in (40, 41)
and s.insitu_protein_mount = 1
union
select distinct i._Refs_key
from #refs r, GXD_Index i, GXD_Index_Stages_Old s
where r._Refs_key = i._Refs_key
and i._Index_key = s.index_id
and s.stage_id in (40, 41)
and s.insitu_rna_mount = 1
go

delete #refs
from #refs r, #todelete d
where d._Refs_key = r._Refs_key
go

declare @highpriorityKey integer
select @highpriorityKey = _Term_key 
from VOC_Term_View where vocabName = 'GXD Index Priority' and term = 'High'

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

${newmgddbschema}/index/GXD_Index_create.object | tee -a $LOG
${newmgddbschema}/index/GXD_Index_Stages_create.object | tee -a $LOG

date | tee -a $LOG

