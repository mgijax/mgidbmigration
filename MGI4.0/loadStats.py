#!/usr/local/bin/python

# deletes any existing statistics and measurements before adding new ones

import stats
import sys
import db

###-------------------------------###
###--- command-line processing ---###
###-------------------------------###

try:
	DB_USER = sys.argv[1]		# database username
	PWD_FILE = sys.argv[2]		# password file
	DB_SRV = sys.argv[3]		# database server name
	MGD_DB = sys.argv[4]		# mgd database name
	SNP_DB = sys.argv[5]		# snp database name
except:
	sys.stderr.write ('Usage: %s <db username> <db password file> <db server> <mgd db name> <snp db name>\n' % sys.argv[0])
	sys.exit(1)

try:
	fp = open(PWD_FILE, 'r')
	PWD = fp.readline().strip()
	fp.close()
except:
	sys.stderr.write ('read of %s failed\n' % PWD_FILE)
	sys.exit(1)

try:
	db.set_sqlLogin (DB_USER, PWD, DB_SRV, MGD_DB)
	db.sql ('SELECT COUNT(1) FROM MGI_dbInfo', 'auto')
except:
	sys.stderr.write ('mgd database login failed\n')
	sys.exit(1)

try:
	db.sql ('SELECT COUNT(1) FROM %s..MGI_dbInfo' % SNP_DB, 'auto')
except:
	sys.stderr.write ('snp database login failed\n')
	sys.exit(1)

###---------------###
###--- globals ---###
###---------------###

GENE = 1			# marker type
NUCLEOTIDE_KEY = 316347		# sequence type
TRANSCRIPT_KEY = 316346		# sequence type
PROTEIN_KEY = 316348		# sequence type
QTL = 6				# marker type
QTL_ALLELE = 847130		# allele type
APPROVED_ALLELE = 847114	# allele status key
OMIM_VOCAB = 44			# vocab key
MP_VOCAB = 5			# vocab key
GENOTYPE_MP = 1002		# association type
GO_MARKER = 1000		# association type
GO_BP = 3			# dag key
GO_MF = 2			# dag key
GO_CC = 1			# dag key
MOUSE = 1			# organism key
HUMAN = 2			# organism key
RAT = 40			# organism key
CHIMP = 10			# organism key
DOG = 13			# organism key
ALLELE = 11			# mgitype key
ASSAY = 8			# mgitype key
MARKER = 2			# mgitype key
REF = 1				# mgitype key
HOMOLOGENE = 88			# logical db key

###---------------------------------###
###--- definitions of statistics ---###
###---------------------------------###

