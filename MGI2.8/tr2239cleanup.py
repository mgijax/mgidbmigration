#!/usr/local/bin/python

'''
#
# remove duplicate Genotypes
#
'''
 
import sys 
import string
import db

def cleanup(cmds, hasAllele = 0):

	results = db.sql(cmds, 'auto')

	prevStrain = ''
	prevObject = 0
	deleteRec = 0
	keepRec = -5

	for r in results[-1]:

		if prevObject != r['_Genotype_key'] and keepRec > -5 and deleteRec > 0:
			delit = cleanUp % (keepRec, deleteRec, keepRec, deleteRec, keepRec, deleteRec) + \
			'\ndelete from GXD_Genotype where _Genotype_key = %d' % (deleteRec)

			if not DEBUG:
				db.sql(delit, None)

			print delit
			deleteRec = 0

		if hasAllele:
			checkStrain = r['strain'] + ':' + r['allele1'] + ':' + r['allele2']
		else:
			checkStrain = r['strain']

		if prevStrain != checkStrain:
			print checkStrain
			deleteRec = 0
			keepRec = -5

		if keepRec > -5:
			deleteRec = int(r['_Genotype_key'])
		else:
			keepRec = int(r['_Genotype_key'])

		if hasAllele:
			prevStrain = r['strain'] + ':' + r['allele1'] + ':' + r['allele2']
		else:
			prevStrain = r['strain']

		prevObject = r['_Genotype_key']

	if keepRec > -5 and deleteRec > 0:
		delit = cleanUp % (keepRec, deleteRec, keepRec, deleteRec, keepRec, deleteRec) + \
		'\ndelete from GXD_Genotype where _Genotype_key = %d' % (deleteRec)

		if not DEBUG:
			db.sql(delit, None)

		print delit

	db.sql('checkpoint', None)

def nopairs():

	# select all genotypes w/out allele pairs

	cmds = []

	cmds.append('select _Genotype_key, strain ' + \
	'into #strains ' + \
	'from GXD_Genotype_View s ' + \
	'where not exists (select 1 from GXD_AllelePair a ' + \
	'where s._Genotype_key = a._Genotype_key) ' + \
	'order by strain, _Genotype_key')

	cmds.append('select * into #dups from #strains group by strain having count(*) > 1')
	cmds.append('select * from #dups order by strain, _Genotype_key')

	cleanup(cmds)

def onepair():

	# select all duplicate genotypes with 1 allele pair

	cmds = []


	cmds.append('select strain, allele1, allele2, _Genotype_key into #strains from GXD_AllelePair_View')
	cmds.append('select * into #onepair from #strains group by _Genotype_key having count(*) = 1')
	cmds.append('select * into #dups from #onepair group by strain, allele1, allele2 having count(*) > 1')
	cmds.append('select * from #dups order by strain, allele1, allele2, _Genotype_key')

	cleanup(cmds, hasAllele = 1)

def twopair():

	# select all duplicate genotypes with 2 allele pair

	cmds = []


	cmds.append('select strain, allele1, allele2, _Genotype_key into #strains from GXD_AllelePair_View')
	cmds.append('select * into #twopair from #strains group by _Genotype_key having count(*) = 2')
	cmds.append('select * into #dups from #twopair group by strain, allele1, allele2 having count(*) > 1')
	cmds.append('select * from #dups order by strain, allele1, allele2, _Genotype_key')

	cleanup(cmds, hasAllele = 1)

#
# Main
#

DEBUG = 0

db.set_sqlServer(sys.argv[1])
db.set_sqlDatabase(sys.argv[2])
db.set_sqlUser('mgd_dbo')
db.set_sqlPassword(string.strip(open('/usr/local/mgi/dbutils/mgidbutilities/.mgd_dbo_password', 'r').readline()))

cleanUp = "update GXD_GelLane set _Genotype_key = %d where _Genotype_key = %d " + \
	  "\nupdate GXD_Specimen set _Genotype_key = %d where _Genotype_key = %d " + \
	  "\nupdate GXD_Expression set _Genotype_key = %d where _Genotype_key = %d"

nopairs()
onepair()
twopair()

