#!/usr/local/bin/python

'''
#
# Purpose:
#
# To migrate Probe Strain and Tissue data to MGI 1.0 schema
#
'''

import sys
import string
import regsub
import mgdlib

NL = '\n'
DL = '|'
NS = -1

class Strain:
 
        def __init__(self, tuple):
 
                self.id = tuple['_Strain_key']
                self.name = tuple['strain']
		self.standard = tuple['standard']
 
class Tissue:
 
        def __init__(self, tuple):
 
                self.id = tuple['_Tissue_key']
                self.name = tuple['tissue']
 
def loadStrain():
	''' Initialize global Strain dictionary '''

	global strainDict
 
        cmd = 'select _Strain_key, strain, standard from PRB_Strain'
        results = mgdlib.sql(cmd, 'auto')

	for r in results:
		strain = Strain(r)
		strainDict[strain.name] = strain
 
def loadTissue():
	''' Initialize global Tissue dictionary '''

	global tissueDict
 
        cmd = 'select _Tissue_key, tissue from PRB_Tissue'
        results = mgdlib.sql(cmd, 'auto')
 
	for r in results:
		tissue = Tissue(r)
		tissueDict[tissue.name] = tissue
 
def parseSource(tuple):
	''' Process each source record and write to bcp file '''

	global sourceBCP

	if tuple.has_key('_Strain_key'):
		strain = tuple['_Strain_key']
	else:
		if tuple['strain'] in unsList:
			strain = NS
		else:
			try:
				strain = strainDict[tuple['strain']].id
			except:
				if tuple['strain'] != None:
					print tuple['strain']

				strain = NS

	if tuple.has_key('_Tissue_key'):
		tissue = tuple['_Tissue_key']
	else:
		if tuple['tissue'] in unsList:
			tissue = NS
		else:
			try:
				tissue = tissueDict[tuple['tissue']].id
			except:
				if tuple['tissue'] != None:
					print tuple['tissue']

				tissue = NS

	if tuple['sex'] in ['Not Spec', 'Unknown', 'unknown', None]:
		sex = 'Not Specified'
	elif tuple['sex'] == 'female':
		sex = 'Female'
	elif tuple['sex'] == 'male':
		sex = 'Male'
	elif tuple['sex'] == 'pooled':
		sex = 'Pooled'
	else:
		sex = tuple['sex']

	if tuple['age'] == 'unspecified':

		age = 'Not Specified'
	else:
		age = regsub.gsub(' - ', '-', tuple['age'])
		age = regsub.gsub('  ', ' ', age)

	if not tuple.has_key('_Tissue_key') and tuple['tissue'] == 'unfertilized egg':
		age = 'Not Applicable'

	#
	# Convert age to 'ageMin' and 'ageMax' values
	# See Requirements document for full details
	# http://kelso:4444/software/mgi1.0/age.html
	#

	ageMin = None
	ageMax = None
	ageOK = 1

	if age in ['Not Specified', 'mixed', 'Not Applicable']:
		ageMin = None
		ageMax = None
	elif age == 'embryonic':
		ageMin = 0.0
		ageMax = 21.0
	elif age == 'postnatal':
		ageMin = 21.01
		ageMax = 1846.0
	elif age == 'postnatal newborn':
		ageMin = 21.01
		ageMax = 25.0
	elif age == 'postnatal immature':
		ageMin = 25.01
		ageMax = 42.0
	elif age == 'postnatal adult':
		ageMin = 42.01
		ageMax = 1846.0
	else:
		age = regsub.gsub('days', 'day', age)	# days ==> day
		age = regsub.gsub('or ', ',', age)	# 2 or 3 ==> 2,3
		age = regsub.gsub('and ', ',', age)	# 2 and 3 ==> 2,3
		age = regsub.gsub('to ', '-', age)	# 2 to 3 ==> 2-3
		age = regsub.gsub('+', '', age)		# 2+ ==> 2

		# only split into 3 elements
		try:
			ages = string.split(age, ' ', 2)
			stem = ages[0]
			timeUnit = ages[1]
			timeRange = ages[2]

			#
			# format is 'embryonic day x,y,z...' ==> (min(x,y,z), max(x,y,z))
			# format is 'embryonic day x-y,z...' ==> (min(x,y,z), max(x,y,z))
			#
			if string.find(timeRange, ',') >= 0:
				times = string.split(timeRange, ',')

				for i in range(len(times)):
					if string.find(times[i], '-') >= 0:
						[x, y] = string.split(times[i], '-')
						times[i] = x

				ageMin = string.atof(times[0])
				ageMax = string.atof(times[0])

				for t in times:
					tFloat = string.atof(t)
					if tFloat < ageMin:
						ageMin = tFloat
					if tFloat > ageMax:
						ageMax = tFloat

			#
			# format is 'embryonic day x-y' ==> (x,y)
			#
			elif string.find(timeRange, '-') >= 0:
				[ageMin, ageMax] = string.split(timeRange, '-')
				ageMin = string.atof(ageMin)
				ageMax = string.atof(ageMax)

			#
			# format is 'embryonic day x' ==> (x,x)
			#
			else:
				ageMin = string.atof(timeRange)
				ageMax = string.atof(timeRange)

			try:
				if stem == 'postnatal':
					if timeUnit == 'day':
						ageMin = ageMin + 21.01
						ageMax = ageMax + 21.01
					elif timeUnit == 'week':
						ageMin = ageMin * 7 + 21.01
						ageMax = ageMax * 7 + 21.01
					elif timeUnit == 'month':
						ageMin = ageMin * 30 + 21.01
						ageMax = ageMax * 30 + 21.01
					elif timeUnit == 'year':
						ageMin = ageMin * 365 + 21.01
						ageMax = ageMax * 365 + 21.01
	
			except:
				ageOK = 0
				print mgdlib.prvalue(tuple['age']) + \
			      		'\tcould not convert\n'

		except:
			ageOK = 0
			print mgdlib.prvalue(tuple['age']) + \
			      '\tcould not convert\n'

		if ageMin is None or ageMax is None:
			ageOK = 0
			print mgdlib.prvalue(tuple['age']) + \
			      '\tcould not convert\n'

	if ageOK:
		sourceBCP.write(mgdlib.prvalue(tuple['_Source_key']) + DL + \
				mgdlib.prvalue(tuple['name']) + DL + \
				mgdlib.prvalue(tuple['description']) + DL + \
				mgdlib.prvalue(tuple['_Refs_key']) + DL + \
				mgdlib.prvalue(tuple['species']) + DL + \
				`strain` + DL + \
				`tissue` + DL + \
				mgdlib.prvalue(age) + DL + \
				mgdlib.prvalue(ageMin) + DL + \
				mgdlib.prvalue(ageMax) + DL + \
				mgdlib.prvalue(sex) + DL + \
				mgdlib.prvalue(tuple['cellLine']) + DL + \
				mgdlib.prvalue(tuple['cd']) + DL + \
				mgdlib.prvalue(tuple['md']) + NL)

