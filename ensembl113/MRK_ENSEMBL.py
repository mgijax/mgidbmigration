
'''
#
# Report:
#       Produce a tab-delimited report with the following output fields:
#
#   1. ensembl_id
#   2. marker_mgi_id
#   3. marker_symbol
#   4. marker_name
#   5. marker_creation_date (Mon DD yyyy)
#   6. rawbiotype
#   7. feature_type
#   8. marker_pubmedid (if multiple, comma delimit in this column)
#   9. marker_jnumid (if multiple, comma delimit in this column)
#   10. marker_synonym (if multiple, comma delimit in this column)
#   11. chromosome
#   12. seq_start_coord (start coordinate of the Ensembl regulatory gene model)
#   13. seq_end_coord (end coordinate of the Ensembl regulatory gene model)
#   14. strand (strand of the Ensembl regulatory gene model)
#   15. provider (Ensembl Regulatory Feature)
#   16. length (sequence length)
#   17. seq_creation_date (Mon DD yyyy)
#   18. seq_description
#   
'''
 
import sys 
import os
import mgi_utils
import reportlib
import db

db.setTrace()

CRT = reportlib.CRT
TAB = reportlib.TAB

#
# Main
#

fp = reportlib.init(sys.argv[0], printHeading = None)

db.sql('''
      select a1.accID as mgi, 
      m.*,
      a2.accID as ensembl, a2._object_key as sequenceKey,
      mlc.genomicChromosome,
      to_char(m.creation_date, 'Mon DD YYYY') as cdate
      into temporary table markers
      from ACC_Accession a1, ACC_Accession a2, MRK_Marker m, MRK_Location_Cache mlc
      where a1._Object_key = a2._Object_key and 
      a1._Object_key = m._Marker_key and 
      a1._LogicalDB_key = 1 and 
      a1._MGIType_key = 2 and 
      a1.prefixPart = 'MGI:' and 
      a1.preferred = 1 and 
      a2._LogicalDB_key = 222 and 
      a2._MGIType_key = 2 and 
      m._Marker_key = mlc._Marker_key
    --and a1.accid in ('MGI:6903868', 'MGI:6903869', 'MGI:6899157', 'MGI:7138631')
        ''', None)
db.sql('create index markers_idx1 on markers(_Marker_key)', None)

#
# feature types
#
results = db.sql('''
        select m._marker_key, s.term 
        from markers m, MRK_MCV_Cache s 
        where m._marker_key = s._marker_key 
        and s.qualifier = 'D'
        ''', 'auto')
featureTypes = {}
for r in results:
        key = r['_marker_key']
        value = r['term']
        if key not in featureTypes:
                featureTypes[key] = []
        featureTypes[key].append(value)

#
# pubmedids
#
results = db.sql('''
        select m._marker_key, c.pubmedid
        from markers m, MGI_Reference_Assoc r, BIB_Citation_Cache c
        where m._marker_key = r._object_key 
        and r._mgitype_key = 2
        and r._refs_key = c._refs_key
        and c.pubmedid is not null
        ''', 'auto')
pubmedids = {}
for r in results:
        key = r['_marker_key']
        value = r['pubmedid']
        if key not in pubmedids:
                pubmedids[key] = []
        pubmedids[key].append(value)

#
# jnumids
#
results = db.sql('''
        select m._marker_key, c.jnumid
        from markers m, MGI_Reference_Assoc r, BIB_Citation_Cache c
        where m._marker_key = r._object_key 
        and r._mgitype_key = 2
        and r._refs_key = c._refs_key
        and c.jnumid is not null
        ''', 'auto')
jnumids = {}
for r in results:
        key = r['_marker_key']
        value = r['jnumid']
        if key not in jnumids:
                jnumids[key] = []
        jnumids[key].append(value)

#
# synonyms
#
results = db.sql('''
        select m._marker_key, s.synonym 
        from markers m, MGI_Synonym s
        where m._marker_key = s._object_key 
        and s._mgitype_key = 2
        ''', 'auto')
synonyms = {}
for r in results:
        key = r['_marker_key']
        value = r['synonym']
        if key not in synonyms:
                synonyms[key] = []
        synonyms[key].append(value)

