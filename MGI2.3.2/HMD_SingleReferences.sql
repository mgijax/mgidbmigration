#!/bin/csh
 
setenv DSQUERY $1
setenv MGD $2
 
isql -S$DSQUERY -Umgd_public -Pmgdpub -w200 <<END > $0.rpt

use $MGD 
go

set nocount on
go

select * 
into #homology
from HMD_Homology_Marker
group by _Homology_key
having count(*) = 1
go

select h.*
into #keep
from #homology h, MRK_Marker m
where h._Marker_key = m._Marker_key
and m._Species_key in (1,18,22,37,34,19,21,48,58,10,47,9,20,13,44,39,35,11,40,2)
go

select h.*
into #dontkeep
from #homology h, MRK_Marker m
where h._Marker_key = m._Marker_key
and m._Species_key not in (1,18,22,37,34,19,21,48,58,10,47,9,20,13,44,39,35,11,40,2)
go

set nocount off
go

print ""
print "Homology References w/ Single Entries - Desired Species"
print ""
 
select r.symbol, r.commonName, r.jnum, r._Class_key
from #keep s, HMD_Homology_View r
where s._Homology_key = r._Homology_key
order by r._Class_key, r.symbol
go
 
print ""
print "Homology References w/ Single Entries - Undesired Species"
print ""
 
select r.symbol, r.commonName, r.jnum, r._Class_key
from #dontkeep s, HMD_Homology_View r
where s._Homology_key = r._Homology_key
order by r._Class_key, r.symbol
go
 
quit

END