def parseFISH(tuple):
	global fishBCP

	try:
		strain = strainDict[tuple['strain']].id
	except:
		if tuple['strain'] != None:
			print tuple['strain']

		strain = NS

	fishBCP.write(mgdlib.prvalue(tuple['_Expt_key']) + DL + \
	              mgdlib.prvalue(tuple['band']) + DL + \
		      `strain` + DL + \
	              mgdlib.prvalue(tuple['cellOrigin']) + DL + \
	              mgdlib.prvalue(tuple['karyotype']) + DL + \
	              mgdlib.prvalue(tuple['robertsonians']) + DL + \
	              mgdlib.prvalue(tuple['label']) + DL + \
	              mgdlib.prvalue(tuple['numMetaphase']) + DL + \
	              mgdlib.prvalue(tuple['totalSingle']) + DL + \
	              mgdlib.prvalue(tuple['totalDouble']) + DL + \
		      DL + NL)

def parseInSitu(tuple):
	global insituBCP

	try:
		strain = strainDict[tuple['strain']].id
	except:
		if tuple['strain'] != None:
			print tuple['strain']

		strain = NS

	insituBCP.write(mgdlib.prvalue(tuple['_Expt_key']) + DL + \
	                mgdlib.prvalue(tuple['band']) + DL + \
		        `strain` + DL + \
	                mgdlib.prvalue(tuple['cellOrigin']) + DL + \
	                mgdlib.prvalue(tuple['karyotype']) + DL + \
	                mgdlib.prvalue(tuple['robertsonians']) + DL + \
	                mgdlib.prvalue(tuple['numMetaphase']) + DL + \
	                mgdlib.prvalue(tuple['totalGrains']) + DL + \
	                mgdlib.prvalue(tuple['grainsOnChrom']) + DL + \
	                mgdlib.prvalue(tuple['grainsOtherChrom']) + DL + \
		        DL + NL)

