#!/bin/csh -f

#
# Migration for TR 256
#

cd `dirname $0`

setenv LOG $0.log
rm -rf $LOG
touch $LOG
 
date >> $LOG
 
cat - <<EOSQL | doisql.csh $0 >> $LOG
  
use ${DBNAME}
go

update MLD_RI set _RISet_key = -1, RI_IdList = "Not Specified" where _RISet_key = null
go

sp_rename RI_RISet, RI_RISet_Old
go

sp_rename MLD_RI, MLD_RI_Old
go

checkpoint
go

quit
 
EOSQL
  
#
# Use new schema product to create new tables
#
${newmgddbschema}/table/RI_RISet_create.object
${newmgddbschema}/table/MLD_RI_create.object
${newmgddbschema}/default/RI_RISet_bind.object
${newmgddbschema}/default/MLD_RI_bind.object

cat - <<EOSQL | doisql.csh $0 >> $LOG
  
use ${DBNAME}
go

/* insert Not Specified record into RI_RISet */

insert into RI_RISet
(_RISet_key, _Strain_key_1, _Strain_key_2, designation, abbrev1, abbrev2, RI_IdList)
values (-1, -1, -1, "Not Specified", "NS", "NS", "Not Specified")
go

/* Resolve Strain keys */

select r._RISet_key, r.origin,
strain1 = substring(r.origin, 1, charindex(" x", r.origin) - 1),
strain2 = substring(r.origin, charindex("x ", r.origin) + 2, char_length(r.origin)),
_Strain_key_1 = s1._Strain_key,
_Strain_key_2 = s2._Strain_key
into #strains
from RI_RISet_Old r, PRB_Strain s1, PRB_Strain s2
where r._RISet_key > 0
and substring(r.origin, 1, charindex(" x", r.origin) - 1) = s1.strain
and substring(r.origin, charindex("x ", r.origin) + 2, char_length(r.origin)) = s2.strain
go

insert into #strains
select r._RISet_key, r.origin,
strain1 = "129S1/Sv-Kitl<Sl-J> p<+> Tyr<+>",
strain2 = "A/HeJ",
_Strain_key_1 = s1._Strain_key,
_Strain_key_2 = s2._Strain_key
from RI_RISet_Old r, PRB_Strain s1, PRB_Strain s2
where r._RISet_key > 0
and "129S1/Sv-Kitl<Sl-J> p<+> Tyr<+>" = s1.strain
and "A/HeJ" = s2.strain
go

insert into #strains
select r._RISet_key, r.origin,
strain1 = "129S2/SvPas-Kitl<Sl-J> p<+> Tyr<+>",
strain2 = "C57BL/6JPas",
_Strain_key_1 = s1._Strain_key,
_Strain_key_2 = s2._Strain_key
from RI_RISet_Old r, PRB_Strain s1, PRB_Strain s2
where r._RISet_key > 0
and "129S2/SvPas-Kitl<Sl-J> p<+> Tyr<+>" = s1.strain
and "C57BL/6JPas" = s2.strain
go

insert into RI_RISet
(_RISet_key, _Strain_key_1, _Strain_key_2, designation, abbrev1, abbrev2, RI_IdList, creation_date, modification_date)
select r._RISet_key, s._Strain_key_1, s._Strain_key_2, r.designation, r.abbrev1, r.abbrev2,
r.RI_IdList, r.creation_date, r.modification_date
from RI_RISet_Old r, #strains s
where r._RISet_key = s._RISet_key
go

insert into MLD_RI
(_Expt_key, RI_IdList, _RISet_key, creation_date, modification_date)
select _Expt_key, RI_IdList, _RISet_key, creation_date, modification_date
from MLD_RI_Old
go

drop trigger RI_RISet_Update
go

drop trigger MLD_RI_Insert
go

drop trigger MLD_RI_Update
go

checkpoint
go

quit
 
EOSQL
  
date >> $LOG

${newmgddbschema}/key/RI_RISet_create.object
${newmgddbschema}/key/MLD_RI_create.object
${newmgddbschema}/index/RI_RISet_create.object
${newmgddbschema}/index/MLD_RI_create.object
