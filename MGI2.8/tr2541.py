#!/usr/local/bin/python

'''
#
# tr2541.py
#
# Update MGI from Strain File (EB/Larry's Database)
#
# Usage:
#       tr2541.py DBSERVER DBNAME InputFile
#
# Adds:
# 	Search by JRS registry ID and Strain
# 	If Strain in InputFile and not in MGI, add it
#
# Updates:
#	Search by Strain; for all Strain matches in MGI:
#		If gene symbols in JRS, not valid in MGI => QC report; send to jte
#		If gene symbols in JRS, not in MGI Strain => add to MGI Strain
#		If strain types in JRS, not in MGI => QC report; send to jte
#		If no JR# in MGI, add it
#
# Conflicts - send to jte
#	JRS registry ID matches, but strains don't
#	Instances where MGI has the same Strain as JRS, but the registry IDs don't match
#
#
# Notes:
#	- all reports use mgireport directory for output file
#	- all reports use db default of public login
#	- all reports use server/database default of environment
#	- use lowercase for all SQL commands (i.e. select not SELECT)
#	- all public SQL reports require the header and footer
#	- all private SQL reports require the header
#
# History:
#
# lec	12/10/2001
#	- created
#
'''
 
import sys 
import string
import db

def modify_genes(genes):

	newgenes = []

	for g in genes:

		i = string.find(g, '+<')
		j = string.find(g, '>')

		if i >= 0:
			newgene = g[i+2:j]

		else:
			i = string.find(g, '<')

			if i >= 0:
				newgene = g[:i]
			else:
				newgene = g
	
		if newgene not in newgenes:
			newgenes.append(newgene)

	return (newgenes)

def process_adds(results):
	global markers, strainmarker

	addFile = open('tr2541.add.out', 'w')
	addmarkerFile = open('tr2541.addmarkers.out', 'w')

	keyresults = db.sql('select max(_Strain_key) + 1 from PRB_Strain', 'auto')
	strainKey = keyresults[0]['']

	if DOIT:
		keyresults = db.sql('select max(_Synonym_key) + 1 from PRB_Strain_Synonym', 'auto')
		synonymKey = keyresults[0]['']
	else:
		synonymKey = 1

	for r in results:

		add = []

		# if wild-derived strain type, then species is unknown for now

		speciesKey = 197
		for st in (r['mgikey1'], r['mgikey2'], r['mgikey3']):
			if st is not None:
				if st == 31:
					speciesKey = -1

		if r['privacy'] == 'private':
			isPrivate = 1
		else:
			isPrivate = 0

		add.append('insert into MLP_Strain (_Strain_key, _Species_key) values (%s, %d)\n' % (strainKey, speciesKey))
		# note that the insert trigger will create the MGI Accession ID for the standard strains
		add.append('insert into PRB_Strain (_Strain_key, strain, standard, needsReview, private) ' + \
			'values (%s, "%s", 1, 0, %d)\n' % (strainKey, r['strain'], isPrivate))
		add.append('insert into MLP_Extra (_Strain_key) values (%s)\n' % (strainKey))
		
		if r['registry'] is not None:
			add.append('exec ACC_insert %s, "%s", 22, "Strain", @private = 1\n' % (strainKey, r['registry']))

		if r['genes'] is not None:
			genes = modify_genes(string.split(r['genes'], '|'))
			for g in genes:
				markerKey = '0'

				if markers.has_key(g):
					markerKey = markers[g]
				else:
					mResults = db.sql('select distinct _Current_key ' + \
						'from MRK_Current_View where symbol = "%s"' % (g), 'auto')
	
					if len(mResults) > 0:
						markerKey = mResults[0]['_Current_key']
						markers[g] = markerKey

				if markerKey != '0':
					smKey = `strainKey` + ":" + `markerKey`
					if not strainmarker.has_key(smKey):
						add.append('insert into PRB_Strain_Marker (_Strain_key, _Marker_key) ' + \
							'values (%s, %s)\n'  % (strainKey, markerKey))
						strainmarker[smKey] = smKey
				else:
					addmarkerFile.write('JRS [%s]; Strain [%s]; Marker [%s]\n' % (r['registry'], r['strain'], g))

		if r['synonyms'] is not None:
			add.append('insert into PRB_Strain_Synonym (_Strain_key, _Synonym_key, synonym) ' + \
				'values (%s, %s, "%s")\n' % (strainKey, synonymKey, r['synonyms']))
			synonymKey = synonymKey + 1

		for st in (r['mgikey1'], r['mgikey2'], r['mgikey3']):
			if st is not None:
				add.append('insert into MLP_StrainTypes (_Strain_key, _StrainType_key) ' + \
					'values (%s, %s)\n' % (strainKey, st))
			
		db.sql(add, None, execute = DOIT)
		strainKey = strainKey + 1
		diagFile.write(str(add) + '\n\n')
		addFile.write(str(r) + '\n\n')
		print str(add)

	addFile.close()
	addmarkerFile.close()

