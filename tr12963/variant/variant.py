#!/usr/local/bin/python

'''
#
# Report:
#       load Meiyee's spreadsheet
#
#
# 1.  mgi id marker
# 2.  marker symbol
# 3.  strain name			: var_variant._strain_key
# 4.  pubmedid				: acc_accession:  _mgitype_key = ?, ldb = 29
# 5.  J:				: mgi_reference_assoc: _mgitype_key = ?, _object_key = _refs_key
# 6.  mgi id allele			: var_variant._allele_key
# 7.  allele symbol
# 8.  molecular note			: mgi_note: _mgitype_key = ?, _notetype_key = ?
# 9.  chromosome (format is in "chr")
# 10. start coordinate			: map
# 11. end coordinate			: map
# 12. ref_allele			: var_sequence.referenceSequence
# 13. alt_allele			: var_sequence.variantSequence
# 14. jannovar_hgvs 			: var_variant.description
# 15. jannovar_functional_class		: lookup terms in SO vocab (21)
#
# database fields not in spreadsheet/but need to be set
#
# var_variant._sourcevariant_key = ?
# var_variant.isReviewed = ?
#
# var_sequence
# _sequence_type_key = ? where voc_term._vocab_key = 21 (RNA, DNA, Polypeptide, Not Loaded)
#
# var_effect, from SO
#
# var_type, from SO
#
'''
 
import sys 
import os
import db
import reportlib

db.setTrace()

CRT = reportlib.CRT
SPACE = reportlib.SPACE
TAB = reportlib.TAB
PAGE = reportlib.PAGE

#
# Main
#

db.useOneConnection(1)

inFile = open('', 'r')
lineNum = 0
for line in inFile.readlines():
	lineNum = lineNum + 1

	tokens = line[:-1].split('\t')

fp = reportlib.init(sys.argv[0], printHeading = None)

#
# cmd = sys.argv[1]
#
# or
#
# cmd = 'select * from MRK_Marker where _Species_key = 1 and chromosome = "1"'
#

results = db.sql(cmd, 'auto')

for r in results:
    fp.write(r['item'] + CRT)

inFile.close()
reportlib.finish_nonps(fp)	# non-postscript file
db.useOneConnection(0)

