#!/bin/csh -f

#
# Migration for TR 2193
#

setenv SYBASE   /opt/sybase

setenv DSQUERY	 $1
setenv DATABASE	$2

setenv LOG $0.log

set scripts = $SYBASE/admin

rm -rf $LOG
touch $LOG
 
date >> $LOG
 
set sql = /tmp/$$.sql

cat > $sql << EOSQL
   
use $DATABASE
go

checkpoint
go

select symbol, substring(symbol, 3, char_length(symbol) - 3), substring(symbol, 3, char_length(symbol) - 3) + "<+>"
from ALL_Allele
where symbol like '+<%'
go

update ALL_Allele
set symbol = substring(symbol, 3, char_length(symbol) - 3) + "<+>"
where symbol like '+<%'
go

checkpoint
go

quit
 
EOSQL
  
$scripts/dbo_sql $sql >> $LOG
rm $sql
   
date >> $LOG
