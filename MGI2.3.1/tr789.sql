#!/bin/csh -f

#
# Migration for TR 789
#

setenv DSQUERY $1
setenv MGD $2

setenv LOG `pwd`/$0.log

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
 
select distinct e._Expt_key
into #expts
from MLD_Expts e, MLD_Expt_Notes n
where e.exptType like 'Text%'
and e._Expt_key = n._Expt_key
and n.note like '%radiation hybrid%'
go

update MLD_Expts
set e.exptType = 'TEXT-Radiation Hybrid'
from #expts e, MLD_Expts x
where e._Expt_key = x._Expt_key
go

checkpoint
go

quit
 
EOSQL
 
$scripts/dbo_sql $sql >> $LOG
rm $sql
 
date >> $LOG
