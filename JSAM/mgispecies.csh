#!/bin/csh -f

#
# Migration for MGI Organism
#

cd `dirname $0` && source ./Configuration

setenv LOG $0.log
rm -rf $LOG
touch $LOG
 
date >> $LOG
echo "MGI Organism Migration..." | tee -a $LOG
 
cat - <<EOSQL | doisql.csh $0 >> $LOG

use $DBNAME
go

sp_rename ACC_LogicalDB, ACC_LogicalDB_Old
go

sp_rename GXD_Antibody, GXD_Antibody_Old
go

sp_rename MRK_Chromosome, MRK_Chromosome_Old
go

sp_rename MRK_Label, MRK_Label_Old
go

sp_rename PRB_Source, PRB_Source_Old
go

drop procedure ACC_insert_bySpecies
go

dump tran ${DBNAME} with truncate_only
go

end

EOSQL

#
# Use new schema product to create new tables
#
${newmgddbschema}/table/MGI_Organism_create.object >> $LOG
${newmgddbschema}/default/MGI_Organism_bind.object >> $LOG
${newmgddbschema}/table/MGI_Organism_MGIType_create.object >> $LOG
${newmgddbschema}/default/MGI_Organism_MGIType_bind.object >> $LOG

${newmgddbschema}/table/ACC_LogicalDB_create.object >> $LOG
${newmgddbschema}/default/ACC_LogicalDB_bind.object >> $LOG
${newmgddbschema}/table/GXD_Antibody_create.object >> $LOG
${newmgddbschema}/default/GXD_Antibody_bind.object >> $LOG
${newmgddbschema}/table/MRK_Chromosome_create.object >> $LOG
${newmgddbschema}/default/MRK_Chromosome_bind.object >> $LOG
${newmgddbschema}/table/MRK_Label_create.object >> $LOG
${newmgddbschema}/default/MRK_Label_bind.object >> $LOG
${newmgddbschema}/table/PRB_Source_create.object >> $LOG
${newmgddbschema}/default/ageminmax_default_create.object >> $LOG
${newmgddbschema}/default/PRB_Source_bind.object >> $LOG

cat - <<EOSQL | doisql.csh $0 >> $LOG

use $DBNAME
go

insert into MGI_Organism
select _Species_key, name, species, ${CREATEDBY}, ${CREATEDBY}, creation_date, modification_date
from MRK_Species
go

dump tran ${DBNAME} with truncate_only
go

/* insert Marker Organism list into MGI_Organism_MGIType */
insert into MGI_Organism_MGIType
select _Organism_key, 2, ${CREATEDBY}, ${CREATEDBY}, getdate(), getdate()
from MGI_Organism
go

dump tran ${DBNAME} with truncate_only
go

/* insert Orthology Organism list into MGI_Organism_MGIType */
insert into MGI_Organism_MGIType
select _Organism_key, 18, ${CREATEDBY}, ${CREATEDBY}, getdate(), getdate()
from MGI_Organism
go

dump tran ${DBNAME} with truncate_only
go

/* insert Organism list for Sequences into MGI_Organism_MGIType (mouse, human, rat) */
insert into MGI_Organism_MGIType
select _Organism_key, 19, ${CREATEDBY}, ${CREATEDBY}, getdate(), getdate()
from MGI_Organism
where _Organism_key in (1,2,40)
go

dump tran ${DBNAME} with truncate_only
go

/* grab all species from other species tables */

select p.species, seq = identity(5)
into #species
from PRB_Species p
where not exists (select 1 from MGI_Organism s where p.species = s.commonName)
union
select p.antibodySpecies, seq = identity(5)
from GXD_AntibodySpecies p
where not exists (select 1 from MGI_Organism s where p.antibodySpecies = s.commonName)
go

dump tran ${DBNAME} with truncate_only
go

/* insert the rest of the species into MGI_Organism */

declare @maxKey integer
select @maxKey = max(_Organism_key) from MGI_Organism
insert into MGI_Organism
select seq + @maxKey, s.species, "Not Specified", ${CREATEDBY}, ${CREATEDBY}, getdate(), getdate()
from #species s
go

/* insert Molecular Segment species list into MGI_Organism_MGIType */
insert into MGI_Organism_MGIType
select distinct s._Organism_key, 3, ${CREATEDBY}, ${CREATEDBY}, getdate(), getdate()
from PRB_Species p, MGI_Organism s
where p.species = s.commonName
go

/* insert Antigen species list into MGI_Organism_MGIType */
insert into MGI_Organism_MGIType
select distinct s._Organism_key, 7, ${CREATEDBY}, ${CREATEDBY}, getdate(), getdate()
from PRB_Species p, MGI_Organism s
where p.species = s.commonName
go

/* insert Antibody species list into MGI_Organism_MGIType */
insert into MGI_Organism_MGIType
select distinct s._Organism_key, 6, ${CREATEDBY}, ${CREATEDBY}, getdate(), getdate()
from GXD_AntibodySpecies p, MGI_Organism s
where p.antibodySpecies = s.commonName
go

