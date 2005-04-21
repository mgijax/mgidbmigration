#!/usr/local/bin/python

import sys 
import string
import db
import reportlib
import loadlib

CRT = reportlib.CRT
SPACE = reportlib.SPACE
TAB = reportlib.TAB
PAGE = reportlib.PAGE

loaddate = loadlib.loaddate

#
# Main
#

fp = reportlib.init('genotypeorder', printHeading = 0)

# select all unique Genotype, Marker, Allele triplets

db.sql('select distinct ap._Genotype_key, ap._Marker_key, ap._Allele_key_1, t.term, ap._AllelePair_key, s.strain ' + \
	'into #alleles ' + \
	'from GXD_AllelePair ap, VOC_Term t, GXD_Genotype g, PRB_Strain s ' + \
	'where ap._PairState_key = t._Term_key ' + \
	'and ap._Genotype_key = g._Genotype_key ' + \
	'and g._Strain_key = s._Strain_key ' + \
	'union ' + \
	'select distinct ap._Genotype_key, ap._Marker_key, ap._Allele_key_2, t.term, ap._AllelePair_key, s.strain ' + \
	'from GXD_AllelePair ap, VOC_Term t, GXD_Genotype g, PRB_Strain s ' + \
	'where ap._Allele_key_2 is not null ' + \
	'and ap._PairState_key = t._Term_key ' + \
	'and ap._Genotype_key = g._Genotype_key ' + \
	'and g._Strain_key = s._Strain_key ', None)
db.sql('create index idx1 on #alleles(_Genotype_key)', None)
db.sql('create index idx2 on #alleles(_Allele_key_1)', None)

# select all allele pairs that contain a wild type allele
results = db.sql('select distinct a._AllelePair_key from #alleles a, GXD_AllelePair ap, ALL_Allele l ' + \
	'where a._AllelePair_key = ap._AllelePair_key ' + \
	'and ap._Allele_key_1 = l._Allele_key and l.isWildType = 1 ' + \
	'union ' + \
	'select distinct a._AllelePair_key from #alleles a, GXD_AllelePair ap, ALL_Allele l ' + \
	'where a._AllelePair_key = ap._AllelePair_key ' + \
	'and ap._Allele_key_2 = l._Allele_key and l.isWildType = 1 ', 'auto')
isWildType = []
for r in results:
    isWildType.append(r['_AllelePair_key'])

# select the simple genotypes, those that have only one allele pair

results = db.sql('select distinct _Genotype_key from GXD_AllelePair group by _Genotype_key having count(*) = 1', 'auto')
isSimple = []
for r in results:
    isSimple.append(r['_Genotype_key'])

# select the complex genotypes, those that have > 1 allele pair

results = db.sql('select distinct _Genotype_key from GXD_AllelePair group by _Genotype_key having count(*) > 1', 'auto')
isComplex = []
for r in results:
    isComplex.append(r['_Genotype_key'])

results = db.sql('select * from #alleles order by _Allele_key_1, strain', 'auto')
alleles = {}
for r in results:
    key = r['_Allele_key_1']
    value = r

    if not alleles.has_key(key):
	alleles[key] = []
    alleles[key].append(r)

for a in alleles.keys():

    homoSeq = 0
    hetero1Seq = 10
    hetero2Seq = 20
    hemiXSeq = 30
    hemiYSeq = 40
    hemiISeq = 50
    indetSeq = 60
    simpleSeq = 70
    complexSeq = 80

    for r in alleles[a]:

        genotype = r['_Genotype_key']
        marker = r['_Marker_key']
        alleleState = r['term']
	allelePair = r['_AllelePair_key']

	if genotype in isSimple:
	    if alleleState == 'Homozygous':
	        sequenceNum = homoSeq
		homoSeq = homoSeq + 1
	    elif alleleState == 'Heterozygous' and allelePair in isWildType:
	        sequenceNum = hetero1Seq
		hetero1Seq = hetero1Seq + 1
	    elif alleleState == 'Heterozygous' and allelePair not in isWildType:
	        sequenceNum = hetero2Seq
		hetero2Seq = hetero2Seq + 1
	    elif alleleState == 'Hemizygous X-linked':
	        sequenceNum = hemiXSeq
		hemiXSeq = hemiXSeq + 1
	    elif alleleState == 'Hemizygous Y-linked':
	        sequenceNum = hemiYSeq
		hemiYSeq = hemiYSeq + 1
	    elif alleleState == 'Hemizygous Insertion':
	        sequenceNum = hemiISeq
		hemiISeq = hemiISeq + 1
	    elif alleleState == 'Indeterminate':
	        sequenceNum = indetSeq
		indetSeq = indetSeq + 1
	    else:
	        sequenceNum = simpleSeq
		simpleSeq = simpleSeq + 1
	else:
	    sequenceNum = complexSeq
	    complexSeq = complexSeq + 1

	fp.write(str(genotype) + TAB)
	fp.write(str(marker) + TAB)
	fp.write(str(a) + TAB)
	fp.write(str(sequenceNum) + TAB)
	fp.write("1000" + TAB + "1000" + TAB)
	fp.write(loaddate + TAB + loaddate + CRT)

reportlib.finish_nonps(fp)	# non-postscript file

