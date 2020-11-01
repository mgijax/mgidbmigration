import sys 
import os
import db
import reportlib

db.setTrace()

fp = reportlib.init(sys.argv[0], printHeading = None)

#
# For references that satisfy the following conditions:
#
# iscurrent workflow status = Rejected for groups: A&P, GXD, GO
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
# *data_tag set
# AP:DiseaseReview
# AP:NewTransgene
# AP:strains
# MGI:mapping
# MGI:markers
# MGI:nomen_selected
# MGI:PRO_selected
# MGI:PRO_used
# MGI:probe
# 
# **mgi_data type set
# markers
# alleles
# probes
# strains
# sequences
# antibodies
#
# sort by mgiid
#

db.sql('''
select distinct m._refs_key
into temp table results
from BIB_Refs m
where m.isDiscard = 0
and m._referencetype_key = 31576687
and exists (select 1 from bib_workflow_status s
        where m._refs_key = s._refs_key and s.isCurrent = 1
        and s._group_key in (31576664) and s._status_key in (31576672)
        )
and exists (select 1 from bib_workflow_status s
        where m._refs_key = s._refs_key and s.isCurrent = 1
        and s._group_key in (31576665) and s._status_key in (31576672)
        )
and exists (select 1 from bib_workflow_status s
        where m._refs_key = s._refs_key and s.isCurrent = 1
        and s._group_key in (31576666) and s._status_key in (31576672)
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
and (
        exists (select 1 from bib_workflow_tag wt, voc_term t
                where m._refs_key = wt._refs_key
                and wt._tag_key = t._term_key
                and t.term in (
                'AP:DiseaseReview',
                'AP:NewTransgene',
                'AP:strains',
                'MGI:mapping',
                'MGI:markers',
                'MGI:nomen_selected',
                'MGI:PRO_selected',
                'MGI:PRO_used',
                'MGI:probe'
                )
        )
        or ( 
                exists (select 1 from mrk_reference t where m._refs_key = t._refs_key)
                or exists (select 1 from prb_reference t where m._refs_key = t._refs_key)
                or exists (select 1 from mgi_reference_assoc t where m._refs_key = t._refs_key and t._mgitype_key = 11)
                or exists (select 1 from mgi_reference_assoc t where m._refs_key = t._refs_key and t._mgitype_key = 10)
                or exists (select 1 from mgi_reference_assoc t where m._refs_key = t._refs_key and t._mgitype_key = 19)
                or exists (select 1 from mgi_reference_assoc t where m._refs_key = t._refs_key and t._mgitype_key = 6)
        )
)
''', None)

#
# final
#

results = db.sql('''
select distinct s._refs_key, c.jnumid, c.mgiid
from results s, bib_citation_cache c
where s._refs_key = c._refs_key
order by c.mgiid
''', 'auto')

for r in results:
    key = r['_refs_key']
    fp.write(str(r['jnumid']) + '\t' + r['mgiid'] + '\n')

reportlib.finish_nonps(fp)      # non-postscript file


