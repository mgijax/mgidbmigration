#!/bin/csh -f

#
# Migration for TR 1284
#

setenv SYBASE   /opt/sybase
setenv PYTHONPATH       /usr/local/lib/python1.4:/usr/local/etc/httpd/python
set path = ($path $SYBASE/bin)

setenv DSQUERY $1
setenv MGD $2

setenv LOG $0.log

rm -rf $LOG
touch $LOG
 
date >> $LOG
 
set scripts = $SYBASE/admin

set sql = /tmp/$$.sql
 
cat > $sql << EOSQL
 
use master
go
 
sp_dboption $MGD, "select into", true
go
  
use $MGD
go
   
checkpoint
go
 
drop table tempdb..MRK_Marker1284
go

drop table tempdb..HMD_Homology_Marker1284
go

drop table tempdb..HMD_Homology1284
go

drop table tempdb..HMD_Homology_Assay1284
go

drop table tempdb..HMD_Class1284
go

/* Select mouse as well...it's a keeper! */

select *
into #marker
from MRK_Marker
where _Species_key not in (1,18,22,37,34,19,21,48,58,10,47,9,20,13,44,39,35,11,40,2)
go

select h.*
into #homologymarker
from #marker m, HMD_Homology_Marker h
where m._Marker_key = h._Marker_key
go

select h.*
into #homology
from #homologymarker m, HMD_Homology h, MRK_Marker r
where m._Homology_key = h._Homology_key
and m._Marker_key = r._Marker_key
and _Species_key not in (1,18,22,37,34,19,21,48,58,10,47,9,20,13,44,39,35,11,40,2)
go

select a.*
into #homologyassay
from #homology h, HMD_Homology_Assay a
where h._Homology_key = a._Homology_key
go

select c.*
into #homologyclass
from #homology h, HMD_Class c
where h._Class_key = c._Class_key
go

select *
into tempdb..MRK_Marker1284
from #marker
go

select *
into tempdb..HMD_Homology_Marker1284
from #homologymarker
go

select *
into tempdb..HMD_Homology1284
from #homology
go

select *
into tempdb..HMD_Homology_Assay1284
from #homologyassay
go

select *
into tempdb..HMD_Class1284
from #homologyclass
go

select distinct v.symbol, v.chromosome, substring(v.commonName,1,30), substring(v.jnumID,1,10)
from #homologymarker h, HMD_Homology_View v
where h._Homology_key = v._Homology_key
and v._Species_key not in (1,18,22,37,34,19,21,48,58,10,47,9,20,13,44,39,35,11,40,2)
order by v.commonName
go

quit
 
EOSQL
 
$scripts/dbo_sql $sql >> $LOG
rm $sql
 
cat $scripts/.mgd_dbo_password | bcp tempdb..MRK_Marker1284 out MRK_Marker1284.bcp -c -t\\t -Umgd_dbo >> $LOG
cat $scripts/.mgd_dbo_password | bcp tempdb..HMD_Homology_Marker1284 out HMD_Homology_Marker1284.bcp -c -t\\t -Umgd_dbo >> $LOG
cat $scripts/.mgd_dbo_password | bcp tempdb..HMD_Homology1284 out HMD_Homology1284.bcp -c -t\\t -Umgd_dbo >> $LOG
cat $scripts/.mgd_dbo_password | bcp tempdb..HMD_Homology_Assay1284 out HMD_Homology_Assay1284.bcp -c -t\\t -Umgd_dbo >> $LOG
cat $scripts/.mgd_dbo_password | bcp tempdb..HMD_Class1284 out HMD_Class1284.bcp -c -t\\t -Umgd_dbo >> $LOG

set sql = /tmp/$$.sql
 
cat > $sql << EOSQL
 
use master
go
 
sp_dboption $MGD, "select into", true
go
  
use $MGD
go
   
checkpoint
go
 
/* Select mouse as well! */

select *
into #marker
from MRK_Marker
where _Species_key not in (1,18,22,37,34,19,21,48,58,10,47,9,20,13,44,39,35,11,40,2)
go

/* Delete HMD_Homology_Marker to remove the undesired homology record */

delete HMD_Homology_Marker
from #marker m, HMD_Homology_Marker h
where m._Marker_key = h._Marker_key
go

checkpoint
go

quit
 
EOSQL
 
$scripts/dbo_sql $sql >> $LOG
rm $sql

# List out single homologies

./HMD_SingleClasses.sql $DSQUERY $MGD
./HMD_SingleReferences.sql $DSQUERY $MGD

# Delete single homologies and orphan class/homology records...

./tr1343.sql $DSQUERY $MGD >> $LOG

date >> $LOG

