#!/bin/csh -f

#
# Migration for TR 2239
#

cd `dirname $0`

setenv LOG $0.log
rm -rf $LOG
touch $LOG
 
date >> $LOG
 
tr2239cleanup.py $DBSERVER $DBNAME

cat - <<EOSQL | doisql.csh $0 >> $LOG

use $DBNAME
go

insert into ACC_MGIType 
values (12, 'Genotype', 'GXD_Genotype', '_Genotype_key', getdate(), getdate(), getdate())
go

declare acc_cursor cursor for
select _Genotype_key
from GXD_Genotype
for read only
go

begin transaction

declare @genotypeKey int

open acc_cursor
fetch acc_cursor into @genotypeKey

while (@@sqlstatus = 0)
begin
        /* Assign MGI Acc ID */
        exec ACC_assignMGI @genotypeKey, "Genotype", @private = 1
        fetch acc_cursor into @genotypeKey
end

close acc_cursor
deallocate cursor acc_cursor
commit transaction
go

EOSQL

date >> $LOG