#
# Process Updates
#
# - Add JRS Registry ID if it does not already exist
# - Add any Gene Symbols which don't exist
# - Add Synonyms
# - Add Strain Types which don't exist
#

def process_updates(results):
	global markers, strainmarker

	updateFile = open('tr2541.update.out', 'w')
	updmarkerFile = open('tr2541.updmarkers.out', 'w')

	strainmarker = {}

	keyresults = db.sql('select max(_Synonym_key) + 1 from PRB_Strain_Synonym', 'auto')
	synonymKey = keyresults[0]['']

	for r in results:
	
		upd = []

		# should this check for the specific registry ID and load it
		# even if another registry ID exists for the Strain?
		# or should this check look for ANY registry ID associated with the Strain?

		exists = db.sql('select _Object_key from PRB_Strain_Acc_View ' + \
			'where accID = "%s"' % (r['registry']), 'auto')
		if len(exists) == 0:
			upd.append('exec ACC_insert %s, "%s", 22, "Strain", @private = 1\n' % (r['_Strain_key'], r['registry']))

		if r['genes'] is not None:
			genes = modify_genes(string.split(r['genes'], '|'))
			for g in genes:

				markerKey = '0'

				if markers.has_key(g):
					markerKey = markers[g]
				else:
					mResults = db.sql('select distinct _Current_key ' + \
						'from MRK_Current_View where symbol = "%s"' % (g), 'auto')
	
					if len(mResults) > 0:
						markerKey = mResults[0]['_Current_key']
						markers[g] = markerKey

				if markerKey != '0':
					smKey = `r['_Strain_key']` + ":" + `markerKey`
					if not strainmarker.has_key(smKey):
						exists = db.sql('select _Strain_key from PRB_Strain_Marker ' + \
							'where _Strain_key = %s ' % (r['_Strain_key']) + \
							'and _Marker_key = %s' % (markerKey), 'auto')

						if len(exists) > 0:
							strainmarker[smKey] = smKey
							
					if not strainmarker.has_key(smKey):
						upd.append('insert into PRB_Strain_Marker (_Strain_key, _Marker_key) ' + \
							'values (%s, %s)\n'  % (r['_Strain_key'], markerKey))
						strainmarker[smKey] = smKey
				else:
					updmarkerFile.write('Strain [%s]; Marker [%s]\n' % (r['strain'], g))

		if r['synonyms'] is not None:
			exists = db.sql('select _Strain_key from PRB_Strain_Synonym ' + \
				'where _Strain_key = %s' % (r['_Strain_key']), 'auto')
			if len(exists) == 0:
				upd.append('insert into PRB_Strain_Synonym (_Strain_key, _Synonym_key, synonym) ' + \
					'values (%s, %s, "%s")\n' % (r['_Strain_key'], synonymKey, r['synonyms']))
				synonymKey = synonymKey + 1

		for st in (r['mgikey1'], r['mgikey2'], r['mgikey3']):
			if st is not None and st != -1:
				exists = db.sql('select _Strain_key from MLP_StrainTypes ' + \
					'where _Strain_key = %s ' % (r['_Strain_key']) + \
					'and _StrainType_key = %s' % (st), 'auto')
				if len(exists) == 0:
					upd.append('insert into MLP_StrainTypes (_Strain_key, _StrainType_key) ' + \
						'values (%s, %s)\n' % (r['_Strain_key'], st))

		if len(upd) > 0:
			upd.append('update PRB_Strain set modification_date = getdate() ' + \
				'where _Strain_key = %d' % (r['_Strain_key']))
			db.sql(upd, None, execute = DOIT)
			diagFile.write(str(upd) + '\n\n')
			updateFile.write(str(r) + '\n\n')
			print str(upd)

	updateFile.close()
	updmarkerFile.close()

