#!/usr/local/bin/python

# patches several phenotype stats into the GTLF release.  This will need to be run as part
# of the migration.

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

sys.stderr.write ('Starting to update statistics with the following arguments: %s %s %s %s %s\n' 
	% (DB_USER, PWD_FILE, DB_SRV, MGD_DB, SNP_DB))

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


###------------------------------------------------------------------------###

stats.setSqlFunction (db.sql)

# Update existing statistics

## Update the SQL and definition, name for 7 Statistics

updatedStatistics = [
	{
		'abbrev' : 'genesGT',
		'def'	: 'current mouse genes which are associated with gene trap accession IDs via Alleles (from GTLF)',
		'sql'	: '''select count(distinct a._Marker_key)
			from all_allele a, mrk_marker m
			where a._Allele_Type_key = 847121 
			and a._Marker_key != null
			and a._Marker_key = m._Marker_key 
			and m._Organism_key = 1 
			and m._Marker_Status_key != 2
			and m._Marker_type_key = 1'''
	},
	{
		'abbrev' : 'mutantAlleles',
		'name' : 'Total mutant alleles',
		'sql' : '''SELECT COUNT(1)
			FROM ALL_Allele
			WHERE isWildType = 0
			AND _Allele_Type_key != 847130
			AND _Allele_Status_key in (847114, 3983021)'''
	},
	{
		'abbrev' : 'genesMutant',
		'name' : 'Total genes with mutant alleles',
		'sql'	: '''SELECT COUNT(DISTINCT a._Marker_key)
				FROM ALL_Allele a, MRK_Marker m
				WHERE a.isWildType = 0
				AND a._Allele_Type_key != 847130
				AND a._Allele_Status_key in (847114, 3983021)
				AND a._Marker_key = m._Marker_key
				AND m._Marker_Type_key = 1 '''
	},
	{
		'abbrev' : 'allelesTarg',
		'name' : 'Total targeted alleles',
		'sql'	: '''SELECT COUNT(_Allele_key)
				FROM ALL_Allele
				WHERE _Allele_Type_key IN (847116, 847117, 847118,
				847119, 847120)
				AND _Allele_Status_key in (847114, 3983021) '''
	},
	{
		'abbrev' : 'genesTAlleles',
		'sql'	: '''select count(distinct(_Marker_key))
			   from gxd_allelegenotype
			   where _Allele_key in ( 
			   select distinct _allele_key
			   from all_allele
			   WHERE _Allele_Type_key in 
			   (847116, 847117, 847118,847119, 847120)
			   AND _Allele_Status_key in (847114, 3983021))  '''
	},
	{
		'abbrev' : 'knockOutAlleles',
		'name' : 'Total targeted (knock-out) alleles',
		'sql'	: '''SELECT COUNT(_Allele_key)
			   FROM ALL_Allele
			   WHERE _Allele_Type_key = 847116
	           AND _Allele_Status_key in (847114, 3983021) '''
	},
	{
		'abbrev' : 'genesWTAlleles',
		'name' : 'Total genes with targeted (knock-out) alleles',
		'sql'	: '''select count(distinct(_Marker_key))
			   from all_allele
			   where _Allele_Type_key = 847116
			   AND _Allele_Status_key in (847114, 3983021) '''
	},
]

for s in updatedStatistics :
	stat = stats.getStatistic (s['abbrev'])
	if s.has_key('sql'):
		stat.setSql (s['sql'])
	if s.has_key('name'):
		stat.setName(s['name'])
	if s.has_key('def'):
		stat.setDefinition(s['def'])

sys.stderr.write ('Updated %d statistics\n' % len(updatedStatistics))

# Create new statistics

