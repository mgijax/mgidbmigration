#!/usr/local/bin/python

import sys 
import db
import reportlib
import mgi_utils

CRT = reportlib.CRT
SPACE = reportlib.SPACE
TAB = reportlib.TAB
PAGE = reportlib.PAGE

#
# Main
#

fp = reportlib.init(sys.argv[0], printHeading = 0)

results = db.sql('select aa.accID, a1 = a1.symbol, a2 = a2.symbol, m.chromosome, o.isUnknown ' + \
	'from GXD_AllelePair a, VOC_Term t, MRK_Marker m, ALL_Allele a1, ALL_Allele a2, ACC_Accession aa, GXD_AllelePair_Old o ' + \
	'where a._PairState_key = t._Term_key ' + \
	'and t.term = "Unknown" ' + \
	'and a._Marker_key = m._Marker_key ' + \
	'and a._Allele_key_1 = a1._Allele_key ' + \
	'and a._Allele_key_2 *= a2._Allele_key ' + \
	'and a._AllelePair_key = o._AllelePair_key ' + \
	'and a._Genotype_key = aa._Object_key ' + \
	'and aa._MGIType_key = 12 ' + \
	'and aa.prefixPart = "MGI:" order by aa.accID', 'auto')

for r in results:

    if r['isUnknown'] == 1:
	prevState = 'Unknown'
    else:
	prevState = 'Hemizygous'

    fp.write(r['accID'] + TAB + \
	r['chromosome'] + TAB + \
	r['a1'] + TAB + \
	mgi_utils.prvalue(r['a2']) + TAB + \
	prevState + CRT)

reportlib.finish_nonps(fp)	# non-postscript file

