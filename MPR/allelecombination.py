#!/usr/local/bin/python

import sys 
import string
import db
import reportlib
import mgi_utils

DEBUG = 1

CRT = reportlib.CRT
SPACE = reportlib.SPACE
TAB = reportlib.TAB
PAGE = reportlib.PAGE

mgiTypeKey = 12
newline = '\\n'

#
# Main
#

fp1 = reportlib.init('allelecombnotetype1', printHeading = 0)
fp2 = reportlib.init('allelecombnotetype2', printHeading = 0)
fp3 = reportlib.init('allelecombnotetype3', printHeading = 0)

results = db.sql('select g._Genotype_key, alleleState = t1.term, compound = t2.term, allele1 = a1.symbol, allele2 = a2.symbol, ' +
	'allele1WildType = a1.isWildType, allele2WildType = a2.isWildType, ' + \
	'mgiID1 = c1.accID, mgiID2 = c2.accID, genotypeID = c3.accID, g.sequenceNum ' + \
	'from GXD_AllelePair g, VOC_Term t1, VOC_Term t2, ALL_Allele a1, ALL_Allele a2, ACC_Accession c1, ACC_Accession c2, ACC_Accession c3 ' + \
	'where g._PairState_key = t1._Term_key ' + \
	'and g._Compound_key = t2._Term_key ' + \
	'and g._Allele_key_1 = a1._Allele_key ' + \
	'and g._Allele_key_2 = a2._Allele_key ' + \
	'and g._Allele_key_1 = c1._Object_key ' + \
	'and c1._MGIType_key = 11 ' + \
	'and c1._LogicalDB_key = 1 ' + \
	'and c1.prefixPart = "MGI:" ' + \
	'and c1.preferred = 1 ' + \
	'and g._Allele_key_2 = c2._Object_key ' + \
	'and c2._MGIType_key = 11 ' + \
	'and c2._LogicalDB_key = 1 ' + \
	'and c2.prefixPart = "MGI:" ' + \
	'and c2.preferred = 1 ' + \
	'and g._Genotype_key = c3._Object_key ' + \
	'and c3._MGIType_key = 12 ' + \
	'and c3._LogicalDB_key = 1 ' + \
	'and c3.prefixPart = "MGI:" ' + \
	'and c3.preferred = 1 ' + \
	'union ' + \
	'select g._Genotype_key, alleleState = t1.term, compound = t2.term, allele1 = a1.symbol, allele2 = null, ' + \
	'allele1WildType = a1.isWildType, allele2WildType = 0, ' + \
	'mgiID1 = c1.accID, mgiID2 = null, genotypeID = c3.accID, g.sequenceNum ' + \
	'from GXD_AllelePair g, VOC_Term t1, VOC_Term t2, ALL_Allele a1, ACC_Accession c1, ACC_Accession c3 ' + \
	'where g._PairState_key = t1._Term_key ' + \
	'and g._Compound_key = t2._Term_key ' + \
	'and g._Allele_key_1 = a1._Allele_key ' + \
	'and g._Allele_key_2 is null ' + \
	'and g._Allele_key_1 = c1._Object_key ' + \
	'and c1._MGIType_key = 11 ' + \
	'and c1._LogicalDB_key = 1 ' + \
	'and c1.prefixPart = "MGI:" ' + \
	'and c1.preferred = 1 ' + \
	'and g._Genotype_key = c3._Object_key ' + \
	'and c3._MGIType_key = 12 ' + \
	'and c3._LogicalDB_key = 1 ' + \
	'and c3.prefixPart = "MGI:" ' + \
	'and c3.preferred = 1 ' + \
	'order by g._Genotype_key, g.sequenceNum', 'auto')

genotypes = {}
for r in results:
    key = r['_Genotype_key']
    value = r

    if not genotypes.has_key(key):
	genotypes[key] = []
    genotypes[key].append(r)