#
# coordinates
#
results = db.sql('''	
    select m._marker_key,
           c.strand, 
           c.startCoordinate::int as startC,
           c.endCoordinate::int as endC,
           c.provider,
           s.length,
           to_char(s.creation_date, 'Mon DD YYYY') as cdate,
           s.description
    from markers m, MRK_Location_Cache c, SEQ_Sequence s
    where m._marker_key = c._marker_key
        and m.sequenceKey = s._sequence_key
        ''', 'auto')
coords = {}
for r in results:
    key = r['_marker_key']
    value = r
    if key not in coords:
        coords[key] = []
    coords[key].append(value)

#
# biotype
#
results = db.sql('''
        select distinct m._Marker_key, s.rawbiotype 
        from markers m, SEQ_Marker_Cache s 
        where m._Marker_key = s._Marker_key 
        and s.rawbiotype is not null
        ''', 'auto')
bioTypes = {}
for r in results:
        key = r['_Marker_key']
        value = r['rawbiotype']
        if key not in bioTypes:
                bioTypes[key] = []
        bioTypes[key].append(value)

results = db.sql('select * from markers order by genomicChromosome, symbol', 'auto')

for r in results:

    #   1. ensembl_id
    #   2. marker_mgi_id
    #   3. marker_symbol
    #   4. marker_name
    #   5. marker_creation_date (Mon DD yyyy)

    if r['genomicChromosome']:
            chromosome = r['genomicChromosome']
    else:
            chromosome = r['chromosome']

    fp.write(r['ensembl'] + TAB +
            r['mgi'] + TAB + 
            r['symbol'] + TAB + 
            r['name'] + TAB +
            r['cdate'] + TAB)

    #   6. rawbiotype
    if r['_Marker_key'] in bioTypes:	
        fp.write(','.join(bioTypes[r['_Marker_key']]))
    fp.write(TAB)

    #   7. feature_type
    if r['_Marker_key'] in featureTypes:	
        fp.write(','.join(featureTypes[r['_Marker_key']]))
    fp.write(TAB)

    #   8. marker_pubmedid (if multiple, comma delimit in this column)
    #   9. marker_jnumid (if multiple, comma delimit in this column)
    #   10. marker_synonym (if multiple, comma delimit in this column)

    if r['_Marker_key'] in pubmedids:	
        fp.write(','.join(pubmedids[r['_Marker_key']]))
    fp.write(TAB)

    if r['_Marker_key'] in jnumids:	
        fp.write(','.join(jnumids[r['_Marker_key']]))
    fp.write(TAB)

    if r['_Marker_key'] in synonyms:	
        fp.write(','.join(synonyms[r['_Marker_key']]))
    fp.write(TAB)

    #   11. chromosome
    fp.write(chromosome + TAB)

    #   12. seq_start_coord (start coordinate of the Ensembl regulatory gene model)
    #   13. seq_end_coord (end coordinate of the Ensembl regulatory gene model)
    #   14. strand (strand of the Ensembl regulatory gene model)
    #   15. provider (Ensembl Regulatory Feature)
    #   16. length (sequence length)
    #   17. seq_creation_date (Mon DD yyyy)
    #   18. seq_description

    if key in coords:
        fp.write(mgi_utils.prvalue(coords[r['_Marker_key']][0]['startC']) + TAB)
        fp.write(mgi_utils.prvalue(coords[r['_Marker_key']][0]['endC']) + TAB)
        fp.write(mgi_utils.prvalue(coords[r['_Marker_key']][0]['strand']) + TAB)
        fp.write(mgi_utils.prvalue(coords[r['_Marker_key']][0]['provider']) + TAB)
        fp.write(mgi_utils.prvalue(str(coords[r['_Marker_key']][0]['length'])) + TAB)
        fp.write(mgi_utils.prvalue(coords[r['_Marker_key']][0]['cdate']) + TAB)
        fp.write(mgi_utils.prvalue(coords[r['_Marker_key']][0]['description']) + TAB)
    else:
        fp.write(TAB + TAB + TAB + TAB + TAB + TAB + TAB)

    fp.write(CRT)

reportlib.finish_nonps(fp)
