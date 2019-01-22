#!/usr/local/bin/python

'''
#
# load variant spreadsheet
#
# 1/A:  taxon id
# 2/B:  mgi_allele_id			: var_variant._allele_key
# 3/C:  external_id
# 4/D:  mgi_allele_symbol		: var_variant._allele_key
# 5/E:  reference_ids			: mgi_reference_assoc: _mgitype_key = 45, _object_key = _refs_key
# 6/F:  genome_assembly_version
# 7/G:  chromosome
# 8/H:  start				: var_sequence.startCoord
# 9/I:  end				: var_sequence.endCoord
# 10/J: ref_allele			: var_sequence.referenceSequence
# 11/K: alt_allele			: var_sequence.variantSequence
# 12/L: variant type SO_id		: voc_annot/_annottype_key = 1026
# 13/M: variant type label
# 14/N: HGVS notation (refseq)		: var_variant.description
# 15/O: variant effect SO_id		: voc_annot/_annottype_key = 1027
# 16/P: variant effect SO label
# 17/Q: curator_note			: mgi_note: _mgitype_key = 45, _notetype_key = 1050
# 18/R: public_note			: mgi_note: _mgitype_key = 45, _notetype_key = ?
#
# database fields not in spreadsheet/but need to be set
#
# var_variant._sourcevariant_key = null for Source, previous variantKey for Curated
# var_variant.isReviewed = 0 for Source, 1 for Curated
#
# var_sequence
# _sequence_type_key = ? where voc_term._vocab_key = 21 (RNA, DNA, Polypeptide, Not Loaded)
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

variantBCP      = '%s|%s|%s|38048|%s|%s|1001|1001|%s|%s\n'
sequenceBCP     = '%s|%s|316347|%s|%s|%s|%s|%s|1001|1001|%s|%s\n'
referenceBCP    = '%s|%s|%s|45|1030|1001|1001|%s|%s\n'
vocAnnotBCP     = '%s|%s|%s|%s|1614158|%s|%s\n'
#vocEvidenceBCP  = '%s|%s|47380031|%s||1001|1001|%s|%s\n'
noteBCP         = '%s|%s|45|%s|1001|1001|%s|%s\n'
noteChunkBCP    = '%s|1|%s|1001|1001|%s|%s\n'

variantFile     = open('ALL_Variant.bcp', 'w')
sequenceFile    = open('ALL_Variant_Sequence.bcp', 'w')
referenceFile   = open('MGI_Reference_Assoc.bcp', 'w')
vocAnnotFile    = open('VOC_Annot.bcp', 'w')
#vocEvidenceFile = open('VOC_Evidence.bcp', 'w')
noteFile        = open('MGI_Note.bcp', 'w')
noteChunkFile   = open('MGI_NoteChunk.bcp', 'w')

variantKey      = db.sql(''' select nextval('all_variant_seq') ''', 'auto')[0]['nextval']
sequenceKey     = db.sql(''' select nextval('all_variantsequence_seq') ''', 'auto')[0]['nextval']
referenceKey    = db.sql(''' select nextval('mgi_reference_assoc_seq') ''', 'auto')[0]['nextval']
annotKey        = db.sql(''' select max(_annot_key) + 1 as maxKey from voc_annot ''', 'auto')[0]['maxKey']
evidenceKey     = db.sql(''' select max(_annotevidence_key) + 1 as maxKey from voc_evidence ''', 'auto')[0]['maxKey']
noteKey         = db.sql(''' select max(_note_key) + 1 as maxKey from mgi_note ''', 'auto')[0]['maxKey']

inFile = open('mouse_phenotypic_allele_variants_Final.txt', 'r')
lineNum = 0
for line in inFile.readlines():

	error = 0
	lineNum = lineNum + 1

	tokens = line[:-1].split('\t')

	alleleId = tokens[1]
	allele = tokens[3]
	refIds = tokens[4]
	version = tokens[5]
	startCoord = tokens[7]
	endCoord = tokens[8]
	refSequence = tokens[9]
	varSequence = tokens[10]
	description = tokens[13]
	curatornotes = tokens[16].replace('|', '\\|')
	publicnotes = tokens[17].replace('|', '\\|')

	try:
	    soIdType = tokens[11]
	    soIdEffects = tokens[14].split(',')
        except:
	    pass

	results = db.sql('''select _Object_key from ACC_Accession where _mgitype_key = 11 and accID = '%s' '''  % (alleleId), 'auto')
	if len(results) == 0:
		print 'Invalid Allele: ', alleleId
		error = 1
	for r in results:
		alleleKey = r['_Object_key']

	# references allow > 1, comma-separated
	refIds = refIds.replace('PMID:', '').split(',')
	refKeys = []
	for refId in refIds:
	    refId = refId.replace(' ', '')
	    results = db.sql('''select _Refs_key from BIB_Citation_Cache 
		    where jnumid = '%s' or pubmedid = '%s' or mgiid = '%s' '''  % (refId, refId, refId), 'auto')
	    if len(results) == 0:
		    print 'Invalid Reference: ', refId
		    error = 1
	    for r in results:
		    refKey = r['_Refs_key']
		    refKeys.append(refKey)

	results = db.sql('''select _object_key from ACC_Accession where accID = '%s' ''' % (soIdType), 'auto')
	if len(results) == 0:
		print 'Invalid SO ID: ', soIdType
		error = 1

	# variant effects allow > 1, comma-separated
	soEffectKeys = []
	for soIdEffect in soIdEffects:
	    for r in results:
		    soTypeKey = r['_object_key']
	    results = db.sql('''select _object_key from ACC_Accession where accID = '%s' ''' % (soIdEffect), 'auto')
	    if len(results) == 0:
		    print 'Invalid SO ID: ', soIdEffect
		    error = 1
	    for r in results:
		    soEffectKey = r['_object_key']
		    soEffectKeys.append(soEffectKey)

	if error == 1:
	        print lineNum, alleleId, allele
		print '#####'
		continue

	#
	# source variant
	#
	sVariantKey = ''
	isReviewed = 0
	variantFile.write(variantBCP % (variantKey, alleleKey, sVariantKey, isReviewed, description, cdate, cdate))
	sequenceFile.write(sequenceBCP % (sequenceKey, variantKey, startCoord, endCoord, refSequence, varSequence, version, cdate, cdate))
	sVariantKey = variantKey
	variantKey += 1
	sequenceKey += 1

	#
	# curated variant
	#
	isReviewed = 1
	variantFile.write(variantBCP % (variantKey, alleleKey, sVariantKey, isReviewed, description, cdate, cdate))
	sequenceFile.write(sequenceBCP % (sequenceKey, variantKey, startCoord, endCoord, refSequence, varSequence, version, cdate, cdate))

	for refKey in refKeys:
	    referenceFile.write(referenceBCP % (referenceKey, refKey, variantKey, cdate, cdate))
	    referenceKey += 1

        vocAnnotFile.write(vocAnnotBCP % (annotKey, 1026, variantKey, soTypeKey, cdate, cdate))
        #vocEvidenceFile.write(vocEvidenceBCP % (evidenceKey, annotKey, refKey, cdate, cdate))
	annotKey += 1
	#evidenceKey += 1

	for soEffectKey in soEffectKeys:
            vocAnnotFile.write(vocAnnotBCP % (annotKey, 1027, variantKey, soEffectKey, cdate, cdate))
            #vocEvidenceFile.write(vocEvidenceBCP % (evidenceKey, annotKey, refKey, cdate, cdate))
	    annotKey += 1
	    #evidenceKey += 1

	if len(curatornotes) > 0:
		noteFile.write(noteBCP % (noteKey, variantKey, 1050, cdate, cdate))
		noteChunkFile.write(noteChunkBCP % (noteKey, curatornotes, cdate, cdate))
		noteKey += 1
	if len(publicnotes) > 0:
		noteFile.write(noteBCP % (noteKey, variantKey, 1051, cdate, cdate))
		noteChunkFile.write(noteChunkBCP % (noteKey, publicnotes, cdate, cdate))
		noteKey += 1

	variantKey += 1
	sequenceKey += 1

inFile.close()
variantFile.close()
sequenceFile.close()
referenceFile.close()
vocAnnotFile.close()
#vocEvidenceFile.close()
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
#bcp5 = '%s %s %s %s %s %s "|" "\\n" mgd' % \
#        (bcpCommand, db.get_sqlServer(), db.get_sqlDatabase(), 'VOC_Evidence', currentDir, 'VOC_Evidence.bcp')
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
#print bcp5
#os.system(bcp5)
print bcp6
os.system(bcp6)
print bcp7
os.system(bcp7)
db.commit()

db.sql(''' select setval('all_variant_seq', (select max(_Variant_key) from ALL_Variant)) ''', None)
db.sql(''' select setval('all_variantsequence_seq', (select max(_VariantSequence_key) from ALL_Variant_Sequence)) ''', None)
db.sql(''' select setval('mgi_reference_assoc_seq', (select max(_Assoc_key) from MGI_Reference_Assoc)) ''', None)
db.commit()

