#!/bin/csh -f

#
# Migration for TR 2488
#

setenv SYBASE   /opt/sybase

setenv DSQUERY	 $1
setenv MGD	$2
setenv NOMEN	$3

setenv LOG $0.log

set scripts = $SYBASE/admin

rm -rf $LOG
touch $LOG
 
date >> $LOG
 
set sql = /tmp/$$.sql

cat > $sql << EOSQL
   
use $MGD
go

checkpoint
go

update ALL_Status
set status = "In Progress"
where _Allele_Status_key = 1
go

checkpoint
go

use $NOMEN
go

checkpoint
go

update MRK_Status
set status = "In Progress"
where _Marker_Status_key = 1
go

checkpoint
go

quit
 
EOSQL
  
$scripts/dbo_sql $sql >> $LOG
rm $sql
   
date >> $LOG
