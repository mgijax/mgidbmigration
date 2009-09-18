#!/usr/local/bin/python

# Creates a bunch of groups and stats for the cre release.
# 

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

# Create two new statistic groups

stats.createStatisticGroup("Cre Mini Home")
stats.createStatisticGroup("Stats Page Cre")

# Create new statistics

newStatistics = [
	{
		'abbrev' : 'creInKnockInAlleles',
		'name' : 'Recombinase-containing knock-in alleles',
		'def' : 'Recombinase-containing knock-in alleles',
		'private' : 0,
		'int' : 1,
		'sql' : '''select count(distinct _Allele_key) from ALL_Cre_Cache
				where _Allele_Type_key = 847117''',
	},	
	{
		'abbrev' : 'creInTransgenes',
		'name' : 'Recombinase-containing transgenes',
		'def' : 'Recombinase-containing transgenes',
		'private' : 0,
		'int' : 1,
		'sql' : '''select count(distinct _Allele_key) from ALL_Cre_Cache
				where _Allele_Type_key = 847128''',
	},	
	{
		'abbrev' : 'creTotal',
		'name' : 'Total recombinase transgenes and alleles',
		'def' : 'Total recombinase transgenes and alleles',
		'private' : 0,
		'int' : 1,
		'sql' : '''select count(distinct _Allele_key) from ALL_Cre_Cache
				where _Allele_Type_key in (847117, 847128)''',
	},		
	{
		'abbrev' : 'creDriversInKnockIn',
		'name' : 'Drivers in recombinase transgenes',
		'def' : 'Drivers in recombinase transgenes',
		'private' : 0,
		'int' : 1,
		'sql' : '''select count(distinct driverNote) from ALL_Cre_Cache 
				where _Allele_Type_key = 847117''',
	},
	{
		'abbrev' : 'creDriversInTransgenes',
		'name' : 'Drivers in recombinase knock-in alleles',
		'def' : 'Drivers in recombinase knock-in alleles',
		'private' : 0,
		'int' : 1,
		'sql' : '''select count (distinct driverNote) from ALL_Cre_Cache 
				where _Allele_Type_key = 847128''',
	},	
	{
		'abbrev' : 'tissuesInRecombinaseSpecAssay',
		'name' : 'Tissues in recombinase specificity assays',
		'def' : 'Tissues in recombinase specificity assays',
		'private' : 0,
		'int' : 1,
		'sql' : '''select count(distinct _Structure_key) from All_Cre_cache''',
	},	
	]

for s in newStatistics :
	stat = stats.createStatistic (s['abbrev'], s['name'], s['def'],
		s['private'], s['int'])
	if s.has_key('sql') and s['sql']:
		stat.setSql (s['sql'])

sys.stderr.write ('created %d statistics\n' % len(newStatistics))

# Change the Order of the stats for the Pheno minihome

creGroup = stats.StatisticGroup('Cre Mini Home')

creGroupOrder = ['creInKnockInAlleles','creInTransgenes','creTotal','creDriversInKnockIn', 
				'creDriversInTransgenes', 'tissuesInRecombinaseSpecAssay']

creGroup.setStatistics(creGroupOrder)

sys.stderr.write ('Created the order for the Cre Minihome\n')

# Change the Order of the stats for the All Stats page

allStatsCreGroup = stats.StatisticGroup('Stats Page Cre')

allStatsCreGroupOrder = ['creInKnockInAlleles','creInTransgenes','creTotal','creDriversInKnockIn', 
				'creDriversInTransgenes', 'tissuesInRecombinaseSpecAssay']

allStatsCreGroup.setStatistics(allStatsCreGroupOrder)

sys.stderr.write ('Changed the order for the all stats page.\n')

stats.measureAllHavingSql()

sys.stderr.write ('Done regenerating the stats.\n')

sys.stderr.write ('done.')