statistics = [
	{
		'abbrev' : 'genesUncMut',
		'name' : 'Genes (including uncloned mutants)',
		'def' : 'all current and interim mouse genes',
		'private' : 0,
		'int' : 1,
		'sql' : '''SELECT COUNT(1) FROM MRK_Marker
			WHERE _Organism_key = 1
				AND _Marker_Type_key = %d
				AND _Marker_Status_key IN (1,3)''' % GENE,
	},
	{
		'abbrev' : 'genesSeq',
		'name' : 'Genes with sequence data',
		'def' : 'current and interim mouse genes which have any ' + \
			'associated sequences (nucleotide, transcript, ' + \
			'or protein)',
		'private' : 0,
		'int' : 1,
		'sql' : '''SELECT COUNT(DISTINCT m._Marker_key)
			FROM MRK_Marker m, SEQ_Marker_Cache s
			WHERE m._Marker_key = s._Marker_key
				AND m._Organism_key = 1
				AND m._Marker_Status_key IN (1,3)
				AND m._Marker_Type_key = %d''' % GENE,
	},
	{
		'abbrev' : 'genesNucl',
		'name' : 'Genes with nucleotide sequence data',
		'def' : 'current and interim mouse genes which have nucleotide sequences',
		'private' : 0,
		'int' : 1,
		'sql' : '''SELECT COUNT(DISTINCT m._Marker_key)
			FROM MRK_Marker m, SEQ_Marker_Cache s
			WHERE m._Marker_key = s._Marker_key
				AND m._Organism_key = 1
				AND m._Marker_Type_key = %d
				AND m._Marker_Status_key IN (1,3)
				AND s._SequenceType_key = %d''' % \
					(GENE, NUCLEOTIDE_KEY),
	},
	{
		'abbrev' : 'genesProt',
		'name' : 'Genes with protein sequence data',
		'def' : 'current and interim mouse genes which have protein sequences',
		'private' : 0,
		'int' : 1,
		'sql' : '''SELECT COUNT(DISTINCT m._Marker_key)
			FROM MRK_Marker m, sEQ_Marker_Cache s
			WHERE m._Marker_key = s._Marker_key
				AND m._Organism_key = 1
				AND m._Marker_Type_key = %d
				AND m._Marker_Status_key IN (1,3)
				AND s._SequenceType_key = %d''' % \
					(GENE, PROTEIN_KEY),
	},
	{
		'abbrev' : 'genesExpr',
		'name' : 'Genes with expression assays',
		'def' : 'current and interim mouse genes and other markers which have expression assays',
		'private' : 0,
		'int' : 1,
		'sql' : '''SELECT COUNT(DISTINCT e._Marker_key)
			FROM GXD_Expression e, MRK_Marker m
			WHERE e._Marker_key = m._Marker_key
				AND m._Organism_key = 1
				AND m._Marker_Status_key IN (1,3)''',
	},
	{
		'abbrev' : 'genes',
		'name' : 'Genes',
		'def' : 'current and interim mouse genes',
		'private' : 0,
		'int' : 1,
		'sql' : '''SELECT COUNT(1)
			FROM MRK_Marker
			WHERE _Organism_key = 1
				AND _Marker_Type_key = %d
				AND _Marker_Status_key IN (1,3)''' % GENE,
	},
	{
		'abbrev' : 'markersMap',
		'name' : 'Mapped genes/markers',
		'def' : 'current mouse genes and markers which have been ' + \
				'mapped to genome coordinates',
		'private' : 0,
		'int' : 1,
		'sql' : '''SELECT COUNT(1)
			FROM MRK_Location_Cache
			WHERE startCoordinate != null''',
	},
	{
		'abbrev' : 'genesGT',
		'name' : 'Genes with gene traps',
		'def' : 'current mouse genes which are associated with ' + \
				'gene trap accession IDs (from GT Lite)',
		'private' : 0,
		'int' : 1,
		'sql' : '''SELECT COUNT(DISTINCT aa._Object_key)
			FROM ACC_Accession aa,
				MRK_Marker mm
			WHERE aa._MGIType_key = %d
				AND aa._Object_key = mm._Marker_key
				AND mm._Marker_Type_key = %d
				AND mm._Organism_key = %d
				AND aa._LogicalDB_key IN (
					SELECT  msm._Object_key
					FROM MGI_SetMember msm, MGI_Set ms
					WHERE msm._Set_key = ms._Set_key
						AND ms.name = 'Gene Traps')
				AND aa.private = 0''' % (MARKER, GENE, MOUSE),
	},
	{
		'abbrev' : 'mutantAlleles',
		'name' : 'Mutant alleles',
		'def' : 'approved non-wild type, non-QTL mutant alleles',
		'private' : 0,
		'int' : 1,
		'sql' : '''SELECT COUNT(1)
			FROM ALL_Allele
			WHERE isWildType = 0
				AND _Allele_Type_key != %d
				AND _Allele_Status_key = %d''' % (QTL_ALLELE,
					APPROVED_ALLELE),
	},
	{
		'abbrev' : 'genesMutant',
		'name' : 'Genes with mutant alleles',
		'def' : 'Genes which have approved non-wild type, non-QTL mutant alleles',
		'private' : 0,
		'int' : 1,
		'sql' : '''SELECT COUNT(DISTINCT a._Marker_key)
			FROM ALL_Allele a, MRK_Marker m
			WHERE a.isWildType = 0
				AND a._Allele_Type_key != %d
				AND a._Allele_Status_key = %d
				AND a._Marker_key = m._Marker_key
				AND m._Marker_Type_key = %d''' % (
					QTL_ALLELE, APPROVED_ALLELE, GENE),
	},
	{
		'abbrev' : 'genotypesAnno',
		'name' : 'Genotypes with phenotype annotations',
		'def' : 'Genotypes with phenotype annotations, excluding genotypes with QTL alleles',
		'private' : 0,
		'int' : 1,
		'sql' : '''SELECT COUNT(DISTINCT g._Genotype_key)
			FROM VOC_Annot v, GXD_AlleleGenotype g, ALL_Allele a
			WHERE v._AnnotType_key = %d
				AND v._Object_key = g._Genotype_key
				AND g._Allele_key = a._Allele_key
				AND a._Allele_Type_key != %d''' % \
					(GENOTYPE_MP, QTL_ALLELE),
	},
	{
		'abbrev' : 'allelesAnno',
		'name' : 'Alleles with phenotype annotations',
		'def' : 'Approved alleles with phenotype annotations',
		'private' : 0,
		'int' : 1,
		'sql' : '''SELECT COUNT(DISTINCT g._Allele_key)
			FROM VOC_Annot v, GXD_AlleleGenotype g, ALL_Allele a
			WHERE v._AnnotType_key = %d
				AND g._Allele_key = a._Allele_key
				AND a._Allele_Status_key = %d
				AND v._Object_key = g._Genotype_key''' % \
					(GENOTYPE_MP, APPROVED_ALLELE),
	},
	{
		'abbrev' : 'genesAnno',
		'name' : 'Genes with phenotype annotations',
		'def' : 'Genes which are part of genotypes which have phenotype annotations',
		'private' : 0,
		'int' : 1,
		'sql' : '''SELECT COUNT(DISTINCT m._Marker_key)
			FROM VOC_Annot v,
				GXD_AlleleGenotype g,
				MRK_Marker m
			WHERE v._AnnotType_key = %d
				AND v._Object_key = g._Genotype_key
				AND g._Marker_key = m._Marker_key
				AND m._Marker_Type_key = %d''' % \
					(GENOTYPE_MP, GENE),
	},
	{
		'abbrev' : 'genesTreeFam',
		'name' : 'Genes with links to TreeFam',
		'def' : 'Mouse genes with links to TreeFam (IDs from HomoloGene)',
		'private' : 0,
		'int' : 1,
		'sql' : '''SELECT COUNT(DISTINCT m._Marker_key)
			FROM MRK_Marker m,
				ACC_Accession a
			WHERE m._Marker_Type_key = %d
				AND m._Organism_key = %d
				AND m._Marker_key = a._Object_key
				AND a._LogicalDB_key = %d
				AND a._MGIType_key = %d''' % \
					(GENE, MOUSE, HOMOLOGENE, MARKER),
	},
	{
		'abbrev' : 'omimUsed',
		'name' : 'Human diseases with genotypic mouse models',
		'def' : 'Human diseases with current genotypic mouse models; includes only those associated with an allele',
		'private' : 0,
		'int' : 1,
		'sql' : '''SELECT COUNT(DISTINCT(_Term_key))
			FROM MRK_OMIM_Cache
			WHERE _Allele_key != null''',
	},
	{
		'abbrev' : 'genotypesOmim',
		'name' : 'Mouse genotypes modeling human diseases',
		'def' : 'Mouse genotypes modeling human diseases',
		'private' : 0,
		'int' : 1,
		'sql' : '''SELECT COUNT(DISTINCT _Genotype_key)
			FROM MRK_OMIM_Cache''',
	},
	{
		'abbrev' : 'allelesTarg',
		'name' : 'Targeted alleles',
		'def' : 'Alleles of one of the various targeted types',
		'private' : 0,
		'int' : 1,
		'sql' : '''SELECT COUNT(_Allele_key)
			FROM ALL_Allele
			WHERE _Allele_Type_key IN (847116, 847117, 847118,
				847119, 847120)
				AND _Allele_Status_key = %d''' % \
					APPROVED_ALLELE,
	},
	{
		'abbrev' : 'allelesTran',
		'name' : 'Transgenes',
		'def' : 'Alleles of one of the various transgene types',
		'private' : 0,
		'int' : 1,
		'sql' : '''SELECT COUNT(_Allele_key)
			FROM ALL_Allele
			WHERE _Allele_Type_key IN (847126, 847127, 847128,
				847129, 2327160)
				AND _Allele_Status_key = %d''' % \
					APPROVED_ALLELE,
	},
	{
		'abbrev' : 'allelesSpMut',
		'name' : 'Spontaneous or mutagenized alleles',
		'def' : 'All spontaneous, chemical induced, ' + \
				'and radiation induced alleles',
		'private' : 0,
		'int' : 1,
		'sql' : '''SELECT COUNT(_Allele_key)
			FROM ALL_Allele
			WHERE _Allele_Type_key IN (847122, 847123, 847124, 
				847115, 847125)
				AND _Allele_Status_key = %d''' % \
					APPROVED_ALLELE,
	},
	{
		'abbrev' : 'allelesGT',
		'name' : 'Gene trapped alleles',
		'def' : 'Alleles of the gene trapped type',
		'private' : 0,
		'int' : 1,
		'sql' : '''SELECT COUNT(_Allele_key)
			FROM ALL_Allele
			WHERE _Allele_Type_key = 847121
				AND _Allele_Status_key = %d''' % \
					APPROVED_ALLELE,
	},
	{
		'abbrev' : 'allelesGTMP',
		'name' : 'Gene trapped alleles with mouse phenotype ' + \
			'annotations',
		'def' : 'Gene trapped alleles which are part of genotypes which have mouse phenotype annotations',
		'private' : 0,
		'int' : 1,
		'sql' : '''SELECT COUNT(DISTINCT g._Allele_key)
			FROM VOC_Annot v, GXD_AlleleGenotype g, ALL_Allele a
			WHERE v._AnnotType_key = %d
				AND v._Object_key = g._Genotype_key
				AND g._Allele_key = a._Allele_key
				AND a._Allele_Status_key = %d
				AND a._Allele_Type_key = 847121''' % \
					(GENOTYPE_MP, APPROVED_ALLELE),
	},
	{
		'abbrev' : 'allelesCreFlp',
		'name' : 'Cre/Flp expressing Transgenes & Knock-Ins',
		'def' : 'Cre/Flp expressing Transgenes & Knock-Ins',
		'private' : 0,
		'int' : 1,
		'sql' : '''SELECT COUNT(_Allele_key)
			FROM ALL_Allele
			WHERE (_Allele_Type_key = 847128)
			OR (_Allele_Type_key = 847117 AND 
				(symbol LIKE '%(%cre%)%'
				OR symbol LIKE '%(%flp%)%') )''',
	},
	{
		'abbrev' : 'markersQTL',
		'name' : 'QTL',
		'def' : 'Current and interim mouse QTLs',
		'private' : 0,
		'int' : 1,
		'sql' : '''SELECT COUNT(1)
			FROM MRK_Marker
			WHERE _Marker_Type_key = %d
				AND _Marker_Status_key IN (1,3)
				AND _Organism_key = 1''' % QTL,
	},
	{
		'abbrev' : 'omimTerms',
		'name' : 'OMIM disease terms',
		'def' : 'OMIM disease terms',
		'private' : 0,
		'int' : 1,
		'sql' : '''SELECT COUNT(1)
			FROM VOC_Term
			WHERE _Vocab_key = %d''' % OMIM_VOCAB,
	},
	{
		'abbrev' : 'mpTerms',
		'name' : 'Mammalian Phenotype (MP) ontology terms',
		'def' : 'Mammalian Phenotype (MP) ontology terms, excluding those marked as obsolete',
		'private' : 0,
		'int' : 1,
		'sql' : '''SELECT COUNT(1)
			FROM VOC_Term
			WHERE _Vocab_key = %d
				AND isObsolete = 0''' % MP_VOCAB,
	},
	{
		'abbrev' : 'allelesQtlMP',
		'name' : 'QTL alleles with phenotype data',
		'def' : 'QTL alleles which are part of genotypes which have associated phenotype data',
		'private' : 0,
		'int' : 1,
		'sql' : '''SELECT COUNT(DISTINCT g._Allele_key)
			FROM VOC_Annot v, GXD_AlleleGenotype g, ALL_Allele a
			WHERE v._AnnotType_key = %d
				AND v._Object_key = g._Genotype_key
				AND g._Allele_key = a._Allele_key
				AND a._Allele_Status_key = %d
				AND a._Allele_Type_key = %d''' % \
					(GENOTYPE_MP, APPROVED_ALLELE,
					QTL_ALLELE),
	},
	{
		'abbrev' : 'allelesImg',
		'name' : 'Alleles with images',
		'def' : 'Alleles which have associated phenotype images',
		'private' : 0,
		'int' : 1,
		'sql' : '''SELECT COUNT(DISTINCT _Object_key)
			FROM IMG_ImagePane_Assoc
			WHERE _MGIType_key = %d''' % ALLELE,
	},
	{
		'abbrev' : 'gxdGenesLit',
		'name' : 'Genes studied in expression references',
		'def' : 'Genes or other markers studied in expression references',
		'private' : 0,
		'int' : 1,
		'sql' : 'SELECT COUNT(DISTINCT _Marker_key) FROM GXD_Index',
	},
	{
		'abbrev' : 'gxdGenesRes',
		'name' : 'Genes with expression assay results in GXD',
		'def' : 'Current and interim genes and other markers with expression assay results in GXD',
		'private' : 0,
		'int' : 1,
		'sql' : '''SELECT COUNT(DISTINCT ge._Marker_key)
			FROM GXD_Expression ge, MRK_Marker mm
			WHERE ge._Marker_key = mm._Marker_key
				AND mm._Organism_key = %d
				AND mm._Marker_Status_key IN (1,3)''' % MOUSE,
	},
	{
		'abbrev' : 'gxdResults',
		'name' : 'Expression assay results',
		'def' : 'Expression assay results',
		'private' : 0,
		'int' : 1,
		'sql' : 'SELECT COUNT(1) FROM GXD_Expression',
	},
	{
		'abbrev' : 'gxdImages',
		'name' : 'Expression images',
		'def' : 'Expression images',
		'private' : 0,
		'int' : 1,
		'sql' : '''SELECT COUNT(DISTINCT _Image_key)
			FROM IMG_Image
			WHERE _MGIType_key = %d''' % ASSAY,
	},
	{
		'abbrev' : 'gxdAssays',
		'name' : 'Expression assays',
		'def' : 'Expression assays',
		'private' : 0,
		'int' : 1,
		'sql' : 'SELECT COUNT(1) FROM GXD_Assay',
	},
	{
		'abbrev' : 'gxdMutants',
		'name' : 'Mouse mutants with expression data',
		'def' : 'Mouse mutant alleles with expression data',
		'private' : 0,
		'int' : 1,
		'sql' : '''SELECT COUNT(DISTINCT a._Allele_key)
			FROM GXD_Expression e, GXD_AlleleGenotype g,
				ALL_Allele a
			WHERE e._Genotype_key = g._Genotype_key
				AND g._Allele_key = a._Allele_key
				AND a.isWildType = 0''',
	},
	{
		'abbrev' : 'goGenes',
		'name' : 'Mouse genes with GO annotations',
		'def' : 'Mouse genes with one or more GO annotations',
		'private' : 0,
		'int' : 1,
		'sql' : '''SELECT COUNT(DISTINCT v._Object_key)
			FROM VOC_Annot v,
				MRK_Marker m
			WHERE v._AnnotType_key = %d
				AND v._Object_key = m._Marker_key
				AND m._Marker_Type_key = %d''' % \
					(GO_MARKER, GENE),
	},
	{
		'abbrev' : 'goGenesFun',
		'name' : 'Genes with functional annotation',
		'def' : 'Mouse genes with one or more GO annotations',
		'private' : 0,
		'int' : 1,
		'sql' : '''SELECT COUNT(DISTINCT v._Object_key)
			FROM VOC_Annot v,
				MRK_Marker m
			WHERE v._AnnotType_key = %d
				AND v._Object_key = m._Marker_key
				AND m._Marker_Type_key = %d''' % \
					(GO_MARKER, GENE),
	},
	{
		'abbrev' : 'goRefs',
		'name' : 'Unique references used for GO annotations',
		'def' : 'Unique references used for GO annotations, ' + \
			'including only those which have PubMed IDs',
		'private' : 0,
		'int' : 1,
		'sql' : '''SELECT COUNT(DISTINCT e._Refs_key)
			FROM VOC_Annot v,
			    VOC_Evidence e,
			    ACC_Accession a
			WHERE v._AnnotType_key = %d
			    AND v._Annot_key = e._Annot_key
			    AND e._Refs_key = a._Object_key
			    AND a._MGIType_key = %d
			    AND a._LogicalDB_key = (SELECT _LogicalDB_key
			    	FROM ACC_LogicalDB
				WHERE name = 'PubMed')''' % (GO_MARKER, REF),
	},
	{
		'abbrev' : 'goGenesExp',
		'name' : 'Mouse genes with experimentally-derived GO ' + \
				'annotations',
		'def' : 'Mouse genes with one or more GO annotations ' + \
				'with evidence codes ISS, IDA, IMP, ' + \
				'IGI, or IPI',
		'private' : 0,
		'int' : 1,
		'sql' : '''SELECT COUNT(DISTINCT v._Object_key)
			FROM VOC_Annot v,
				MRK_Marker m,
				VOC_Evidence e,
				VOC_Term t
			WHERE v._AnnotType_key = %d
				AND v._Object_key = m._Marker_key
				AND m._Marker_Type_key = %d
				AND v._Annot_key = e._Annot_key
				AND e._EvidenceTerm_key = t._Term_key
				AND t.abbreviation IN ('ISS', 'IDA', 'IMP',
					'IGI', 'IPI')''' % (GO_MARKER, GENE),
	},
	{
		'abbrev' : 'goMarkersBP',
		'name' : 'Genes/markers with Gene Ontology (GO) ' + \
				'Process Annotations',
		'def' : 'Genes and markers with one or more GO biological process annotations',
		'private' : 0,
		'int' : 1,
		'sql' : '''SELECT COUNT(DISTINCT v._Object_key)
			FROM VOC_Annot v, DAG_Node d
			WHERE v._AnnotType_key = %d
				AND v._Term_key = d._Object_key
				AND d._DAG_key = %d''' % (GO_MARKER, GO_BP),
	},
	{
		'abbrev' : 'goMarkersCC',
		'name' : 'Genes/markers with Gene Ontology (GO) ' + \
				'Cellular Component Annotations',
		'def' : 'Genes and markers with one or more GO cellular component annotations',
		'private' : 0,
		'int' : 1,
		'sql' : '''SELECT COUNT(DISTINCT v._Object_key)
			FROM VOC_Annot v, DAG_Node d
			WHERE v._AnnotType_key = %d
				AND v._Term_key = d._Object_key
				AND d._DAG_key = %d''' % (GO_MARKER, GO_CC),
	},
	{
		'abbrev' : 'goMarkersMF',
		'name' : 'Genes/markers with Gene Ontology (GO) ' + \
				'Functional Annotations',
		'def' : 'Genes and markers with one or more GO molecular function annotations',
		'private' : 0,
		'int' : 1,
		'sql' : '''SELECT COUNT(DISTINCT v._Object_key)
			FROM VOC_Annot v, DAG_Node d
			WHERE v._AnnotType_key = %d
				AND v._Term_key = d._Object_key
				AND d._DAG_key = %d''' % (GO_MARKER, GO_MF),
	},
	{
		'abbrev' : 'goAnnotAll',
		'name' : 'GO annotations total',
		'def' : 'Total number of annotations using GO in MGI',
		'private' : 0,
		'int' : 1,
		'sql' : '''SELECT COUNT(1)
			FROM VOC_Annot v
			WHERE v._AnnotType_key = %d''' % GO_MARKER,
	},
	{
		'abbrev' : 'mpAnnotAll',
		'name' : 'MP annotations total',
		'def' : 'Total number of annotations using MP in MGI',
		'private' : 0,
		'int' : 1,
		'sql' : '''SELECT COUNT(1)
			FROM VOC_Annot v
			WHERE v._AnnotType_key = %d''' % GENOTYPE_MP,
	},
	{
		'abbrev' : 'refsnps',
		'name' : 'RefSNPs',
		'def' : 'Number of reference single-nucleotide polymorphisms',
		'private' : 0,
		'int' : 1,
		'sql' : 'SELECT COUNT(1) FROM %s..SNP_ConsensusSnp' % SNP_DB,
	},
	{
		'abbrev' : 'snpStrains',
		'name' : 'Strains with SNPs',
		'def' : 'Number of strains with reference ' + \
				'single-nucleotide polymorphisms',
		'private' : 0,
		'int' : 1,
		'sql' : 'SELECT COUNT(1) FROM %s..SNP_Strain' % SNP_DB,
	},
	{
		'abbrev' : 'polyGenes',
		'name' : 'Genes with polymorphisms',
		'def' : 'Current and interim genes with PCR/RFLP polymorphisms',
		'private' : 0,
		'int' : 1,
		'sql' : '''SELECT COUNT(DISTINCT pr._Marker_key)
			FROM PRB_RFLV pr,
				MRK_Marker m
			WHERE pr._Marker_key = m._Marker_key
				AND m._Marker_Status_key IN (1,3)
				AND m._Marker_Type_key = %d''' % GENE,
	},
	{
		'abbrev' : 'polyMarkers',
		'name' : 'Markers with polymorphisms',
		'def' : 'Markers with PCR/RFLP polymorphisms',
		'private' : 0,
		'int' : 1,
		'sql' : 'SELECT COUNT(DISTINCT _Marker_key) FROM PRB_RFLV',
	},
	{
		'abbrev' : 'strains',
		'name' : 'Strains',
		'def' : 'Standard mouse strains',
		'private' : 0,
		'int' : 1,
		'sql' : '''SELECT COUNT(1)
			FROM PRB_Strain
			WHERE standard = 1''',
	},
	{
		'abbrev' : 'orthoMusHum',
		'name' : 'Genes with orthologs in Human',
		'def' : 'Mouse genes with human orthologs',
		'private' : 0,
		'int' : 1,
		'sql' : '''SELECT COUNT(DISTINCT hm._Class_key)
			FROM MRK_Homology_Cache hm,
				MRK_Homology_Cache hh
			WHERE hm._Class_key = hh._Class_key
				AND hm._Organism_key = %d
				AND hh._Organism_key = %d''' % (MOUSE, HUMAN),
	},
	{
		'abbrev' : 'orthoMusRat',
		'name' : 'Genes with orthologs in Rat',
		'def' : 'Mouse genes with rat orthologs',
		'private' : 0,
		'int' : 1,
		'sql' : '''SELECT COUNT(DISTINCT hm._Class_key)
			FROM MRK_Homology_Cache hm,
				MRK_Homology_Cache hr
			WHERE hm._Class_key = hr._Class_key
				AND hm._Organism_key = %d
				AND hr._Organism_key = %d''' % (MOUSE, RAT),
	},
	{
		'abbrev' : 'orthoMusChi',
		'name' : 'Genes with orthologs in Chimp',
		'def' : 'Mouse genes with chimp orthologs',
		'private' : 0,
		'int' : 1,
		'sql' : '''SELECT COUNT(DISTINCT hm._Class_key)
			FROM MRK_Homology_Cache hm,
				MRK_Homology_Cache hr
			WHERE hm._Class_key = hr._Class_key
				AND hm._Organism_key = %d
				AND hr._Organism_key = %d''' % (MOUSE, CHIMP),
	},
	{
		'abbrev' : 'orthoMusDog',
		'name' : 'Genes with orthologs in Dog',
		'def' : 'Mouse genes with dog orthologs',
		'private' : 0,
		'int' : 1,
		'sql' : '''SELECT COUNT(DISTINCT hm._Class_key)
			FROM MRK_Homology_Cache hm,
				MRK_Homology_Cache hr
			WHERE hm._Class_key = hr._Class_key
				AND hm._Organism_key = %d
				AND hr._Organism_key = %d''' % (MOUSE, DOG),
	},
	{
		'abbrev' : 'ortho',
		'name' : 'Genes with orthologs (any)',
		'def' : 'Total orthologies, all species',
		'private' : 0,
		'int' : 1,
		'sql' : 'SELECT COUNT(1) FROM HMD_Class',
	},
	{
		'abbrev' : 'seqNuc',
		'name' : 'Mouse nucleotide sequences',
		'def' : 'Mouse nucleotide sequences',
		'private' : 0,
		'int' : 1,
		'sql' : '''SELECT COUNT(1)
			FROM SEQ_Sequence
			WHERE _SequenceType_key = %d
				AND _Organism_key = 1''' % NUCLEOTIDE_KEY,
	},
	{
		'abbrev' : 'seqTran',
		'name' : 'Mouse transcript sequences',
		'def' : 'Mouse transcript sequences',
		'private' : 0,
		'int' : 1,
		'sql' : '''SELECT COUNT(1)
			FROM SEQ_Sequence
			WHERE _SequenceType_key = %d
				AND _Organism_key = 1''' % TRANSCRIPT_KEY,
	},
	{
		'abbrev' : 'seqPoly',
		'name' : 'Mouse polypeptide sequences',
		'def' : 'Mouse polypeptide sequences',
		'private' : 0,
		'int' : 1,
		'sql' : '''SELECT COUNT(1)
			FROM SEQ_Sequence
			WHERE _SequenceType_key = %d
				AND _Organism_key = 1''' % PROTEIN_KEY,
	},
	{
		'abbrev' : 'refs',
		'name' : 'References',
		'def' : 'References in MGI',
		'private' : 0,
		'int' : 1,
		'sql' : 'SELECT COUNT(1) FROM BIB_Refs',
	},
	{
		'abbrev' : 'gxdRefs',
		'name' : 'References indexed for expression',
		'def' : 'References in GXD literature index',
		'private' : 0,
		'int' : 1,
		'sql' : 'SELECT COUNT(DISTINCT _Refs_key) FROM GXD_Index',
	},
	{
		'abbrev' : 'polyPcr',
		'name' : 'PCR polymorphism records',
		'def' : 'PCR polymorphism records - unique reports of a gene, probe, restriction enzyme and set of strain polymorphisms detected',
		'private' : 0,
		'int' : 1,
		'sql' : '''select count (pr._Reference_key) 
			from PRB_Probe pp, PRB_RFLV pr, PRB_Reference ref,
				VOC_Term vt
			where pp._SegmentType_key = vt._Term_key
				and pr._Reference_key = ref._Reference_key
				and ref._Probe_key = pp._Probe_key
				and vt.term = 'primer' ''',
	},
	{
		'abbrev' : 'polyRflp',
		'name' : 'RFLP records',
		'def' : 'RFLP records - unique reports of a gene, probe, restriction enzyme and set of strain polymorphisms detected',
		'private' : 0,
		'int' : 1,
		'sql' : '''select count (pr._Reference_key) 
			from PRB_Probe pp, PRB_RFLV pr, PRB_Reference ref,
				VOC_Term vt
			where pp._SegmentType_key = vt._Term_key
				and pr._Reference_key = ref._Reference_key
				and ref._Probe_key = pp._Probe_key
				and vt.term != 'primer' ''',
	},
	{
		'abbrev' : 'pwPathways',
		'name' : 'Pathways',
		'def' : 'Biological pathways',
		'private' : 0,
		'int' : 1,
	},
	{
		'abbrev' : 'pwEnzymaticRx',
		'name' : 'Enzymatic reactions',
		'def' : 'Enzymatic reactions',
		'private' : 0,
		'int' : 1,
	},
	{
		'abbrev' : 'pwTransportRx',
		'name' : 'Transport reactions',
		'def' : 'Transport reactions',
		'private' : 0,
		'int' : 1,
	},
	{
		'abbrev' : 'pwPolypeptide',
		'name' : 'Polypeptides',
		'def' : 'Polypeptides',
		'private' : 0,
		'int' : 1,
	},
	{
		'abbrev' : 'pwProtein',
		'name' : 'Protein complexes',
		'def' : 'Protein complexes',
		'private' : 0,
		'int' : 1,
	},
	{
		'abbrev' : 'pwTransporter',
		'name' : 'Transporters',
		'def' : 'Transporters',
		'private' : 0,
		'int' : 1,
	},
	{
		'abbrev' : 'pwCompounds',
		'name' : 'Compounds',
		'def' : 'Compounds',
		'private' : 0,
		'int' : 1,
	},
	]