for g in genotypes.keys():

    foundTop = 0
    foundBottom = 0

    displayNotes1 = ''
    displayNotes2 = ''

    topType1 = ''
    topType2 = ''

    bottomType1 = ''
    bottomType2 = ''

    for r in genotypes[g]:

	genotypeID = r['genotypeID']
        compound = r['compound']
        alleleState = r['alleleState']

        allele1 = r['allele1']
        allele1WildType = r['allele1WildType']
        mgiID1 = r['mgiID1']

        allele2 = r['allele2']
        allele2WildType = r['allele2WildType']
        mgiID2 = r['mgiID2']

        if compound == 'Not Applicable':

            if alleleState in ['Homozygous', 'Heterozygous', 'Hemizygous X-linked', 'Hemizygous Y-linked', 'Hemizygous Insertion', 'Indeterminate']:
                topType1 = allele1
                if allele1WildType == 1:
	            topType2 = allele1
                else:
	            topType2 = '\Allele(' + mgiID1 + ',' + allele1 + ',)'

            if alleleState in ['Homozygous', 'Heterozygous']:
                bottomType1 = allele2
                if allele2WildType == 1:
	            bottomType2 = allele2
                else:
	            bottomType2 = '\Allele(' + mgiID2 + ',' + allele2 + ',)'

            if alleleState == 'Hemizygous X-linked':
                bottomType1 = 'Y'

            if alleleState == 'Hemizygous Y-linked':
                bottomType1 = 'X'

            if alleleState == 'Hemizygous Insertion':
                bottomType1 = '0'

            if alleleState == 'Hemizygous Deletion':
                topType1 = 'Mutant Allele'
                topType2 = topType1
                bottomType1 = '-'
    
            if alleleState == 'Indeterminate':
                bottomType1 = '?'

            if alleleState in ['Hemizygous X-linked', 'Hemizygous Y-linked', 'Hemizygous Insertion', 'Hemizygous Deletion', 'Indeterminate']:
                bottomType2 = bottomType1

            if alleleState != 'Unknown':
                displayNotes1 = displayNotes1 + topType1 + '/' + bottomType1 + newline
                displayNotes2 = displayNotes2 + topType2 + '/' + bottomType2 + newline

        elif (compound == 'Top'):

            # new top, new group: process old group

            if foundBottom >= 1:
                displayNotes1 = displayNotes1 + topType1 + '/' + bottomType1 + newline
                displayNotes2 = displayNotes2 + topType2 + '/' + bottomType2 + newline
	        topType1 = ''
	        topType2 = ''
	        bottomType1 = ''
	        bottomType2 = ''
                foundTop = 0
                foundBottom = 0

           # new top, same group: need space to separate tops */

            if foundTop >= 1:
	        topType1 = topType1 + ' '
	        topType2 = topType2 + ' '

            topType1 = topType1 + allele1
            topType2 = topType2 + '\Allele(' + mgiID1 + ',' + allele1 + ',)'

            foundTop = foundTop + 1

        elif compound == 'Bottom':

            # new bottom, same group: need space to separate bottoms

            if foundBottom >= 1:
	        bottomType1 = bottomType1 + ' '
	        bottomType2 = bottomType2 + ' '

            bottomType1 = bottomType1 + allele1

            if allele2WildType == 1:
	        bottomType2 = bottomType2 + allele1
            else:
	        bottomType2 = bottomType2 + '\Allele(' + mgiID1 + ',' + allele1 + ',)'

            foundBottom = foundBottom + 1

        if foundTop >= 1 and foundBottom >= 1:
            displayNotes1 = displayNotes1 + topType1 + '/' + bottomType1 + newline
            displayNotes2 = displayNotes2 + topType2 + '/' + bottomType2 + newline

    fp1.write(genotypeID + TAB + displayNotes1 + CRT)
    fp2.write(genotypeID + TAB + displayNotes2 + CRT)
    fp3.write(genotypeID + TAB + displayNotes2 + CRT)

reportlib.finish_nonps(fp1)	# non-postscript file
reportlib.finish_nonps(fp2)	# non-postscript file
reportlib.finish_nonps(fp3)	# non-postscript file