newStatistics = [
	{
		'abbrev' : 'mutantAllelesInMice',
		'name' : 'Mutant alleles in mice',
		'def' : 'approved non-wild type, non-QTL mutant alleles, that are not cell line only',
		'private' : 0,
		'int' : 1,
		'sql' : '''SELECT COUNT(1)
			FROM ALL_Allele
			WHERE isWildType = 0
			AND _Allele_Type_key != 847130
			AND _Allele_Status_key in (847114, 3983021) 
            AND _Transmission_key != 3982953''',
	},
	{
		'abbrev' : 'gtAllelesCellLineOnly',
		'name' : 'Gene trap alleles (cell line only)',
		'def' : 'Gene trap alleles, that are cell line only',
		'private' : 0,
		'int' : 1,
		'sql' : '''SELECT COUNT(1)
			FROM ALL_Allele
			WHERE isWildType = 0
			AND _Allele_Type_key = 847121
			AND _Allele_Status_key in (847114, 3983021) 
            AND _Transmission_key = 3982953''',
	},
	{
		'abbrev' : 'allelesTargInMice',
		'name' : 'Targeted alleles in mice',
		'def' : 'Alleles of one of the various targeted types, that are not cell line only',
		'private' : 0,
		'int' : 1,
		'sql' : '''SELECT COUNT(_Allele_key)
				FROM ALL_Allele
				WHERE _Allele_Type_key IN (847116, 847117, 847118,
				847119, 847120)
				AND _Allele_Status_key in (847114, 3983021)
				and _Transmission_key != 3982953''',
	},	
	{
		'abbrev' : 'knockOutAllelesInMice',
		'name' : 'Targeted (knock-out) alleles in mice',
		'def' : 'Count of targeted (knock-out) alleles, that are not cell line only',
		'private' : 0,
		'int' : 1,
		'sql' : '''SELECT COUNT(_Allele_key)
				FROM ALL_Allele
				WHERE _Allele_Type_key = 847116
				AND _Allele_Status_key in (847114, 3983021)
				and _Transmission_key != 3982953''',
	},	
	{
		'abbrev' : 'knockOutAllelesInCellLine',
		'name' : 'Targeted (knock-out) alleles (IKMC cell line only)',
		'def' : 'Count of targeted (knock-out) alleles, that are cell line only',
		'private' : 0,
		'int' : 1,
		'sql' : '''SELECT COUNT(_Allele_key)
				FROM ALL_Allele
				WHERE _Allele_Type_key = 847116
				AND _Allele_Status_key in (847114, 3983021)
				and _Transmission_key = 3982953''',
	},		
	{
		'abbrev' : 'genesWithMutantAllelesInMice',
		'name' : 'Genes with mutant alleles in mice',
		'def' : 'Count of genes with mutant alleles that have at least one non cell line tranmission status',
		'private' : 0,
		'int' : 1,
		'sql' : '''SELECT COUNT(DISTINCT a._Marker_key)
				FROM ALL_Allele a, MRK_Marker m
				WHERE a.isWildType = 0
				AND a._Allele_Type_key != 847130
				AND a._Allele_Status_key in (847114, 3983021)
				AND a._Marker_key = m._Marker_key
				AND m._Marker_Type_key = 1 
                and a._Transmission_key != 3982953''',
	},
	{
		'abbrev' : 'genesWithGTAllelesCellLineOnly',
		'name' : 'Genes with gene trap alleles (cell line only)',
		'def' : 'Count of genes with gene trap alleles that are cell line only',
		'private' : 0,
		'int' : 1,
		'sql' : '''SELECT COUNT(DISTINCT a._Marker_key)
				FROM ALL_Allele a, MRK_Marker m
				WHERE a.isWildType = 0
				AND a._Allele_Type_key = 847121
				AND a._Allele_Status_key in (847114, 3983021)
				AND a._Marker_key = m._Marker_key
				AND m._Marker_Type_key = 1 
                and a._Transmission_key = 3982953''',
	},	
	{
		'abbrev' : 'genesWithKOInMice',
		'name' : 'Genes with targeted (knock-out) alleles in mice',
		'def' : 'Count of Genes with targeted (knock-out) alleles in mice',
		'private' : 0,
		'int' : 1,
		'sql' : '''select count(distinct(_Marker_key))
			   from all_allele
			   where  _Allele_Type_key = 847116
			   AND _Allele_Status_key in (847114, 3983021)
                and _Transmission_key != 3982953''',
	},	
	{
			'abbrev' : 'genesWithKOInMiceCellLineOnly',
			'name' : 'Genes with targeted (knock-out) alleles (IKMC cell line only)',
			'def' : 'Count of Genes with targeted (knock-out) alleles in cell line only',
			'private' : 0,
			'int' : 1,
			'sql' : '''select count(distinct(a._Marker_key))
			   from all_allele a
			   WHERE a._Allele_Type_key = 847116
			   AND a._Allele_Status_key in (847114, 3983021)
               and exists (select (1) from
                    all_allele a2 where a._Allele_key = a2._Allele_key
                    and a2._Transmission_key = 3982953)
               and not exists (select (1) from
                    all_allele a3 where a._Allele_key = a3._Allele_key
                    and a3._Transmission_key != 3982953)''',
	},	
	]

for s in newStatistics :
	stat = stats.createStatistic (s['abbrev'], s['name'], s['def'],
		s['private'], s['int'])
	if s.has_key('sql') and s['sql']:
		stat.setSql (s['sql'])

sys.stderr.write ('created %d statistics\n' % len(newStatistics))

# Change the Order of the stats for the Pheno minihome

phenoGroup = stats.StatisticGroup('Pheno Mini Home')

phenoGroupOrder = ['mutantAllelesInMice','genesWithMutantAllelesInMice','genotypesAnno','omimUsed']

phenoGroup.setStatistics(phenoGroupOrder)

sys.stderr.write ('changed the order for the Pheno page\n')

# Change the Order of the stats for the All Stats page

allStatsGoGroup = stats.StatisticGroup('Stats Page Phenotypes')

allStatsGoGroupOrder = ['mutantAlleles','mutantAllelesInMice','gtAllelesCellLineOnly', 'genesMutant', 
	'genesWithMutantAllelesInMice',	'genesWithGTAllelesCellLineOnly','genotypesAnno',
	'omimUsed','genotypesOmim','allelesTarg','allelesTargInMice','genesTAlleles','knockOutAlleles',
	'knockOutAllelesInMice','knockOutAllelesInCellLine','genesWTAlleles','genesWithKOInMice',
	'genesWithKOInMiceCellLineOnly','allelesCreFlp','mpTerms','mpAnnotAll','markersQTL']

allStatsGoGroup.setStatistics(allStatsGoGroupOrder)

sys.stderr.write ('Changed the order for the all stats page.\n')

stats.measureAllHavingSql()

sys.stderr.write ('Done regenerating the stats.\n')

sys.stderr.write ('done.')
