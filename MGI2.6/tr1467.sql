#!/bin/csh -f

#
# Migration for TR 1467
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

/* set all Mouse Marker LocusLink IDS to public */

update ACC_Accession
set private = 0
from ACC_Accession a, MRK_Marker m
where a._MGIType_key = 2
and a._LogicalDB_key = 24
and a._Object_key = m._Marker_key
and m._Species_key = 1
go

checkpoint
go

use $NOMEN
go

checkpoint
go

/* set all LocusLink IDS to public */

update ACC_Accession
set private = 0
from ACC_Accession
where _LogicalDB_key = 24
go

checkpoint
go

quit
 
EOSQL
  
$scripts/dbo_sql $sql >> $LOG
rm $sql
   
date >> $LOG
