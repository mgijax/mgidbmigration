#!/bin/csh
 
setenv DSQUERY $1
setenv MGD $2
 
isql -S$DSQUERY -Umgd_public -Pmgdpub -w200 <<END > $0.rpt

use $MGD 
go

set nocount on
go

select h._Class_key, m._Marker_key
into #homology
from HMD_Homology h, HMD_Homology_Marker m
where h._Homology_key = m._Homology_key
go

select *
into #single
from #homology
group by _Class_key
having count(*) = 1
go

set nocount off
go

print ""
print "Homology Classes w/ Single Entries"
print ""

select r.symbol, r.commonName, r.jnum
from #single s, HMD_Homology_View r
where s._Class_key = r._Class_key
order by r.symbol
go
 
quit

END

