#!/bin/csh -f

#
# Migration for TR 2541
#

cd `dirname $0`

setenv LOG $0.log
rm -rf $LOG
touch $LOG
 
date >> $LOG
 
cat - <<EOSQL | doisql.csh $0 >> $LOG
  
use ${DBNAME}
go

sp_rename PRB_Strain, PRB_Strain_Old
go

checkpoint
go

quit
 
EOSQL
  
#
# Use new schema product to create new tables
#
${newmgddbschema}/table/PRB_Strain_create.object
${newmgddbschema}/table/PRB_Strain_Synonym_create.object
${newmgddbschema}/default/PRB_Strain_bind.object
${newmgddbschema}/default/PRB_Strain_Synonym_bind.object
${newmgddbschema}/key/PRB_Strain_Synonym_create.object
${newmgddbschema}/key/PRB_Strain_create.object

#
# changes made to this procedure must be installed prior to data migration
#
${newmgddbschema}/procedure/ACC_assignMGI_drop.object
${newmgddbschema}/procedure/ACC_assignMGI_create.object

cat - <<EOSQL | doisql.csh $0 >> $LOG
  
use ${DBNAME}
go

insert into PRB_Strain
(_Strain_key, strain, standard, needsReview, private, creation_date, modification_date)
select _Strain_key, strain, standard, needsReview, 0, creation_date, modification_date
from PRB_Strain_Old
go

select _Strain_key, synonym = substring(note1, 6, 255), seq = identity(5)
into #synonyms
from MLP_Extra
where note1 like 'syn:%'
go

insert into PRB_Strain_Synonym (_Synonym_key, _Strain_key, synonym)
select seq + 1, _Strain_key, synonym
from #synonyms
go

checkpoint
go

quit
 
EOSQL
  
${newmgddbschema}/index/PRB_Strain_create.object
${newmgddbschema}/index/PRB_Strain_Synonym_create.object

cat - <<EOSQL | doisql.csh $0 >>& $LOG

use tempdb
go
   
drop table JRSStrain
go

drop table JRSType
go

create table JRSStrain
(
registry   integer not null,
strain     varchar(80) null,
genes      varchar(255) null,
privacy    varchar(10) not null,
synonyms   varchar(25) null,
types      varchar(255) null
)
go

create table JRSType
(
jrstype    varchar(255) null,
mgikey1    integer not null,
mgikey2    integer null,
mgikey3    integer null
)
go

checkpoint
go

quit
 
EOSQL
 
cat $DBPASSWORDFILE | bcp tempdb..JRSStrain in tr2541.txt -c -t\\t -S$DBSERVER -U$DBUSER >>& $LOG
cat $DBPASSWORDFILE | bcp tempdb..JRSType in tr2541.type.tab -c -t\\t -S$DBSERVER -U$DBUSER >>& $LOG

cat - <<EOSQL | doisql.csh $0 >>& $LOG
 
use tempdb
go

create clustered index index_registry on JRSStrain(registry)
go

create nonclustered index index_strain on JRSStrain(strain)
go

grant select on JRSStrain to public
go

grant select on JRSType to public
go

checkpoint
go

quit
 
EOSQL
 
# Process JRS Strains

./tr2541.py $DBSERVER $DBNAME 1 >>& $LOG

# Assign MGI Accession IDS to Standard Strains

cat - <<EOSQL | doisql.csh $0 >> $LOG
  
use ${DBNAME}
go

declare strain_cursor cursor for
select _Strain_key
from PRB_Strain
where standard = 1
union
select s._Strain_key
from PRB_Strain s
where s.standard = 0
and exists (select * from PRB_Strain_Acc_View a
where s._Strain_key = a._Object_key
and a._LogicalDB_key = 22)
for read only
go

begin transaction

declare @strainKey int

open strain_cursor
fetch strain_cursor into @strainKey

while (@@sqlstatus = 0)
begin
	/* Assign MGI Acc ID */
	exec ACC_assignMGI @strainKey, "Strain", @private = 1
	fetch strain_cursor into @strainKey
end

close strain_cursor
deallocate cursor strain_cursor
commit transaction
go

quit

EOSQL

date >> $LOG
