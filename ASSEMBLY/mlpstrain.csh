#!/bin/csh -f

#
# Migration for MLP tables
#

cd `dirname $0` && source ./Configuration

setenv LOG $0.log
rm -rf ${LOG}
touch ${LOG}
 
date | tee -a ${LOG}
echo "MLP Migration..." | tee -a ${LOG}
 
cat - <<EOSQL | doisql.csh $0 >> ${LOG}

use ${DBNAME}
go

sp_rename PRB_Strain, PRB_Strain_Old
go

sp_rename MLP_mergeStrain, PRB_mergeStrain
go

end

EOSQL

${newmgddbschema}/table/PRB_Strain_create.object >>& ${LOG}
${newmgddbschema}/table/PRB_Strain_Type_create.object >>& ${LOG}
${newmgddbschema}/table/MGI_Synonym_create.object >>& ${LOG}
${newmgddbschema}/table/MGI_SynonymType_create.object >>& ${LOG}

cat - <<EOSQL | doisql.csh $0 >> ${LOG}

use ${DBNAME}
go

insert into PRB_Strain
select o._Strain_key, t._Term_key, o.strain, o.standard, o.needsReview, 
o.private, 1086, 1086, o.creation_date, o.modification_date
from PRB_Strain_Old o, MLP_Strain mlp, MLP_Species p, VOC_Term t, VOC_Vocab v
where o._Strain_key = mlp._Strain_key
and mlp._Species_key = p._Species_key
and p.species = t.term
and t._Vocab_key = v._Vocab_key
and v.name = 'Strain Species'
go

select newKey = identity(10), o._Strain_key, t._Term_key, o.creation_date, o.modification_date
into #stype
from MLP_StrainTypes o, MLP_StrainType s, VOC_Term t, VOC_Vocab v
where o._StrainType_key = s._StrainType_key
and s.strainType = t.term
and t._Vocab_key = v._Vocab_key
and v.name = 'Strain Type'
go

insert into PRB_Strain_Type 
select newKey, _Strain_key, _Term_key, 1086, 1086, creation_date, modification_date
from #stype
go

/* migrate MLP_Notes into MGI_Note, MGI_NoteType */

declare @noteTypeKey integer
declare @noteKey integer
select @noteTypeKey = max(_NoteType_key) + 1 from MGI_NoteType
select @noteKey = max(_Note_key) from MGI_Note
insert into MGI_NoteType values(@noteTypeKey, 10, 'Strain Origin', 0, 1086, 1086, getdate(), getdate())
insert into MGI_NoteType values(@noteTypeKey + 1, 10, 'General', 0, 1086, 1086, getdate(), getdate())
insert into MGI_NoteType values(@noteTypeKey + 2, 10, 'Nomenclature', 0, 1086, 1086, getdate(), getdate())
select _Strain_key, note, sequenceNum, seq = identity(10) into #notes from MLP_Notes
insert into MGI_Note
select @noteKey + seq, _Strain_key, 10, @noteTypeKey, 1086, 1086, getdate(), getdate()
from #notes where sequenceNum = 1
insert into MGI_NoteChunk
select @noteKey + seq, sequenceNum, note, 1086, 1086, getdate(), getdate()
from #notes
go

/* migrate PRB_Strain_Synonym into MGI_Synonym, MGI_SynonymType */

declare @synTypeKey integer
declare @synKey integer
select @synTypeKey = 1000
select @synKey = 1000
insert into MGI_SynonymType values(@synTypeKey, 10, 'synonym', 1086, 1086, getdate(), getdate())
insert into MGI_SynonymType values(@synTypeKey + 1, 10, 'nomenclature history', 1086, 1086, getdate(), getdate())
select _Strain_key, synonym, seq = identity(10) into #syns from PRB_Strain_Synonym
insert into MGI_Synonym
select @synKey + seq, _Strain_key, 10, @synTypeKey + 1, null, synonym, 1086, 1086, getdate(), getdate()
from #syns
go

end

EOSQL

cat - <<EOSQL | doisql.csh $0 >> ${LOG}

use ${DBNAME}
go

drop table PRB_Strain_Old
go

drop table PRB_Strain_Synonym
go

drop table MLP_Extra
go

drop table MLP_Notes
go

drop table MLP_Species
go

drop table MLP_Strain
go

drop table MLP_StrainType
go

drop table MLP_StrainTypes
go

drop view MLP_Strain_View
go

drop view MLP_StrainTypes_View
go

end

EOSQL

${newmgddbschema}/index/PRB_Strain_create.object >>& ${LOG}
${newmgddbschema}/index/PRB_Strain_Type_create.object >>& ${LOG}
${newmgddbschema}/default/PRB_Strain_bind.object >>& ${LOG}
${newmgddbschema}/default/PRB_Strain_Type_bind.object >>& ${LOG}
${newmgddbschema}/index/MGI_Synonym_create.object >>& ${LOG}
${newmgddbschema}/index/MGI_SynonymType_create.object >>& ${LOG}
${newmgddbschema}/default/MGI_Synonym_bind.object >>& ${LOG}
${newmgddbschema}/default/MGI_SynonymType_bind.object >>& ${LOG}

date | tee -a ${LOG}

