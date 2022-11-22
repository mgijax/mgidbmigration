import sys 
import os
import db
import reportlib

# Report 5
#
# I am interested in the papers that have been added to the database since the relevance score was added.  
# (I think that was ~5/21/2021.)  That was when papers started to be “routed” to GXD.
#
# What I would like to know is which journals have a 100% rejection rate when routed to GXD.  
#
# In the papers' history status they should have been routed to GXD at some point and their current status is Rejected.  
# What is the number of papers rejected/journal over this time period and which journals have a 100% rejection rate?  
#
# If you can combine this with the total number of database papers over this period, that is fine, but I could use the existing reports to figure that out.
#
# For this report we wouldn’t use reference date, we’d use date added to the database (since they’d be routed/not routed).
#
# This allows us to focus on the papers that the GXD curators had to review.  
# If journal X adds 1000 papers to the database, but none of them get routed to GXD, 
# we don’t really care.  But if journal Y adds 100 papers to the database, 75 are routed to GXD, and all of them are rejects--that’s what we want to know.
#
#
# journl #routed by GXD #rejected by GXD
#

db.setTrace()

CRT = reportlib.CRT
SPACE = reportlib.SPACE
TAB = reportlib.TAB
PAGE = reportlib.PAGE

db.sql('''
select r.journal, count(*) as totalRouted
into temp table results1
from bib_refs r, bib_workflow_status s
where r.journal is not null
and r.creation_date::date >= '05/21/2021'
and r._refs_key = s._refs_key
and s.isCurrent = 0
and s._group_key = 31576665
and s._status_key = 31576670
group by r.journal
''', None)

db.sql('''
select r.journal, count(*) as totalRejected
into temp table results2
from bib_refs r, bib_workflow_status s
where r.journal is not null
and r.creation_date::date >= '05/21/2021'
and r._refs_key = s._refs_key
and s.isCurrent = 1
and s._group_key = 31576665
and s._status_key = 31576672
group by r.journal
''', None)

results = db.sql('''
(
select r1.journal, r1.totalRouted, r2.totalRejected
from results1 r1, results2 r2
where r1.journal = r2.journal
union
select r1.journal, r1.totalRouted, 0
from results1 r1
where not exists (select 1 from results2 r2 where r1.journal = r2.journal)
)
order by journal
''', 'auto')

fp = reportlib.init(sys.argv[0], printHeading = None)
fp.write('# 1: journal' + CRT)
fp.write('# 2: total routed' + CRT)
fp.write('# 3: total rejected' + CRT)
for r in results:
    fp.write(r['journal'] + TAB)
    fp.write(str(r['totalRouted']) + TAB)
    fp.write(str(r['totalRejected']) + CRT)

reportlib.finish_nonps(fp)	# non-postscript file

