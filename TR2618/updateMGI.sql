#!/bin/csh -f

#
# Update MGI_dbinfo table
#

setenv SYBASE   /opt/sybase

setenv DSQUERY	 $1
setenv MGD	$2
setenv NOMEN	$3
setenv STRAINS	$4

setenv LOG $0.log

set scripts = $SYBASE/admin

rm -rf $LOG
touch $LOG
 
date >> $LOG
 
set sql = /tmp/$$.sql

cat > $sql << EOSQL
   
update $MGD..MGI_dbinfo set schema_version = "mgddbschema-1-0-1"
go

update $NOMEN..MGI_dbinfo set schema_version = "nomendbschema-1-0-1"
go

update $STRAINS..MGI_dbinfo set schema_version = "strainsdbschema-1-0-0"
go

quit
 
EOSQL
  
$scripts/dbo_sql $sql >> $LOG
rm $sql
   
date >> $LOG