statisticGroups = [
	('Home Page' , [
		'genesUncMut', 'genesNucl', 'goGenesFun', 'mutantAlleles',
		'gxdAssays', 'orthoMusHum', 'omimUsed', 'refs', 'refsnps',
		]),
	('Marker Mini Home' , [
		'genesUncMut', 'genesNucl', 'genesProt', 'goGenesFun',
		'genesGT',
		]),
	('Stats Page Markers' , [
		'genesUncMut', 'genesNucl', 'genesProt', 'goGenesFun',
		'genesGT', 'genesExpr', 'markersMap',
		]),
	('Pheno Mini Home' , [
		'mutantAlleles', 'genesMutant', 'genotypesAnno', 'omimUsed',
		]),
	('Stats Page Phenotypes' , [
		'mutantAlleles', 'genesMutant', 'genotypesAnno', 'omimUsed',
		'allelesTarg', 
		'allelesCreFlp','mpTerms', 'mpAnnotAll', 'markersQTL',
		]),
	('GXD Mini Home' , [
		'gxdGenesLit', 'gxdGenesRes', 'gxdResults', 'gxdImages',
		'gxdAssays', 'gxdMutants',
		]),
	('Stats Page GXD' , [
		'gxdGenesLit', 'gxdGenesRes', 'gxdResults', 'gxdImages',
		'gxdAssays', 'gxdMutants',
		]),
	('GO Mini Home' , [
		'goGenes', 'goGenesExp', 'goAnnotAll', 'goRefs',
		]),
	('Stats Page GO' , [
		'goGenes', 'goGenesExp', 'goAnnotAll', 'goRefs',
		]),
	('SNP Mini Home' , [
		'refsnps', 'snpStrains', 'polyRflp', 'polyPcr',
		]),
	('Stats Page Polymorphisms' , [
		'refsnps', 'snpStrains', 'polyRflp', 'polyPcr',
		'polyGenes', 'polyMarkers', 'strains',
		]),
	('Orthology Mini Home' , [
		'orthoMusHum', 'orthoMusRat', 'orthoMusChi', 'orthoMusDog',
		'ortho', 
		]),
	('Stats Page Orthology' , [
		'orthoMusHum', 'orthoMusRat', 'orthoMusChi', 'orthoMusDog',
		'ortho', 'genesTreeFam',
		]),
	('Stats Page Sequences' , [
		'seqNuc', 'seqTran', 'seqPoly',
		]),
	('References' , [
		'refs',
		]),
	('Pathways Mini Home', [
		'pwPathways', 'pwEnzymaticRx', 'pwTransportRx',
		'pwPolypeptide', 'pwProtein', 'pwTransporter', 'pwCompounds',
		]),
	('Stats Page Pathways', [
		'pwPathways', 'pwEnzymaticRx', 'pwTransportRx',
		'pwPolypeptide', 'pwProtein', 'pwTransporter', 'pwCompounds',
		]),
	]

