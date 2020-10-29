import sys 
import os
import db

db.setTrace()

#
# For references that satisfy the following conditions:
#
# iscurrent workflow status = Rejected for groups: A&P and GXD,
#
# iscurrent workflow status = Rejected or Not Routed for group: QTL
#
# [(iscurrent workflow status = Rejected for group: Tumor) OR (bib_workflow Tag = "Tumor:not selected")]
#
# columns for Report1

# jnumid
# mgiid
# list of tags for the reference (comma delimited)
#
# sort by mgiid
#

db.sql('''
select distinct m._refs_key
into temp table results
from BIB_Refs m
where exists (select 1 from bib_workflow_status s
        where m._refs_key = s._refs_key and s.isCurrent = 1
        and s._group_key in (31576664) and s._status_key in (31576672)
        )
and exists (select 1 from bib_workflow_status s
        where m._refs_key = s._refs_key and s.isCurrent = 1
        and s._group_key in (31576665) and s._status_key in (31576672)
        )
and exists (select 1 from bib_workflow_status s
        where m._refs_key = s._refs_key and s.isCurrent = 1
        and s._group_key in (31576668) and s._status_key in (31576672, 31576669)
        )
and (
        exists (select 1 from bib_workflow_status s
                where m._refs_key = s._refs_key and s.isCurrent = 1
                and s._group_key in (31576667) and s._status_key in (31576672)
                )
        or exists (select 1 from bib_workflow_tag s
                where m._refs_key = s._refs_key and s._tag_key in (3297031)
                )
)
''', None)

results = db.sql('''
select distinct s._refs_key, t.term
from results s, bib_workflow_tag wt, voc_term t
where s._refs_key = wt._refs_key
and wt._tag_key = t._term_key
order by s._refs_key
''', 'auto')

tagLookup = {};
for r in results:
    key = r['_refs_key']
    value = r['term']
    if key not in tagLookup:
        tagLookup[key] = []
    tagLookup[key].append(value)
        
results = db.sql('''
select distinct s._refs_key, c.jnumid, c.mgiid
from results s, bib_citation_cache c
where s._refs_key = c._refs_key
order by c.mgiid
''', 'auto')

for r in results:
    key = r['_refs_key']
    if key in tagLookup:
        print(r['jnumid'], r['mgiid'], ','.join(tagLookup[key]))
    else:
        print(r['jnumid'], r['mgiid'])

