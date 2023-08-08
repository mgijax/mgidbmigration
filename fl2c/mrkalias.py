#
# create contrdatasets/misc/STSMarker/STSMarker.txt
#
 
import sys 
import os
import db
import reportlib
import mgi_utils

db.setTrace()

CRT = reportlib.CRT
SPACE = reportlib.SPACE
TAB = reportlib.TAB
PAGE = reportlib.PAGE

#
# Main
#

db.sql('update mrk_alias set _marker_key = 1477664 where _marker_key = 18476', None)
db.sql('update mrk_alias set _alias_key = 1477664 where _alias_key = 18476', None)
#db.sql('insert into mrk_alias values (387770,5045,now(),now())', None)
db.commit()

fp = reportlib.init(sys.argv[0], printHeading = None)

fp.write(mgi_utils.date() + 2*CRT)

fp.write('''
This report lists MGI-curated relationships between STS markers and genome features (genes, pseudogenes, other genome features, etc.).  Coordinates listed reflect the coordinates in MGI at the time the report was created (from mouse genome build GRCm39).
''' + 2*CRT)

fp.write('GF MGI ID' + TAB)
fp.write('GF symbol' + TAB)
fp.write('GF type' + TAB)
fp.write('GF chr' + TAB)
fp.write('GF start coordinate (genome build: GRCm39)' + TAB)
fp.write('GF end coordinate (genome build: GRCm39)' + TAB)
fp.write('GF strand' + TAB)
fp.write('GF cytogenetic offset' + TAB)
fp.write('GF CM offset' + TAB)
fp.write('STS MGI ID' + TAB)
fp.write('STS symbol' + TAB)
fp.write('STS chr' + TAB)
fp.write('STS start coordinate (genome build: GRCm39)' + TAB)
fp.write('STS end coordinate (genome build: GRCm39)' + TAB)
fp.write('STS cytogenetic offset' + TAB)
fp.write('STS CM offset' + CRT)

cmd = '''
select 
a1.accid as accid1, 
m1.symbol as symbol1, 
mcv1.directterms as directterm1, 
l1.chromosome as chr1, 
l1.startcoordinate as s1, 
l1.endcoordinate as e1, 
l1.strand as strand1, 
l1.cytogeneticoffset as cyto1, 
l1.cmoffset as cm1, 
a2.accid as accid2, 
m2.symbol as symbol2, 
l2.chromosome as chr2, 
l2.startcoordinate as s2, 
l2.endcoordinate as e2, 
l2.strand as strand2, 
l2.cytogeneticoffset as cyto2, 
l2.cmoffset as cm2
from MRK_Alias a, MRK_Marker m1, MRK_Marker m2, MRK_MCV_Cache mcv1, MRK_MCV_Cache mcv2, MRK_Location_Cache l1, MRK_Location_Cache l2,
ACC_Accession a1, ACC_Accession a2
where a._alias_key = m1._marker_key
and a._marker_key = m2._marker_key
and m1._marker_type_key in (1,7,9,10)
and m2._marker_type_key in (2,3,8)
and m1._marker_key = mcv1._marker_key
and mcv1.qualifier = 'D'
and m2._marker_key = mcv2._marker_key
and mcv2.qualifier = 'D'
and m1._marker_key = l1._marker_key
and m2._marker_key = l2._marker_key
and m1._marker_key = a1._object_key
and a1._logicaldb_key = 1
and a1._mgitype_key = 2
and a1.preferred = 1
and m2._marker_key = a2._object_key
and a2._logicaldb_key = 1
and a2._mgitype_key = 2
and a2.preferred = 1
order by m1.symbol
'''

results = db.sql(cmd, 'auto')

for r in results:
    if r['symbol1'] == 'Dag1' and r['symbol2'] == 'Dag1':
        continue
    if r['symbol1'] == 'Gabrb1' and r['symbol2'] == 'Commd8':
        continue
    if r['symbol1'] == 'Commd8' and r['symbol2'] == 'Gabrb1':
        continue
    if r['symbol1'] == 'Hpvc-ps' and r['symbol2'] == 'D5Mit30':
        continue
    if r['symbol1'] == 'D5Mit30' and r['symbol2'] == 'Hpvc-ps':
        continue

    fp.write(r['accid1'] + TAB)
    fp.write(r['symbol1'] + TAB)
    fp.write(r['directterm1'] + TAB)
    fp.write(r['chr1'] + TAB)

    if r['s1'] != None:
        fp.write(str(r['s1']))
    fp.write(TAB)

    if r['e1'] != None:
        fp.write(str(r['e1']))
    fp.write(TAB)

    if r['strand1'] != None:
        fp.write(str(r['strand1']))
    fp.write(TAB)

    if r['cyto1'] != None:
        fp.write(str(r['cyto1']))
    fp.write(TAB)

    if r['cm1'] != None:
        fp.write(str(r['cm1']))
    fp.write(TAB)

    fp.write(r['accid2'] + TAB)
    fp.write(r['symbol2'] + TAB)
    fp.write(r['chr2'] + TAB)

    if r['s2'] != None:
        fp.write(str(r['s2']))
    fp.write(TAB)

    if r['e2'] != None:
        fp.write(str(r['e2']))
    fp.write(TAB)

    if r['strand2'] != None:
        fp.write(str(r['strand2']))
    fp.write(TAB)

    if r['cyto2'] != None:
        fp.write(str(r['cyto2']))
    fp.write(TAB)

    if r['cm2'] != None:
        fp.write(str(r['cm2']))
    fp.write(CRT)

reportlib.finish_nonps(fp)	# non-postscript file