###------------------------------------------------------------------------###

stats.setSqlFunction (db.sql)

res1 = db.sql ('SELECT COUNT(1) FROM MGI_Statistic', 'auto')
res2 = db.sql ('SELECT COUNT(DISTINCT _Statistic_key) FROM MGI_StatisticSql',
		'auto')
res3 = db.sql ('SELECT COUNT(1) FROM MGI_Measurement', 'auto')

db.sql ('DELETE FROM MGI_Statistic', 'auto')
db.sql ('''DELETE FROM MGI_Set
	WHERE _MGIType_key = (SELECT _MGIType_key 
		FROM ACC_MGIType 
		WHERE name = "Statistic")''', 'auto')

sys.stderr.write ('deleted %d statistics, %d of which had associated SQL\n' %\
	(res1[0][''], res2[0]['']))
sys.stderr.write ('deleted %d measurements for those statistics\n' % \
	res3[0][''])

for s in statistics:
	stat = stats.createStatistic (s['abbrev'], s['name'], s['def'],
		s['private'], s['int'])
	if s.has_key('sql') and s['sql']:
		stat.setSql (s['sql'])

sys.stderr.write ('created %d statistics\n' % len(statistics))

for (name, members) in statisticGroups:
	group = stats.createStatisticGroup (name)
	group.setStatistics (members)

sys.stderr.write ('created %d statistic groups\n' % len(statisticGroups))

stats.measureAllHavingSql()

sys.stderr.write ('added initial measurements\n')
