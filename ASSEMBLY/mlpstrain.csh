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

sp_rename MLP_Extra, PRB_Strain_Extra
go

sp_rename MLP_StrainTypes, PRB_StrainTypes
go

end

EOSQL

${newmgddbschema}/table/PRB_Strain_create.object >>& ${LOG}

cat - <<EOSQL | doisql.csh $0 >> ${LOG}

use ${DBNAME}
go

insert into PRB_Strain
select o._Strain_key, t._Term_key, o.strain, o.standard, o.needsReview, 
o.private, ${CREATEDBY}, ${CREATEDBY}, o.creation_date, o.modification_date
from PRB_Strain_Old o, MLP_Strain mlp, MLP_Species p, VOC_Term t, VOC_Vocab v
where o._Strain_key = mlp._Strain_key
and mlp._Species_key = p._Species_key
and p.species = t.term
and t._Vocab_key = v._Vocab_key
and v.name = 'Strain Species'
go

update PRB_StrainTypes
set _StrainType_key = t._Term_key
from PRB_StrainTypes p, MLP_StrainType s, VOC_Term t, VOC_Vocab v
where p._StrainType_key = s._StrainType_key
and s.strainType = t.term
and t._Vocab_key = v._Vocab_key
and v.name = 'Strain Type'
go

/* migrate MLP_Notes into MGI_Note, MGI_NoteType */

declare @noteTypeKey integer
declare @noteKey integer
select @noteTypeKey = select max(_NoteType_key) + 1 from MGI_NoteType
select @noteKey = select max(_Note_key) from MGI_Note
insert into MGI_NoteType values(@noteTypeKey, 10, 'Strain Origin', 0, ${CREATEDBY}, ${CREATEDBY}, getdate(), getdate())
insert into MGI_NoteType values(@noteTypeKey + 1, 10, 'General', 0, ${CREATEDBY}, ${CREATEDBY}, getdate(), getdate())
insert into MGI_NoteType values(@noteTypeKey + 2, 10, 'Nomenclature', 0, ${CREATEDBY}, ${CREATEDBY}, getdate(), getdate())
select _Strain_key, note, sequenceNum, seq = identity(10) into #notes from MLP_Notes
insert into MGI_Note
select @noteKey + seq, _Strain_key, 10, @noteTypeKey, ${CREATEDBY}, ${CREATEDBY}, getdate(), getdate()
from #notes where sequenceNum = 1
select @noteKey + seq, sequenceNum, note, ${CREATEDBY}, ${CREATEDBY}, getdate(), getdate()
from #notes
go

drop table PRB_Strain_Old
go

drop table MLP_Notes
go

drop table MLP_Species
go

drop table MLP_Strain
go

drop table MLP_StrainType
go

end

EOSQL

date | tee -a ${LOG}

