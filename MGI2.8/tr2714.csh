#!/bin/csh -f

#
# Migration for TR 2916
#

cd `dirname $0`

setenv LOG $0.log
rm -rf $LOG
touch $LOG
 
date >> $LOG
 
cat - <<EOSQL | doisql.csh $0 >> $LOG
  
use ${DBNAME}
go

sp_rename PRB_Source, PRB_Source_Old
go

checkpoint
go

quit
 
EOSQL
  
#
# Use new schema product to create new tables
#
${newmgddbschema}/table/PRB_Species_create.object
${newmgddbschema}/table/PRB_Source_create.object
${newmgddbschema}/default/PRB_Species_bind.object
${newmgddbschema}/default/PRB_Source_bind.object
${newmgddbschema}/key/PRB_Species_create.object
${newmgddbschema}/key/PRB_Source_create.object

cat - <<EOSQL | doisql.csh $0 >> $LOG
  
use ${DBNAME}
go

insert into PRB_Species (_ProbeSpecies_key, species)
values(-1, "Not Specified")
go

insert into PRB_Species (_ProbeSpecies_key, species)
values(-2, "Not Applicable")
go

insert into PRB_Species (_ProbeSpecies_key, species)
values(1, "mouse, laboratory")
go

select distinct species, seq = identity(5)
into #newspecies
from PRB_Source_Old where species not in ("Not Applicable", "Not Specified", "mouse, laboratory")
go

insert into PRB_Species (_ProbeSpecies_key, species)
select seq + 1, species
from #newspecies
go

insert into PRB_Source
(_Source_key, name, description, _Refs_key, _ProbeSpecies_key, _Strain_key, _Tissue_key, 
age, ageMin, ageMax, sex, cellLine, creation_date, modification_date)
select p._Source_key, p.name, p.description, p._Refs_key, s._ProbeSpecies_key,
p._Strain_key, p._Tissue_key, p.age, p.ageMin, p.ageMax, p.sex, p.cellLine, 
p.creation_date, p.modification_date
from PRB_Source_Old p, PRB_Species s
where p.species = s.species
go

checkpoint
go

quit
 
EOSQL
  
${newmgddbschema}/index/PRB_Species_create.object
${newmgddbschema}/index/PRB_Source_create.object

date >> $LOG
