#!/usr/local/bin/python

#
# Generate a file for noteload of copyright notes for journals
#

import sys 
import string
import db
import reportlib

CRT = reportlib.CRT
SPACE = reportlib.SPACE
TAB = reportlib.TAB
PAGE = reportlib.PAGE

journals = {'J Clin Invest': 'This image is from * and is displayed with the permission of the American Society for Clinical Investigation who owns the Copyright.',
            'J Biol Chem': 'This image is from * and is displayed with the permission of the American Society for Biochemistry and Molecular Biology who owns the Copyright. Full text from \JBiolChem(||).',
            'J Lipid Res': 'This image is from * and is displayed with the permission of the American Society for Biochemistry and Molecular Biology who owns the Copyright. Full text is from \JLipidRes(||).'
	}

#
# Main
#

fp = reportlib.init('journal', printHeading = None)

results = db.sql('select a.accID, t.term ' + \
	'from VOC_Vocab v, VOC_Term t, ACC_Accession a ' + \
	'where v.name = "Journal" ' + \
	'and v._Vocab_key = t._Vocab_key ' + \
	'and t.term in ("' + string.join(journals, '","') + '") ' + \
	'and t._Term_key = a._Object_key ' + \
	'and a._MGIType_key = 13 ' + \
	'and a._LogicalDB_key = 1' + \
	'and a.preferred = 1', 'auto')

for r in results:

    fp.write(r['accID'] + TAB + journals[r['term']] + CRT)

reportlib.finish_nonps(fp)	# non-postscript file

