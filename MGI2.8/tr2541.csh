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
${newmgddbschema}/default/PRB_Strain_bind.object
${newmgddbschema}/key/PRB_Strain_create.object

cat - <<EOSQL | doisql.csh $0 >> $LOG
  
use ${DBNAME}
go

insert into PRB_Strain
(_Strain_key, strain, standard, needsReview, private, creation_date, modification_date)
select _Strain_key, strain, standard, needsReview, 0, creation_date, modification_date
from PRB_Strain_Old
go

declare strain_cursor cursor for
select _Strain_key
from PRB_Strain
where standard = 1
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

checkpoint
go

quit
 
EOSQL
  
${newmgddbschema}/index/PRB_Strain_create.object

date >> $LOG