def parseCross(tuple):
	global crossBCP

	try:
		femaleStrain = strainDict[tuple['femaleStrain']].id
	except:
		if tuple['femaleStrain'] != None:
			print tuple['femaleStrain']

		femaleStrain = NS

	try:
		maleStrain = strainDict[tuple['maleStrain']].id
	except:
		if tuple['maleStrain'] != None:
			print tuple['maleStrain']

		maleStrain = NS

	try:
		strainHO = strainDict[tuple['strainHO']].id
	except:
		if tuple['strainHO'] != None:
			print tuple['strainHO']

		strainHO = NS

	try:
		strainHT = strainDict[tuple['strainHT']].id
	except:
		if tuple['strainHT'] != None:
			print tuple['strainHT']

		strainHT = NS

	crossBCP.write(mgdlib.prvalue(tuple['_Cross_key']) + DL + \
	               mgdlib.prvalue(tuple['type']) + DL + \
		       `femaleStrain` + DL + \
	               mgdlib.prvalue(tuple['femaleAllele1']) + DL + \
	               mgdlib.prvalue(tuple['femaleAllele2']) + DL + \
		       `maleStrain` + DL + \
	               mgdlib.prvalue(tuple['maleAllele1']) + DL + \
	               mgdlib.prvalue(tuple['maleAllele2']) + DL + \
	               mgdlib.prvalue(tuple['abbrevHO']) + DL + \
		       `strainHO` + DL + \
	               mgdlib.prvalue(tuple['abbrevHT']) + DL + \
		       `strainHT` + DL + \
	               mgdlib.prvalue(tuple['whoseCross']) + DL + \
	               mgdlib.prvalue(tuple['alleleFromSegParent']) + DL + \
	               mgdlib.prvalue(tuple['F1DirectionKnown']) + DL + \
	               mgdlib.prvalue(tuple['nProgeny']) + DL + \
	               mgdlib.prvalue(tuple['displayed']) + DL + \
		       DL + NL)

def parseAllele(tuple):
	global alleleBCP

	try:
		strain = strainDict[tuple['strain']].id
	except:
		if tuple['strain'] != None:
			print tuple['strain']

		strain = NS

	alleleBCP.write(mgdlib.prvalue(tuple['_Allele_key']) + DL + \
		        `strain` + DL + \
		        DL + NL)

def createOther():
	global sourceBCP, fishBCP, insituBCP, crossBCP, alleleBCP

	sourceBCP = open("data/PRB_Source.bcp", 'w')
	fishBCP = open("data/MLD_FISH.bcp", 'w')
	insituBCP = open("data/MLD_InSitu.bcp", 'w')
	crossBCP = open("data/CRS_Cross.bcp", 'w')
	alleleBCP = open("data/PRB_Allele_Strain.bcp", 'w')

	loadStrain()
	loadTissue()

	cmd = 'select _Source_key = -2, name = "Not Applicable", description = NULL, ' + \
	      '_Refs_key = NULL, species = "Not Applicable", _Strain_key = -2, ' + \
	      '_Tissue_key = -2, age = "Not Applicable", sex = "Not Applicable", ' + \
	      'cellLine = NULL, cd = NULL, md = NULL'
	print cmd
	mgdlib.sql(cmd, parseSource)

	cmd = 'select _Source_key = -1, name = "Not Specified", description = NULL, ' + \
	      '_Refs_key = NULL, species = "Not Specified", _Strain_key = -1, ' + \
	      '_Tissue_key = -1, age = "Not Specified", sex = "Not Specified", ' + \
	      'cellLine = NULL, cd = NULL, md = NULL'
	print cmd
	mgdlib.sql(cmd, parseSource)

	cmd = 'select _Source_key, name, description, _Refs_key, species, strain, ' + \
	      'tissue, age, sex, cellLine, ' + \
	      'cd = convert(varchar(20), creation_date), ' + \
	      'md = convert(varchar(20), modification_date) from mgd..PRB_Source'
	print cmd
	mgdlib.sql(cmd, parseSource)

	cmd = 'select * from mgd..MLD_FISH'
	print cmd
	mgdlib.sql(cmd, parseFISH)

	cmd = 'select * from mgd..MLD_InSitu'
	print cmd
	mgdlib.sql(cmd, parseInSitu)

	cmd = 'select * from mgd..CRS_Cross'
	print cmd
	mgdlib.sql(cmd, parseCross)

	cmd = 'select a._Allele_key, s.strain from mgd..PRB_Allele_Strain a, mgd..PRB_Strain s ' + \
	      'where a._Strain_key = s._Strain_key'
	print cmd
	mgdlib.sql(cmd, parseAllele)

	sys.stdout.flush()
	sourceBCP.close()
	fishBCP.close()
	insituBCP.close()
	crossBCP.close()
	alleleBCP.close()

def parseStrain(tuple):
	global maxStrain

	if not tuple.has_key('_Strain_key'):
		tuple['_Strain_key'] = maxStrain
		maxStrain = maxStrain + 1

	if tuple['strain'] in unsList:
		return

	if not strainDict.has_key(tuple['strain']):
		strain = Strain(tuple)
		strainDict[strain.name] = strain

