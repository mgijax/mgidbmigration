#!/bin/csh -f

#
# Migration for TR 1404
#

setenv SYBASE   /opt/sybase
set path = ($path $SYBASE/bin)

setenv DSQUERY	$1
setenv MGD	$2
setenv NOMEN	$3

setenv LOG $0.log

rm -rf $LOG
touch $LOG
 
date >> $LOG
 
set scripts = $SYBASE/admin

set sql = /tmp/$$.sql
 
cat > $sql << EOSQL
 
use $MGD
go

delete from MRK_Types where _Marker_Type_key in (4,5)
go

checkpoint
go

quit
 
EOSQL
 
$scripts/dbo_sql $sql
rm $sql
 
echo "Rebuild MRK tables..." >> $LOG
$SYBASE/admin/utilities/MRK/createMRK.sh $DSQUERY $MGD >>& $LOG

date >> $LOG
