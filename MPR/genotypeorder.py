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

db.sql('select distinct ap._Genotype_key, ap._Marker_key, ap._Allele_key_1, t.term, a.isWildType ' + \
	'into #alleles ' + \
	'from GXD_AllelePair ap, VOC_Term t, ALL_Allele a ' + \
	'where ap._PairState_key = t._Term_key ' + \
	'and ap._Allele_key_1 = a._Allele_key ' + \
	'union ' + \
	'select distinct ap._Genotype_key, ap._Marker_key, ap._Allele_key_2, t.term, a.isWildType ' + \
	'from GXD_AllelePair ap, VOC_Term t, ALL_Allele a ' + \
	'where ap._Allele_key_2 is not null ' + \
	'and ap._PairState_key = t._Term_key ' + \
	'and ap._Allele_key_2 = a._Allele_key ', None)
db.sql('create index idx1 on #alleles(_Genotype_key)', None)
db.sql('create index idx2 on #alleles(_Allele_key_1)', None)

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

results = db.sql('select * from #alleles order by _Allele_key_1, _Genotype_key', 'auto')
alleles = {}
for r in results:
    key = r['_Allele_key_1']
    value = r

    if not alleles.has_key(key):
	alleles[key] = []
    alleles[key].append(r)

for a in alleles.keys():

    for r in alleles[a]:

        genotype = r['_Genotype_key']
        marker = r['_Marker_key']
        alleleState = r['term']
        alleleWildType = r['isWildType']
	sequenceNum = 8

	if genotype in isSimple:
	    if alleleState == 'Homozygous':
	        sequenceNum = 1
	    elif alleleState == 'Heterozygous' and alleleWildType == 1:
	        sequenceNum = 2
	    elif alleleState == 'Heterozygous' and alleleWildType == 0:
	        sequenceNum = 3
	    elif alleleState == 'Hemizygous X-linked':
	        sequenceNum = 4
	    elif alleleState == 'Hemizygous Y-linked':
	        sequenceNum = 5
	    elif alleleState == 'Hemizygous Insertion':
	        sequenceNum = 6
	    elif alleleState == 'Indeterminate':
	        sequenceNum = 7

	fp.write(str(genotype) + TAB)
	fp.write(str(marker) + TAB)
	fp.write(str(a) + TAB)
	fp.write(str(sequenceNum) + TAB)
	fp.write("1000" + TAB + "1000" + TAB)
	fp.write(loaddate + TAB + loaddate + CRT)

reportlib.finish_nonps(fp)	# non-postscript file

