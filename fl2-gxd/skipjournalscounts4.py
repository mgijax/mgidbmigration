import sys 
import os
import db
import reportlib

# Report 4 (the easy one)
# 
# Column1:  journals with articles (all types) added to the database in the last 5 reference years (2018-Present)
# 
# Column 2: total number of articles from this journal added in the last 5 years
# 
# Column 3: total number of articles from this journal used by GXD last 5 years (indexed/full coded/etc).
# 
# (I am looking for journals that gets lots of papers added to the database but very few of them are for GXD.)
#

db.setTrace()

CRT = reportlib.CRT
SPACE = reportlib.SPACE
TAB = reportlib.TAB
PAGE = reportlib.PAGE

db.sql('''
select r.journal, count(r.journal) as totalAll
into temp table results1
from bib_refs r
where r.journal is not null
and r.year between 2018 and 2022
group by r.journal
''', None)

results = db.sql('''
select r.journal, count(r.journal) as totalGXD
into temp table results2
from bib_refs r, bib_workflow_status s
where r.journal is not null
and r.year between 2018 and 2022
and r._refs_key = s._refs_key
and s.isCurrent = 1
and s._group_key = 31576665
and s._status_key in (31576673,31576674)
group by r.journal
''', None)

results = db.sql('''
select r1.*, r2.totalGXD
from results1 r1, results2 r2
where r1.journal = r2.journal
union
select r1.*, 0
from results1 r1
where not exists (select 1 from results2 r2 where r1.journal = r2.journal)
order by journal
''', 'auto')

fp = reportlib.init(sys.argv[0], printHeading = None)
for r in results:
    fp.write(r['journal'] + TAB)
    fp.write(str(r['totalAll']) + TAB)
    fp.write(str(r['totalGXD']) + CRT)

reportlib.finish_nonps(fp)	# non-postscript file

