#!/bin/csh -f

#
# Migration for TR 1177
#

setenv SYBASE   /opt/sybase
set path = ($path $SYBASE/bin)

setenv DSQUERY	$1
setenv MGD	$2

setenv LOG $0.log

rm -rf $LOG
touch $LOG
 
date >> $LOG
 
set scripts = $SYBASE/admin

./tr1177.py -S $DSQUERY -D $MGD -U mgd_dbo -P `cat $scripts/.mgd_dbo_password` alleles.txt

set sql = /tmp/$$.sql
cat > $sql << EOSQL
 
use $MGD
go

declare @typekey int

if not exists (select 1 from ACC_MGIType where name = "Allele")
begin
        select @typekey = max(_MGIType_key) + 1 from ACC_MGIType
	insert into ACC_MGIType (_MGIType_key, name, tableName, primaryKeyName)
	values (@typekey, "Allele", "ALL_Allele", "_Allele_key")
end

go

/* Add MGI Accession numbers for all ALL_Allele records which don't have one... */

declare all_cursor cursor for
select _Allele_key
from ALL_Allele al
where not exists 
(select 1 from ACC_Accession a where al._Allele_key = a._Object_key
and a._MGIType_key = 11)
for read only
go

declare @allKey integer

open all_cursor
 
fetch all_cursor into @allkey
   
while (@@sqlstatus = 0)
begin
	exec ACC_assignMGI @allKey, "Allele"
        fetch all_cursor into @allKey
end

close all_cursor
deallocate cursor all_cursor
go

checkpoint
go

quit
 
EOSQL
 
$scripts/dbo_sql $sql
rm $sql
 
date >> $LOG
