#!/usr/local/bin/python

'''
#
# Report:
#       load Meiyee's spreadsheet
#
#
# 1/A.  mgi id marker
# 2/B.  marker symbol
# 3/C.  strain name			: var_variant._strain_key
# 4/D.  pubmedid				: acc_accession:  _mgitype_key = ?, ldb = 29
# 5/E.  J:				: mgi_reference_assoc: _mgitype_key = ?, _object_key = _refs_key
# 6/F.  mgi id allele			: var_variant._allele_key
# 7/G.  allele symbol
# 8/H.  molecular note			: mgi_note: _mgitype_key = ?, _notetype_key = ?
# 9/I.  chromosome (format is in "chr")
# 10/J. start coordinate			: var_sequence.startCoord
# 11/K. end coordinate			: var_sequence.endCoord
# 12/L. ref_allele			: var_sequence.referenceSequence
# 13/M. alt_allele			: var_sequence.variantSequence
# 14/N. jannovar_hgvs 			: var_variant.description
# 15/O. jannovar_functional_class		: lookup terms in SO vocab (21)
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

variantBCP      = '%s|%s|%s|%s|0|%s|1001|1001|%s|%s\n'
sequenceBCP     = '%s|%s|316347|%s|%s|%s|%s|1001|1001|%s|%s\n'
referenceBCP    = '%s|%s|%s|45|1030|1001|1001|%s|%s\n'
vocAnnotBCP     = '%s|1026|%s|%s|1614158|%s|%s\n'
vocEvidenceBCP  = '%s|%s|47380031|%s||1001|1001|%s|%s\n'
noteBCP         = '%s|%s|45|1050|1001|1001|%s|%s\n'
noteChunkBCP    = '%s|1|%s|1001|1001|%s|%s\n'

variantFile     = open('ALL_Variant.bcp', 'w')
sequenceFile    = open('ALL_Variant_Sequence.bcp', 'w')
referenceFile   = open('MGI_Reference_Assoc.bcp', 'w')
vocAnnotFile    = open('VOC_Annot.bcp', 'w')
vocEvidenceFile = open('VOC_Evidence.bcp', 'w')
noteFile        = open('MGI_Note.bcp', 'w')
noteChunkFile   = open('MGI_NoteChunk.bcp', 'w')

variantKey      = db.sql(''' select nextval('all_variant_seq') ''', 'auto')[0]['nextval']
sequenceKey     = db.sql(''' select nextval('all_variantsequence_seq') ''', 'auto')[0]['nextval']
referenceKey    = db.sql(''' select nextval('mgi_reference_assoc_seq') ''', 'auto')[0]['nextval']
annotKey        = db.sql(''' select max(_annot_key) + 1 as maxKey from voc_annot ''', 'auto')[0]['maxKey']
evidenceKey     = db.sql(''' select max(_annotevidence_key) + 1 as maxKey from voc_evidence ''', 'auto')[0]['maxKey']
noteKey         = db.sql(''' select max(_note_key) + 1 as maxKey from mgi_note ''', 'auto')[0]['maxKey']

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
	#
	# 10/J. start coordinate		: var_sequence.startCoord
	# 11/K. end coordinate			: var_sequence.endCoord
	# 12/L. ref_allele			: var_sequence.referenceSequence
	# 13/M. alt_allele			: var_sequence.variantSequence
	#
	# 5/E.  J:				: mgi_reference_assoc: _mgitype_key = ?, _object_key = _refs_key
	#
	# 15/O. jannovar_functional_class	: lookup terms in SO vocab (21)
	#
	# 8/H.  molecular note			: mgi_note: _mgitype_key = ?, _notetype_key = ?

	strain = tokens[2]
	alleleId = tokens[5]
	allele = tokens[6]
	description = tokens[13]

	startCoord = tokens[9]
	endCoord = tokens[10]
	refSequence = tokens[11]
	varSequence = tokens[12]
	jnumId = tokens[4]
	notes = tokens[7]

	try:
	    soTerm = tokens[14].lower()
        except:
	    pass

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

	results = db.sql('''select _Refs_key from BIB_Citation_Cache where jnumID = '%s' '''  % (jnumId), 'auto')
	if len(results) == 0:
		print 'Invalid J#: ', jnumId
		error = 1
	for r in results:
		refsKey = r['_Refs_key']

	results = db.sql('''select _term_key from VOC_Term where term = '%s' ''' % (soTerm), 'auto')
	if len(results) == 0:
		print 'Invalid SO term: ', soTerm
		error = 1
	for r in results:
		soKey = r['_Term_key']

	if error == 1:
	        print lineNum, strain, alleleId, allele
		print '#####'
		continue

	sourceVariantKey = ''
	variantFile.write(variantBCP % (variantKey, alleleKey, sourceVariantKey, strainKey, description, cdate, cdate))
	sequenceFile.write(sequenceBCP % (sequenceKey, variantKey, startCoord, endCoord, refSequence, varSequence, cdate, cdate))
	referenceFile.write(referenceBCP % (referenceKey, refsKey, variantKey, cdate, cdate))
        vocAnnotFile.write(vocAnnotBCP % (annotKey, variantKey, soKey, cdate, cdate))
        vocEvidenceFile.write(vocEvidenceBCP % (evidenceKey, annotKey, refsKey, cdate, cdate))
	noteFile.write(noteBCP % (noteKey, variantKey, cdate, cdate))
	noteChunkFile.write(noteChunkBCP % (noteKey, notes, cdate, cdate))

	sourceVariantKey = variantKey
	variantKey += 1
	sequenceKey += 1
	referenceKey += 1
	annotKey += 1
	evidenceKey += 1
	noteKey += 1;

	variantFile.write(variantBCP % (variantKey, alleleKey, sourceVariantKey, strainKey, description, cdate, cdate))
	sequenceFile.write(sequenceBCP % (sequenceKey, variantKey, startCoord, endCoord, refSequence, varSequence, cdate, cdate))
	referenceFile.write(referenceBCP % (referenceKey, refsKey, variantKey, cdate, cdate))
        vocAnnotFile.write(vocAnnotBCP % (annotKey, variantKey, soKey, cdate, cdate))
	variantKey += 1
	sequenceKey += 1
	referenceKey += 1
	annotKey += 1
	evidenceKey += 1

inFile.close()
variantFile.close()
sequenceFile.close()
referenceFile.close()
vocAnnotFile.close()
vocEvidenceFile.close()
noteFile.close()
noteChunkFile.close()

db.commit()

bcpCommand = os.environ['PG_DBUTILS'] + '/bin/bcpin.csh'
currentDir = os.getcwd()

bcp1 = '%s %s %s %s %s %s "|" "\\n" mgd' % \
        (bcpCommand, db.get_sqlServer(), db.get_sqlDatabase(), 'ALL_Variant', currentDir, 'ALL_Variant.bcp')
bcp2 = '%s %s %s %s %s %s "|" "\\n" mgd' % \
        (bcpCommand, db.get_sqlServer(), db.get_sqlDatabase(), 'ALL_Variant_Sequence', currentDir, 'ALL_Variant_Sequence.bcp')
bcp3 = '%s %s %s %s %s %s "|" "\\n" mgd' % \
        (bcpCommand, db.get_sqlServer(), db.get_sqlDatabase(), 'MGI_Reference_Assoc', currentDir, 'MGI_Reference_Assoc.bcp')
bcp4 = '%s %s %s %s %s %s "|" "\\n" mgd' % \
        (bcpCommand, db.get_sqlServer(), db.get_sqlDatabase(), 'VOC_Annot', currentDir, 'VOC_Annot.bcp')
bcp5 = '%s %s %s %s %s %s "|" "\\n" mgd' % \
        (bcpCommand, db.get_sqlServer(), db.get_sqlDatabase(), 'VOC_Evidence', currentDir, 'VOC_Evidence.bcp')
bcp6 = '%s %s %s %s %s %s "|" "\\n" mgd' % \
        (bcpCommand, db.get_sqlServer(), db.get_sqlDatabase(), 'MGI_Note', currentDir, 'MGI_Note.bcp')
bcp7 = '%s %s %s %s %s %s "|" "\\n" mgd' % \
        (bcpCommand, db.get_sqlServer(), db.get_sqlDatabase(), 'MGI_NoteChunk', currentDir, 'MGI_NoteChunk.bcp')


print bcp1
os.system(bcp1)
print bcp2
os.system(bcp2)
print bcp3
os.system(bcp3)
print bcp4
os.system(bcp4)
print bcp5
os.system(bcp5)
print bcp6
os.system(bcp6)
print bcp7
os.system(bcp7)
db.commit()

db.sql(''' select setval('all_variant_seq', (select max(_Variant_key) from ALL_Variant)) ''', None)
db.sql(''' select setval('all_variantsequence_seq', (select max(_VariantSequence_key) from ALL_Variant_Sequence)) ''', None)
db.sql(''' select setval('mgi_reference_assoc_seq', (select max(_Assoc_key) from MGI_Reference_Assoc)) ''', None)
db.commit()

