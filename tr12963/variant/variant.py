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
import mgi_utils
import reportlib

cdate = mgi_utils.date('%m/%d/%Y')

db.setTrace()

CRT = reportlib.CRT
SPACE = reportlib.SPACE
TAB = reportlib.TAB
PAGE = reportlib.PAGE

#
# Main
#

variantBCP = '%s|%s||%s|0|%s|1000|1000|%s|%s\n'
variantFile = open('ALL_Variant.bcp', 'w')
variantKey = 1

inFile = open('122018_alleles.txt', 'r')
lineNum = 0
for line in inFile.readlines():

	error = 0
	lineNum = lineNum + 1

	tokens = line[:-1].split('\t')

	# 3.  strain name			: var_variant._strain_key
	# 6.  mgi id allele			: var_variant._allele_key
	# 7.  allele symbol
	# 14. jannovar_hgvs 			: var_variant.description

	strain = tokens[2]
	alleleId = tokens[5]
	allele = tokens[6]
	description = tokens[13]
	print strain, alleleId, allele

	results = db.sql('''select _Strain_key, strain from PRB_Strain where strain = '%s' ''' % (strain), 'auto')
	if len(results) == 0:
		print 'Invalid Strain: ', strain
		error = 1
	for r in results:
		strainKey = r['_Strain_key']

	results = db.sql('''select _Object_key from ACC_Accession where _mgitype_key = 11 and accID = '%s' '''  % (alleleId), 'auto')
	if len(results) == 0:
		print 'Invalid Allele: ', alleleId
		error = 1
	for r in results:
		alleleKey = r['_Object_key']

	if error == 1:
		continue

	variantFile.write(variantBCP % (variantKey, alleleKey, strainKey, description, cdate, cdate))
	variantKey += 1

inFile.close()
variantFile.close()

bcpCommand = os.environ['PG_DBUTILS'] + '/bin/bcpin.csh'
currentDir = os.getcwd()

bcp1 = '%s %s %s %s %s %s "|" "\\n" mgd' % \
        (bcpCommand, db.get_sqlServer(), db.get_sqlDatabase(), 'ALL_Variant', currentDir, 'ALL_Variant.bcp')

os.system(bcp1)

