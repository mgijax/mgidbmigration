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

sp_rename GXD_AllelePair, GXD_AllelePair_Old
go

sp_rename GXD_Genotype, GXD_Genotype_Old
go

end

EOSQL

#
# Use new schema product to create new table
#
${newmgddbschema}/table/GXD_AllelePair_create.object
${newmgddbschema}/default/GXD_AllelePair_bind.object
${newmgddbschema}/table/GXD_Genotype_create.object
${newmgddbschema}/default/GXD_Genotype_bind.object

cat - <<EOSQL | doisql.csh $0 >> $LOG

use $DBNAME
go

insert into GXD_AllelePair
(_AllelePair_key, _Genotype_key, sequenceNum, _Allele_key_1, _Allele_key_2, _Marker_key, isUnknown, creation_date, modification_date)
select _AllelePair_key, _Genotype_key, sequenceNum, _Allele_key_1, _Allele_key_2, _Marker_key, 0, creation_date, modification_date
from GXD_AllelePair_Old
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

/* Swap Allele 1 and Allele 2 where Allele 1 is wild type */
/* All wild types should be Allele 2 */

declare acc_cursor cursor for
select _AllelePair_key, _Allele_key_1, _Allele_key_2
from GXD_AllelePair_View
where allele1 like "%<+>"
for read only
go

begin transaction

declare @allelepairKey int
declare @allele1 int
declare @allele2 int

open acc_cursor
fetch acc_cursor into @allelepairKey, @allele1, @allele2

while (@@sqlstatus = 0)
begin
        update GXD_AllelePair
		set _Allele_key_1 = @allele2, _Allele_key_2 = @allele1
		where _AllelePair_key = @allelepairKey
        fetch acc_cursor into @allelepairKey, @allele1, @allele2
end

close acc_cursor
deallocate cursor acc_cursor
commit transaction
go

/* Reorder Allele Pairs Alphabetically */

declare gen_cursor cursor for
select _Genotype_key, _AllelePair_key, sequenceNum
from GXD_AllelePair_View
where _Allele_key_1 is not null
order by _Genotype_key
for read only
go

begin transaction

declare @gkey int	/* primary key of records to update */
declare @prevgkey int	/* primary key of records to update */
declare @pkey int	/* primary key of records to update */
declare @oldSeq int	/* current sequence number */
declare @newSeq int	/* new sequence number */

open gen_cursor
fetch gen_cursor into @gkey, @pkey, @oldSeq
 
while (@@sqlstatus = 0)
begin
	if @gkey != @prevgkey
		select @newSeq = 1
 
	select @prevgkey = @gkey
	
  	update GXD_AllelePair set sequenceNum = @newSeq
    	where _AllelePair_key = @pkey

  	select @newSeq = @newSeq + 1

	fetch gen_cursor into @gkey, @pkey, @oldSeq
end

close gen_cursor
deallocate cursor gen_cursor
commit transaction

go

checkpoint
go

quit

EOSQL

${newmgddbschema}/key/GXD_AllelePair_create.object
${newmgddbschema}/index/GXD_AllelePair_create.object
${newmgddbschema}/key/GXD_Genotype_create.object
${newmgddbschema}/index/GXD_Genotype_create.object

date >> $LOG

