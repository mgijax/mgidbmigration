#!/bin/csh -f

#
# Migration for MGI_Synonym
#

cd `dirname $0` && source ./Configuration

setenv LOG $0.log
rm -rf ${LOG}
touch ${LOG}
 
date | tee -a ${LOG}
echo "MGI Synonym Migration..." | tee -a ${LOG}
 
${newmgddbschema}/table/MGI_Synonym_create.object >>& ${LOG}
${newmgddbschema}/table/MGI_SynonymType_create.object >>& ${LOG}

cat - <<EOSQL | doisql.csh $0 >> ${LOG}

use ${DBNAME}
go

/* migrate PRB_Strain_Synonym into MGI_Synonym, MGI_SynonymType */

declare @synTypeKey integer
declare @synKey integer
select @synTypeKey = 1000
select @synKey = 1000

insert into MGI_SynonymType values
(@synTypeKey, 10, 'synonym', 'synonym used in community', 1086, 1086, getdate(), getdate())
insert into MGI_SynonymType 
values(@synTypeKey + 1, 10, 'nomenclature history', 'synonym due to nomenclature changes', 1086, 1086, getdate(), getdate())

select _Strain_key, synonym, seq = identity(10) into #syns from PRB_Strain_Synonym

insert into MGI_Synonym
select @synKey + seq, _Strain_key, 10, @synTypeKey + 1, null, synonym, 1086, 1086, getdate(), getdate()
from #syns

go

/* migrate NOM_Synonym into MGI_Synonym, MGI_SynonymType */

declare @synTypeKey integer
declare @synKey integer

select @synTypeKey = max(_SynonymType_key) + 1 from MGI_SynonymType
select @synKey = max(_Synonym_Key) from MGI_Synonym

insert into MGI_SynonymType 
values(@synTypeKey, 21, 'Author', 'synonymn the author used', ${CREATEDBY}, ${CREATEDBY}, getdate(), getdate())
insert into MGI_SynonymType 
values(@synTypeKey + 1, 21, 'Other', 'other', ${CREATEDBY}, ${CREATEDBY}, getdate(), getdate())

select _Nomen_key, _Refs_key, name, isAuthor, seq = identity(10) into #syns from NOM_Synonym

insert into MGI_Synonym
select @synKey + seq, _Nomen_key, 21, @synTypeKey, _Refs_key, name, ${CREATEDBY}, ${CREATEDBY}, getdate(), getdate()
from #syns
where isAuthor = 1

insert into MGI_Synonym
select @synKey + seq, _Nomen_key, 21, @synTypeKey + 1, _Refs_key, name, ${CREATEDBY}, ${CREATEDBY}, getdate(), getdate()
from #syns
where isAuthor = 0

go

end

EOSQL

#cat - <<EOSQL | doisql.csh $0 >> ${LOG}
#
#use ${DBNAME}
#go
#
#drop table NOM_Synonym
#go
#
#drop table PRB_Strain_Synonym
#go
#
#end
#
#EOSQL

${newmgddbschema}/index/MGI_Synonym_create.object >>& ${LOG}
${newmgddbschema}/index/MGI_SynonymType_create.object >>& ${LOG}
${newmgddbschema}/default/MGI_Synonym_bind.object >>& ${LOG}
${newmgddbschema}/default/MGI_SynonymType_bind.object >>& ${LOG}

date | tee -a ${LOG}

