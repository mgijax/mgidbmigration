#!/bin/csh
 
#
# Template for SQL report
#
# TR 327
#	List of Mapping Text References which contain multiple instances
#	of competing search terms
#
# Notes:
#	- all public reports require a header and trailer
#	- all private reports require a header
#
# Usage:
#	MappingText.sql MGD mgd
#


setenv DSQUERY $1
setenv MGD $2

/mgi/se/customSQL/bin/header.sh $0

isql -S$DSQUERY -Umgd_public -Pmgdpub -w200 <<END >> $0.rpt

use $MGD
go

select e._Expt_key, type = "physical"
into #all
from MLD_Expts e, MLD_Expt_Notes n
where e.exptType = "TEXT"
and e._Expt_key = n._Expt_key
and (n.note like '%physical%' or n.note like '%overlapping%')
union
select e._Expt_key, type = "cyto"
from MLD_Expts e, MLD_Expt_Notes n
where e.exptType = "TEXT"
and e._Expt_key = n._Expt_key
and (n.note like '%somatic%' or n.note like '%fish%' or n.note like '%situ%')
union
select e._Expt_key, type = "qtl"
from MLD_Expts e, MLD_Expt_Notes n
where e.exptType = "TEXT"
and e._Expt_key = n._Expt_key
and (n.note like '%QTL%' or n.note like '%quantitative%')
union
select e._Expt_key, type = "cross"
from MLD_Expts e, MLD_Expt_Notes n
where e.exptType = "TEXT"
and e._Expt_key = n._Expt_key
and (n.note like '%cross%' or n.note like '%EUCIB%' or n.note like '%JAX%')
go
 
/* Select Experiments of type TEXT which belong to more than one category */
 
select distinct _Expt_key, type
into #exclude
from #all
group by _Expt_key
having count(*) > 1
go
 
print ""
print "References which contain search terms from more than one category"
print ""
 
select distinct b.jnum, e.type, substring(m.exptType,1,10), m.tag, a.accID
from #exclude e, MLD_Expts m, BIB_All_View b, MLD_Acc_View a
where e._Expt_key = m._Expt_key
and m._Refs_key = b._Refs_key
and m._Expt_key = a._Object_key
and a.preferred = 1
order by b.jnum
go
 
quit

END

cat /mgi/se/customSQL/bin/trailer >> $0.rpt

