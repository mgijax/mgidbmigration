import sys 
import os
import db
import reportlib

db.setTrace()

fp = reportlib.init(sys.argv[0], printHeading = None)

fp.write('#jnumid\n')
fp.write('#mgiid\n')
fp.write('#list of tags\n')
fp.write('#count of markers\n')
fp.write('#count of alleles\n')
fp.write('#count of probes\n')
fp.write('#count of strains\n')
fp.write('#count of sequences\n')
fp.write('#count of antibodies\n')
fp.write('#\n')

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

# tags
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

# markers 
results = db.sql('''
select distinct s._refs_key, t._marker_key
from results s, mrk_reference t
where s._refs_key = t._refs_key
''', 'auto')
markerLookup = {};
for r in results:
    key = r['_refs_key']
    value = r['_marker_key']
    if key not in markerLookup:
        markerLookup[key] = []
    markerLookup[key].append(value)
#print(markerLookup)

# alleles, 
results = db.sql('''
select distinct s._refs_key, t._object_key
from results s, mgi_reference_assoc t
where s._refs_key = t._refs_key
and t._mgitype_key = 11
''', 'auto')
alleleLookup = {};
for r in results:
    key = r['_refs_key']
    value = r['_object_key']
    if key not in alleleLookup:
        alleleLookup[key] = []
    alleleLookup[key].append(value)
#print(alleleLookup)

# probes
results = db.sql('''
select distinct s._refs_key, t._probe_key
from results s, prb_reference t
where s._refs_key = t._refs_key
''', 'auto')
probeLookup = {};
for r in results:
    key = r['_refs_key']
    value = r['_probe_key']
    if key not in probeLookup:
        probeLookup[key] = []
    probeLookup[key].append(value)
#print(probeLookup)

# strains
results = db.sql('''
select distinct s._refs_key, t._object_key
from results s, mgi_reference_assoc t
where s._refs_key = t._refs_key
and t._mgitype_key = 10
''', 'auto')
strainLookup = {};
for r in results:
    key = r['_refs_key']
    value = r['_object_key']
    if key not in strainLookup:
        strainLookup[key] = []
    strainLookup[key].append(value)
#print(strainLookup)

# sequences
results = db.sql('''
select distinct s._refs_key, t._object_key
from results s, mgi_reference_assoc t
where s._refs_key = t._refs_key
and t._mgitype_key = 6
''', 'auto')
sequenceLookup = {};
for r in results:
    key = r['_refs_key']
    value = r['_object_key']
    if key not in sequenceLookup:
        sequenceLookup[key] = []
    sequenceLookup[key].append(value)
#print(sequenceLookup)

# antibodies
results = db.sql('''
select distinct s._refs_key, t._object_key
from results s, mgi_reference_assoc t
where s._refs_key = t._refs_key
and t._mgitype_key = 6
''', 'auto')
antibodyLookup = {};
for r in results:
    key = r['_refs_key']
    value = r['_object_key']
    if key not in antibodyLookup:
        antibodyLookup[key] = []
    antibodyLookup[key].append(value)
#print(antibodyLookup)

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

    fp.write(str(r['jnumid']) + '\t' + r['mgiid'] + '\t')

    if key in tagLookup:
        fp.write(','.join(tagLookup[key]) + '\t')
    else:
        fp.write('\t')

    if key in markerLookup:
        fp.write(str(len(markerLookup[key])) + '\t')
    else:
        fp.write('0\t')

    if key in alleleLookup:
        fp.write(str(len(alleleLookup[key])) + '\t')
    else:
        fp.write('0\t')

    if key in probeLookup:
        fp.write(str(len(probeLookup[key])) + '\t')
    else:
        fp.write('0\t')

    if key in strainLookup:
        fp.write(str(len(strainLookup[key])) + '\t')
    else:
        fp.write('0\t')

    if key in sequenceLookup:
        fp.write(str(len(sequenceLookup[key])) + '\t')
    else:
        fp.write('0\t')

    if key in antibodyLookup:
        fp.write(str(len(antibodyLookup[key])) + '\t')
    else:
        fp.write('0\t')

    fp.write('\n')

reportlib.finish_nonps(fp)      # non-postscript file


