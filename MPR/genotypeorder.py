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

# strain ordering

db.sql('select ap._Genotype_key, ap._Allele_key_1, ap._Allele_key_2, p._Strain_key, s.strain ' + \
	'into #allelepairs ' + \
	'from GXD_AllelePair ap, GXD_Genotype p, PRB_Strain s ' + \
	'where ap._Genotype_key = p._Genotype_key ' + \
	'and p._Strain_key = s._Strain_key ', None)

db.sql('select distinct _Allele_key_1, _Allele_key_2, _Strain_key, strain into #uniqap from #allelepairs', None)

db.sql('select * into #orderbystrain from #uniqap group by _Allele_key_1, _Allele_key_2 having count(*) > 1', None)

results = db.sql('select distinct a._Genotype_key, a._Allele_key_1 ' + \
	'from #orderbystrain s, #allelepairs a ' + \
	'where s._Allele_key_1 = a._Allele_key_1 ' + \
	'and s._Allele_key_2 = a._Allele_key_2 ' + \
	'and s.strain != "Not Specified" ' + \
	'and s.strain not like "involves:%" ' + \
	'and s.strain not like "either:%" ' + \
	'and s._Strain_key = a._Strain_key ' + \
	'union ' + \
	'select distinct a._Genotype_key, a._Allele_key_2 ' + \
	'from #orderbystrain s, #allelepairs a ' + \
	'where s._Allele_key_1 = a._Allele_key_1 ' + \
	'and s._Allele_key_2 = a._Allele_key_2 ' + \
	'and s.strain != "Not Specified" ' + \
	'and s.strain not like "involves:%" ' + \
	'and s.strain not like "either:%" ' + \
	'and s._Strain_key = a._Strain_key ', 'auto')

isNoPrefix = {}
for r in results:
    key = r['_Genotype_key']
    if not isNoPrefix.has_key(key):
	isNoPrefix[key] = []
    isNoPrefix[key].append(r['_Allele_key_1'])

results = db.sql('select distinct a._Genotype_key, a._Allele_key_1 ' + \
	'from #orderbystrain s, #allelepairs a ' + \
	'where s._Allele_key_1 = a._Allele_key_1 ' + \
	'and s._Allele_key_2 = a._Allele_key_2 ' + \
	'and s.strain like "involves:%" ' + \
	'and s._Strain_key = a._Strain_key ' + \
	'union ' + \
	'select distinct a._Genotype_key, a._Allele_key_2 ' + \
	'from #orderbystrain s, #allelepairs a ' + \
	'where s._Allele_key_1 = a._Allele_key_1 ' + \
	'and s._Allele_key_2 = a._Allele_key_2 ' + \
	'and s.strain like "involves:%" ' + \
	'and s._Strain_key = a._Strain_key ', 'auto')

isInvolves = {}
for r in results:
    key = r['_Genotype_key']
    if not isInvolves.has_key(key):
	isInvolves[key] = []
    isInvolves[key].append(r['_Allele_key_1'])

results = db.sql('select distinct a._Genotype_key, a._Allele_key_1 ' + \
	'from #orderbystrain s, #allelepairs a ' + \
	'where s._Allele_key_1 = a._Allele_key_1 ' + \
	'and s._Allele_key_2 = a._Allele_key_2 ' + \
	'and s.strain like "either:%" ' + \
	'and s._Strain_key = a._Strain_key ' + \
	'union ' + \
	'select distinct a._Genotype_key, a._Allele_key_2 ' + \
	'from #orderbystrain s, #allelepairs a ' + \
	'where s._Allele_key_1 = a._Allele_key_1 ' + \
	'and s._Allele_key_2 = a._Allele_key_2 ' + \
	'and s.strain like "either:%" ' + \
	'and s._Strain_key = a._Strain_key ', 'auto')

isEither = {}
for r in results:
    key = r['_Genotype_key']
    if not isEither.has_key(key):
	isEither[key] = []
    isEither[key].append(r['_Allele_key_1'])

results = db.sql('select distinct a._Genotype_key, a._Allele_key_1 ' + \
	'from #orderbystrain s, #allelepairs a ' + \
	'where s._Allele_key_1 = a._Allele_key_1 ' + \
	'and s._Allele_key_2 = a._Allele_key_2 ' + \
	'and s.strain = "Not Specified" ' + \
	'and s._Strain_key = a._Strain_key ' + \
	'union ' + \
	'select distinct a._Genotype_key, a._Allele_key_2 ' + \
	'from #orderbystrain s, #allelepairs a ' + \
	'where s._Allele_key_1 = a._Allele_key_1 ' + \
	'and s._Allele_key_2 = a._Allele_key_2 ' + \
	'and s.strain = "Not Specified" ' + \
	'and s._Strain_key = a._Strain_key ', 'auto')

isNotSpec = {}
for r in results:
    key = r['_Genotype_key']
    if not isNotSpec.has_key(key):
	isNotSpec[key] = []
    isNotSpec[key].append(r['_Allele_key_1'])

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
	sequenceNum = 12

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

	if isNoPrefix.has_key(genotype):
	    if a in isNoPrefix[genotype]:
	        sequenceNum = sequenceNum + 1

	if isInvolves.has_key(genotype):
	    if a in isInvolves[genotype]:
	        sequenceNum = sequenceNum + 2

	if isEither.has_key(genotype):
	    if a in isEither[genotype]:
	        sequenceNum = sequenceNum + 3

	if isNotSpec.has_key(genotype):
	    if a in isNotSpec[genotype]:
	        sequenceNum = sequenceNum + 4

	fp.write(str(genotype) + TAB)
	fp.write(str(marker) + TAB)
	fp.write(str(a) + TAB)
	fp.write(str(sequenceNum) + TAB)
	fp.write("1000" + TAB + "1000" + TAB)
	fp.write(loaddate + TAB + loaddate + CRT)

reportlib.finish_nonps(fp)	# non-postscript file

