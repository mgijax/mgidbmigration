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

sp_rename GXD_Genotype, GXD_Genotype_Old
go

end

EOSQL

#
# Use new schema product to create new table
#
${newmgddbschema}/table/GXD_Genotype_create.object
${newmgddbschema}/default/GXD_Genotype_bind.object

cat - <<EOSQL | doisql.csh $0 >> $LOG

use $DBNAME
go

insert into GXD_Genotype 
(_Genotype_key, _Strain_key, isConditional, createdBy, modifiedBy, note, creation_date, modification_date)
select _Genotype_key, _Strain_key, 0, "gxd editor", "gxd editor", null, creation_date, modification_date
from GXD_Genotype_Old
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

${newmgddbschema}/key/GXD_Genotype_create.object
${newmgddbschema}/index/GXD_Genotype_create.object

# New VOC and DAG tables

${newmgddbschema}/table/DAG_create.logical
${newmgddbschema}/table/VOC_create.logical
${newmgddbschema}/key/DAG_create.logical
${newmgddbschema}/key/VOC_create.logical
${newmgddbschema}/index/DAG_create.logical
${newmgddbschema}/index/VOC_create.logical
${newmgddbschema}/default/DAG_bind.logical
${newmgddbschema}/default/VOC_bind.logical

date >> $LOG