def updateStandard():

	inFile = open('master.mgi.in', 'r')
	line = string.strip(inFile.readline())
	line = string.strip(inFile.readline())
 
	while (line != ''):
		tokens = string.split(line, '\t')

		inputStrain = tokens[0]

		try:
			if tokens[5] == 'Standard':
				standard = 1
			else:
				standard = 0

			if strainDict.has_key(inputStrain):
				strain = strainDict[inputStrain]
				strain.standard = standard
		except:
			pass

		line = string.strip(inFile.readline())
 
	inFile.close()
 
def createStrains():

	strainBCP = open("data/PRB_Strain.bcp", 'w')

	tuple = {}
	tuple['_Strain_key'] = -2
	tuple['strain'] = 'Not Applicable'
	tuple['standard'] = '1'
	strain = Strain(tuple)
	strainDict[strain.name] = strain

	tuple = {}
	tuple['_Strain_key'] = -1
	tuple['strain'] = 'Not Specified'
	tuple['standard'] = '1'
	strain = Strain(tuple)
	strainDict[strain.name] = strain

        cmd = 'select strain, standard = 0 from mgd..PRB_Strain where strain is not null'
	print cmd
        mgdlib.sql(cmd, parseStrain)

	cmd = 'select strain, standard = 0 from mgd..PRB_Source where strain is not null'
	print cmd
	mgdlib.sql(cmd, parseStrain)

	cmd = 'select strain, standard = 0 from mgd..MLD_FISH where strain is not null'
	print cmd
	mgdlib.sql(cmd, parseStrain)

	cmd = 'select strain, standard = 0 from mgd..MLD_InSitu where strain is not null'
	print cmd
	mgdlib.sql(cmd, parseStrain)

	cmd = 'select strain = femaleStrain, standard = 0 from mgd..CRS_Cross ' + \
	      'where femaleStrain is not null'
	print cmd
	mgdlib.sql(cmd, parseStrain)

	cmd = 'select strain = maleStrain, standard = 0 from mgd..CRS_Cross ' + \
	      'where maleStrain is not null'
	print cmd
	mgdlib.sql(cmd, parseStrain)

	cmd = 'select strain = strainHO, standard = 0 from mgd..CRS_Cross ' + \
	      'where strainHO is not null'
	print cmd
	mgdlib.sql(cmd, parseStrain)

	cmd = 'select strain = strainHT, standard = 0 from mgd..CRS_Cross ' + \
	      'where strainHT is not null'
	print cmd
	mgdlib.sql(cmd, parseStrain)

	updateStandard()

	for i in strainDict.keys():
		s = strainDict[i]
		strainBCP.write(mgdlib.prvalue(s.id) + DL + \
				mgdlib.prvalue(s.name) + DL + \
				mgdlib.prvalue(s.standard) + DL + DL + NL)

	strainBCP.close()

def parseTissue(tuple):
	global maxTissue

	if not tuple.has_key('_Tissue_key'):
		tuple['_Tissue_key'] = maxTissue
		maxTissue = maxTissue + 1

	if tuple['tissue'] in unsList:
		return

	if not tissueDict.has_key(tuple['tissue']):
		tissue = Tissue(tuple)
		tissueDict[tissue.name] = tissue

def createTissues():

	tissueBCP = open("data/PRB_Tissue.bcp", 'w')

	tuple = {}
	tuple['_Tissue_key'] = -2
	tuple['tissue'] = 'Not Applicable'
	tissue = Tissue(tuple)
	tissueDict[tissue.name] = tissue

	tuple = {}
	tuple['_Tissue_key'] = -1
	tuple['tissue'] = 'Not Specified'
	tissue = Tissue(tuple)
	tissueDict[tissue.name] = tissue

	cmd = 'select tissue from mgd..PRB_Source where tissue is not null'
	print cmd
	mgdlib.sql(cmd, parseTissue)

	for i in tissueDict.keys():
		s = tissueDict[i]
		tissueBCP.write(mgdlib.prvalue(s.id) + DL + \
				mgdlib.prvalue(s.name) + DL + \
				'1' + DL + DL + NL)

	tissueBCP.close()

#
# Main Routine
#

loadTag = sys.argv[1]
maxStrain = 1
maxTissue = 1

strainDict = {}
tissueDict = {}

# List of potential unspecified values including misspellings, etc.
# Used to eliminate all versions of unspecified values and map all
# to standard Not Specified terminology

unsList = ['not-given',
	   'unspeified',
	   'unspeicified',
           'unpsecified',
	   'unspecified', 
	   'Unspecified',
	   'Not Spec', 
	   'unknown', 
	   'Unknown', 
	   ' ', 
	   None,]

if loadTag == 'Strains':
	createStrains()
	createTissues()
elif loadTag == 'Other':
	createOther()

