#!/bin/csh -f

#
# Migration for MGI 2.3 Release
#

setenv DSQUERY $1
setenv NOMEN $2
setenv MGD $3

setenv LOG `pwd`/Nomen1.1.log

rm -rf $LOG
touch $LOG
 
date >> $LOG
 
set scripts = $SYBASE/admin

#
# Need stored procedures for migration
#

$scripts/procedures/nomen/procedures.sh $DSQUERY $NOMEN $MGD
$scripts/views/nomen/views.sh $DSQUERY $NOMEN $MGD
$scripts/triggers/nomen/triggers.sh $DSQUERY $NOMEN $MGD

set sql = /tmp/$$.sql
 
cat > $sql << EOSQL
 
use master
go
 
sp_dboption $NOMEN, "select into", true
go
  
use $NOMEN
go
   
checkpoint
go
 
/* 
 * TR# 518
 *
 * Migrated EC numbers
*/

delete from ACC_Accession where _LogicalDB_Key = 8
go

declare ec_cursor cursor for
select _Nomen_key, ECNumber 
from nomen..MRK_Nomen
where ECNumber is not null
go
          
declare @nomenKey integer
declare @ec varchar(25)
          
open ec_cursor
fetch ec_cursor into @nomenKey, @ec
          
while (@@sqlstatus = 0)
begin
execute ACC_insert @nomenKey, @ec, 8, "Nomenclature"
fetch ec_cursor into @nomenKey, @ec
end

close ec_cursor
deallocate cursor ec_cursor
go
                 
checkpoint
go

quit
 
EOSQL
 
$scripts/dbo_sql $sql >> $LOG
rm $sql
 
date >> $LOG

