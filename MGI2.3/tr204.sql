#!/bin/csh
 
setenv DSQUERY $1
setenv STRAINS	$2
setenv MGD	$3

isql -S$DSQUERY -Umgd_public -Pmgdpub -w200 <<END > $0.rpt

use $STRAINS
go

print ""
print "Strains in MGD but not in MLP"
print ""

select s.*
from $MGD..PRB_Strain s
where not exists (select m.* from MLP_Strain m
where s._Strain_key = m._Strain_key)
go

quit

END

