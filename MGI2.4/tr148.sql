#!/bin/csh -f

#
# Migration for TR 148
#

setenv SYBASE   /opt/sybase
setenv PYTHONPATH /usr/local/mgi/lib/python:/usr/local/etc/httpd/python
set path = ($path $SYBASE/bin)

setenv DSQUERY	$1
setenv MGD	$2

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

truncate table MLC_Marker
go

truncate table MLC_Marker_edit
go

checkpoint
go

quit
 
EOSQL
  
$scripts/dbo_sql $sql >> $LOG
rm $sql
   
./mlc_bcp.py -S $DSQUERY -D $MGD

cat $scripts/.mgd_dbo_password | bcp $MGD..MLC_Marker in MLC_Marker_Temp.bcp -c -t\| -Umgd_dbo >> $LOG
cat $scripts/.mgd_dbo_password | bcp $MGD..MLC_Marker_edit in MLC_Marker_Edit_Temp.bcp -c -t\| -Umgd_dbo >> $LOG

./mlc_convert.py -S $DSQUERY -D $MGD >> $LOG

date >> $LOG