dump tran ${DBNAME} with truncate_only
go

/* now map PRB_Source_Old._ProbeSpecies_key to MGI_Organism._Organism_key */

update PRB_Source_Old
set cellLine = 'Not Specified'
where cellLine is null
go

update PRB_Source_Old
set ageMin = -1.0, ageMax = -1.0
where ageMin is null
go

declare @notSpecifiedCuratorKey integer
select @notSpecifiedCuratorKey = _User_key
from MGI_User u, VOC_Term t
where u.login = "not specified"
and u._UserType_key = t._Term_key
and t.term = "Curator"

insert into PRB_Source
select p._Source_key, p._SegmentType_key, t3._Term_key, s._Organism_key,
p._Strain_key, p._Tissue_key, t1._Term_key, t2._Term_key, p._Refs_key, p.name, p.description,
p.age, p.ageMin, p.ageMax, 1,
@notSpecifiedCuratorKey, @notSpecifiedCuratorKey, p.creation_date, p.modification_date
from PRB_Source_Old p, PRB_Species op, MGI_Organism s, 
VOC_Term t1, VOC_Vocab v1, VOC_Term t2, VOC_Vocab v2, VOC_Term t3, VOC_Vocab v3, PRB_Vector_Types pv
where p._ProbeSpecies_key = op._ProbeSpecies_key
and op.species = s.commonName
and p.sex = t1.term
and t1._Vocab_key = v1._Vocab_key
and v1.name = "Gender"
and p.cellLine = t2.term
and t2._Vocab_key = v2._Vocab_key
and v2.name = "Cell Line"
and p._Vector_key = pv._Vector_key
and pv.vectorType = t3.term
and t3._Vocab_key = v3._Vocab_key
and v3.name = "Segment Vector Type"
go

dump tran ${DBNAME} with truncate_only
go

update PRB_Source set name = null where name = 'anonymous'
go

dump tran ${DBNAME} with truncate_only
go

/* now map GXD_Antibody_Old._AntibodySpecies_key to MGI_Organism._Organism_key */

insert into GXD_Antibody
select p._Antibody_key, p._Refs_key, p._AntibodyClass_key, p._AntibodyType_key,
s._Organism_key, p._Antigen_key, p.antibodyName, p.antibodyNote,
p.recogWestern, p.recogImmunPrecip, p.recogNote,
p.creation_date, p.modification_date
from GXD_Antibody_Old p, GXD_AntibodySpecies op, MGI_Organism s
where p._antibodySpecies_key = op._antibodySpecies_key
and op.antibodySpecies = s.commonName
go

dump tran ${DBNAME} with truncate_only
go

/* now reload ACC_LogicaDB */

insert into ACC_LogicalDB
select *
from ACC_LogicalDB_Old
go

dump tran ${DBNAME} with truncate_only
go

/* now reload MRK_Chromosome */

insert into MRK_Chromosome
select *
from MRK_Chromosome_Old
go

dump tran ${DBNAME} with truncate_only
go

/* now reload MRK_Label */

insert into MRK_Label
select *
from MRK_Label_Old
go

dump tran ${DBNAME} with truncate_only
go

checkpoint
go

/* assign MGI accession IDs to MGI_Organism */

declare acc_cursor cursor for
select _Organism_key
from MGI_Organism
for read only
go

begin transaction

declare @key int

open acc_cursor
fetch acc_cursor into @key

while (@@sqlstatus = 0)
begin
        /* Assign MGI Acc ID */
        exec ACC_assignMGI @key, "Organism", @private = 1
        fetch acc_cursor into @key
end

close acc_cursor
deallocate cursor acc_cursor
commit transaction
go

exec ACC_insert 1, "10090", 32, "Organism", @private = 1
exec ACC_insert 2, "9606", 32, "Organism", @private = 1
exec ACC_insert 11, "9913", 32, "Organism", @private = 1
exec ACC_insert 40, "10116", 32, "Organism", @private = 1
exec ACC_insert 63, "7227", 32, "Organism", @private = 1 /* drosophila*/
exec ACC_insert 79, "7955", 32, "Organism", @private = 1 /* zebrafish */
go

dump tran ${DBNAME} with truncate_only
go

quit

EOSQL

${newmgddbschema}/index/MGI_Organism_create.object >> $LOG
${newmgddbschema}/index/MGI_Organism_MGIType_create.object >> $LOG
${newmgddbschema}/index/ACC_LogicalDB_create.object >> $LOG
${newmgddbschema}/index/GXD_Antibody_create.object >> $LOG
${newmgddbschema}/index/MRK_Chromosome_create.object >> $LOG
${newmgddbschema}/index/MRK_Label_create.object >> $LOG
${newmgddbschema}/index/PRB_Source_create.object >> $LOG

cat - <<EOSQL | doisql.csh $0 >> $LOG

use $DBNAME
go

drop table ACC_LogicalDB_Old
go

drop table GXD_Antibody_Old
go

drop table MRK_Chromosome_Old
go

drop table MRK_Label_Old
go

drop table PRB_Source_Old
go

end

EOSQL

date >> $LOG

