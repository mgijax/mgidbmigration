#!/usr/local/bin/python

'''
#
# Report:
#       Report of OMIM/HPO annotations --> MP/HPO relationships
# OMIM - HPO
#
# History:
#
# jsb	05/17/2016
#	- created
#
'''
 
import sys 
import os
import db
import reportlib

db.setTrace()
db.setAutoTranslate(False)
db.setAutoTranslateBE(False)

CRT = reportlib.CRT
SPACE = reportlib.SPACE
TAB = reportlib.TAB
PAGE = reportlib.PAGE

#
# Main
#

db.useOneConnection(1)

# closure table for HPO terms, including term to itself
db.sql('''select _AncestorObject_key, _DescendentObject_key
    into temp table hpo_closure
    from dag_closure dc, voc_term t
    where dc._DescendentObject_key = t._Term_key
      and t._Vocab_key = 106
    union all
    select t._Term_key, t._Term_key
    from voc_term t
    where t._Vocab_key = 106''', None)

db.sql('''create index hc1 on hpo_closure(_AncestorObject_key)''', None)

db.sql('''create index hc2 on hpo_closure(_DescendentObject_key)''', None)

# mapping from OMIM term to HPO terms
db.sql('''select _Object_key as omimKey, _Term_key as hpoKey,  ve._EvidenceTerm_key
    into temp table hpo2omim
    from voc_annot va, voc_evidence ve
    where va._AnnotType_key = 1018
	and va._Annot_key = ve._Annot_key''', None)

db.sql('''create index ho1 on hpo2omim (omimKey)''', None)

db.sql('''create index ho2 on hpo2omim (hpoKey)''', None)

# mapping from HPO high-level terms to MP headers
db.sql('''select r._Object_key_1 as mpKey, r._Object_key_2 as hpoKey
    into temp table mp2hpo
    from mgi_relationship r
    where r._Category_key = 1005''', None)

db.sql('''create index mh1 on mp2hpo(mpKey)''', None)

db.sql('''create index mh2 on mp2hpo(hpoKey)''', None)

# mapping from every HPO term to the MP headers of its ancestors
# and itself
# select distinct hp._DescendentObject_key as hpoKey, mh.mpKey
db.sql('''select distinct hp._DescendentObject_key as hpoKey, mh.mpKey
    into temp table mp2hpo_all
    from hpo_closure hp, mp2hpo mh
    where hp._AncestorObject_key = mh.hpoKey''', None)

db.sql('''create index mha1 on mp2hpo_all(hpoKey)''', None)

#  select distinct hp._DescendentObject_key, null::int
# add in those HPO terms that do not map to an MP header
db.sql('''insert into mp2hpo_all
    select distinct hp._DescendentObject_key, null::int
    from hpo_closure hp
    where not exists (select 1 from mp2hpo_all ma
      where ma.hpoKey = hp._DescendentObject_key)''', None)

# primary IDs for vocab terms (MP, HPO, OMIM)
db.sql('''select a._Object_key as _Term_key, a.accID
    into temp table term_ids
    from acc_accession a, voc_term t
    where a._MGIType_key = 13
    and a.preferred = 1
    and a._Object_key = t._Term_key
    and t._Vocab_key in (44, 106, 5)''', None)

db.sql('''create index ti1 on term_ids(_Term_key)''', None)

# entrez gene IDs for human markers
db.sql('''select _Object_key as _Marker_key, accID as entrezgene_id, m.symbol
    into temp table human
    from acc_accession a, mrk_marker m
    where a._MGIType_key = 2
    and a.preferred = 1
    and a._LogicalDB_key = 55
    and a._Object_key = m._Marker_key
    and m._Organism_key = 2''', None)

db.sql('''create index egi1 on human(_Marker_key)''', None)

# pull it all together
# select distinct  omim_id.accID as omimID, omim.term as omimTerm,
results = db.sql('''select omim_id.accID as omimID, vt.term as omimTerm,
      h.entrezgene_id as egID, h.symbol,
      mp_id.accID as mpID, mp.term as mpTerm,
      hp_id.accID as hpID, hp.term as hpTerm
    from voc_term vt
    inner join term_ids omim_id on (vt._Term_key = omim_id._Term_key)
    left outer join voc_annot va on (vt._Term_key = va._Term_key
      and va._AnnotType_key = 1006)
    left outer join human h on (va._Object_key = h._Marker_key)
    left outer join hpo2omim on (vt._Term_key = hpo2omim.omimKey)
    left outer join mp2hpo_all mha on (hpo2omim.hpoKey = mha.hpoKey)
    left outer join voc_term mp on (mha.mpKey = mp._Term_key)
    left outer join term_ids mp_id on (mha.mpKey = mp_id._Term_key)
    left outer join term_ids hp_id on (hpo2omim.hpoKey = hp_id._Term_key)
    left outer join voc_term hp on (hpo2omim.hpoKey = hp._Term_key)
    where vt._Vocab_key = 44
    order by 2, 4, 8, 6''', 'auto')

fp = reportlib.init(sys.argv[0], printHeading = None)

fp.write('omimID%somimTerm%segID%shumanSymbol%smpID%smpTerm%shpID%shpTerm%s' %(TAB, TAB, TAB, TAB, TAB, TAB, TAB, CRT))
for r in results:

    	omimTerm = r['omimTerm']
	omimID = r['omimID']

	symbol = r['symbol']
	if symbol == None:
	    symbol = ''

	egID = r['egID']
	if egID == None:
	    egID = ''

	mpID = r['mpID']
	if mpID == None:
	    mpID = ''

	mpTerm = r['mpTerm']
	if mpTerm == None:
	    mpTerm = ''

	hpID = r['hpID']
	if hpID == None:
	    hpID = ''
	hpTerm = r['hpTerm']
	if hpTerm == None:
	    hpTerm = ''

	fp.write('%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s' % (omimID, TAB, omimTerm, TAB, egID, TAB, symbol, TAB, mpID, TAB, mpTerm, TAB, hpID, TAB, hpTerm, CRT))
	
reportlib.finish_nonps(fp)	# non-postscript file
db.useOneConnection(0)