#
# Main
#

markers = {}
strainmarker = {}

db.set_sqlServer(sys.argv[1])
db.set_sqlDatabase(sys.argv[2])
db.set_sqlUser('mgd_dbo')
db.set_sqlPassword(string.strip(open('/usr/local/mgi/dbutils/mgidbutilities/.mgd_dbo_password', 'r').readline()))
DOIT = string.atoi(sys.argv[3])

diagFile = open('tr2541.txt.out', 'w')

cmds = []

cmds.append('select jrs.*, t.mgikey1, t.mgikey2, t.mgikey3 ' + \
'into #adds ' + \
'from tempdb..JRSStrain jrs, tempdb..jrstype t ' + \
'where jrs.strain is not null ' + \
'and not exists (select 1 from PRB_Strain_Acc_View a ' + \
'where convert(varchar(30), jrs.registry) = a.accID) ' + \
'and not exists (select 1 from PRB_Strain s ' + \
'where jrs.strain = s.strain) ' + \
'and jrs.types = t.jrstype ' + \
'union ' + \
'select jrs.*, null, null, null ' + \
'from tempdb..JRSStrain jrs ' + \
'where jrs.strain is not null ' + \
'and not exists (select 1 from PRB_Strain_Acc_View a ' + \
'where convert(varchar(30), jrs.registry) = a.accID) ' + \
'and not exists (select 1 from PRB_Strain s ' + \
'where jrs.strain = s.strain) ' + \
'and jrs.types is null')

# Delete weird strains, duplicates

cmds.append('delete from #adds where strain like "(Same as %"')
cmds.append('select * into #dups from #adds group by strain having count(*) > 1')
cmds.append('delete #adds from #adds a, #dups d where a.registry = d.registry')

# Match on Registry ID but Strains don't match

cmds.append('select jrs.*, jaxstrain = m.strain ' + \
'into #conflicts ' + \
'from tempdb..JRSStrain jrs, PRB_Strain m, PRB_Strain_Acc_View a ' + \
'where convert(varchar(30), jrs.registry) = a.accID ' + \
'and a._Object_key = m._Strain_key ' + \
'and jrs.strain != m.strain ' + \
'order by jrs.strain')

# Match on Strain

cmds.append('select jrs.*, t.mgikey1, t.mgikey2, t.mgikey3, m._Strain_key ' + \
'into #updates ' + \
'from tempdb..JRSStrain jrs, PRB_Strain m, tempdb..jrstype t ' + \
'where jrs.strain = m.strain ' + \
'and jrs.types = t.jrstype ' + \
'union ' + \
'select jrs.*, null, null, null, m._Strain_key ' + \
'from tempdb..JRSStrain jrs, PRB_Strain m ' + \
'where jrs.strain = m.strain ' + \
'and jrs.types is null')

# Records which require updates and exist in the conflicts table
# This means that we have the wrong Registry ID assigned to the wrong strain
 
cmds.append('select c.registry, c.strain, c.jaxstrain ' + \
'from #conflicts c, #updates u ' + \
'where c.registry = u.registry')

cmds.append('select * from #adds')

cmds.append('select u.* from #updates u ' + \
'where not exists (select 1 from #conflicts c where u.registry = c.registry)')

results = db.sql(cmds, 'auto')

process_adds(results[-2])
process_updates(results[-1])

diagFile.close()

