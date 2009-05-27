#!/usr/local/bin/python

# Purpose:
#	1. create new "not specified" mutant cell lines as needed.
#	2. choose (and link up) derivations for mutant cell lines.
# Assumes:
#	1. We are running as part of the TR7493 migration.  This script is not
#		intended to be used otherwise.
#	2. The ALL_Allele, ALL_CellLine, and ALL_CellLine_Derivation tables
#		have been populated, as much as possible.
#	3. We are dealing with a partially-migrated database.  (expects the
#		ALL_Allele_Old and ALL_CellLine_Old tables to still exist)
# Alterations:
#	1. Adds new "Not Specified" mutant cell lines to ALL_CellLine.
#	2. Updates _Derivation_key in ALL_CellLine for mutant cell lines, to
#		point to their generic derivations.
#	3. Deletes rows from ALL_Allele_CellLine for wild-type alleles and
#		for alleles with "Not Applicable" for both mutant and parent
#		cell lines.
#	4. Updates rows in ALL_Allele_CellLine for alleles with a
#		"Not Specified" mutant cell line, to point to its generic one.
#	5. Adds rows in ALL_Allele_CellLine for alleles which have a new
#		"Not Specified" mutant cell line, which did not have one
#		before.

import sys
import db
import time

USAGE = 'Usage: %s <db user> <password file> <db server> <db name>\n' % \
	sys.argv[0]

STARTTIME = time.time()		# time (in seconds) at start of script run
ESCELLLINE = None		# term key for "Embryonic Stem Cell"
MAXCELLLINE = None		# maximum _CellLine_key in ALL_CellLine so far
MAXASSOCKEY = None		# maximum _Assoc_key in ALL_Allele_CellLine
FP = None			# file pointer; for logging update statments

NA = 'Not Applicable'		# cell line name (where a cell line was not
				# ...biologically involved)
NS = 'Not Specified'		# cell line name (where a cell line was
				# ...involved, but the name was not published)

def bailout (s, showUsage = True):
	# exit with an error message

	if showUsage:
		print USAGE
	print 'Msg (Error): %s' % s
	sys.exit(1)

def update (cmd):
	# issue a data-altering SQL command and log it (insert/delete/update)

	FP.write (cmd)
	FP.write ('\n\n')
	return db.sql(cmd, 'auto')

def select (cmd):
	# issue a read-only SQL command (select)

	return db.sql(cmd, 'auto')

def debug (s):
	# write a time-stamped debugging message to stderr

	sys.stderr.write ('%8.3f : %s\n' % (time.time() - STARTTIME, s))
	return

def initialize():
	# process command-line arguments and intialize global variables

	global ESCELLLINE, MAXCELLLINE, MAXASSOCKEY

	# extract command-line arguments

	if len(sys.argv) != 5:
		bailout ('Invalid command-line')

	[ user, pwdFile, server, dbname ] = sys.argv[1:]

	# read password from file

	try:
		fp = open (pwdFile, 'r')
		password = fp.readline().strip()
		fp.close()
	except:
		bailout ('Cannot read: %s' % pwdFile)

	# set up database connection and try a sample query

	db.set_sqlLogin (user, password, server, dbname)

	try:
		db.useOneConnection(1)
		select ('select count(1) from MGI_dbInfo')
	except:
		bailout ('Cannot read from database')

	# look up the term key for ES cell line

	cmd = '''select vt._Term_key
		from VOC_Vocab vv, VOC_Term vt
		where vv.name = "Cell Line Type"
			and vt.term = "Embryonic Stem Cell"
			and vv._Vocab_key = vt._Vocab_key'''
	results = select (cmd)

	if not results:
		bailout ('Cannot find "Embryonic Stem Cell" term')
	ESCELLLINE = results[0]['_Term_key']

	# look up the maximum cell line key in the database so far

	results = select ('SELECT MAX(_CellLine_key) FROM ALL_CellLine')
	MAXCELLLINE = results[0]['']

	# look up the maximum assoc key in the database so far

	results = select ('SELECT MAX(_Assoc_key) FROM ALL_Allele_CellLine')
	MAXASSOCKEY = results[0]['']

	debug ('finished initialization')
	return

def getDerivations ():
	# get the loaded set of derivations from the database

	cmd = '''SELECT d._Derivation_key,
			d._DerivationType_key,
			c._CellLine_key,
			c.cellLine,
			c._Strain_key,
			s.strain,
			d._Creator_key,
			t.term AS creator,
			t2.term AS derivationType
		FROM ALL_CellLine_Derivation d,
			ALL_CellLine c,
			PRB_Strain s,
			VOC_Term t,
			VOC_Term t2
		WHERE d._ParentCellLine_key = c._CellLine_key
			AND c._Strain_key = s._Strain_key
			AND d._DerivationType_key = t2._Term_key
			AND d._Creator_key = t._Term_key'''

	derivations = {}
	results = select (cmd)
	for row in results:
		creator = row['creator']
		pcl = row['cellLine']
		derivType = row['derivationType']

		key = (creator, pcl, derivType, row['strain'])
		if derivations.has_key(key):
			bailout ("duplicate derivation %s" % str(key))
		derivations[key] = row

	debug ('Got %d derivations' % len(derivations))
	return derivations

def getAlleles ():
	# get the current set of alleles and their parent & mutant cell lines

	cmd = '''SELECT a._Allele_key AS alleleKey,
			mcl._CellLine_key AS mclKey,
			pcl._CellLine_key AS pclKey,
			mcl.cellLine AS mcl,
			pcl.cellLine AS pcl,
			pcl._Strain_key AS pclStrainKey,
			mcl._Strain_key AS mclStrainKey,
			ps.strain AS pclStrain,
			ms.strain AS mclStrain,
			vt.term AS alleleType,
			mcl.provider AS mclProvider,
			pcl.provider AS pclProvider,
			a.isWildType
		FROM ALL_Allele_Old a,
			ALL_CellLine_Old mcl,
			ALL_CellLine_Old pcl,
			PRB_Strain ps,
			PRB_Strain ms,
			VOC_Term vt
		WHERE a._Allele_Type_key = vt._Term_key
			AND a._MutantESCellLine_key *= mcl._CellLine_key
			AND a._ESCellLine_key *= pcl._CellLine_key
			AND mcl._Strain_key *= ms._Strain_key
			AND pcl._Strain_key *= ps._Strain_key'''

	results = select (cmd)
	debug ('Got %d alleles' % len(results))
	return results

def addMCL (alleleKey, name, strainKey, derivationKey):
	# add a new mutant cell line to the database, and hook it up to the
	# given allele

	global MAXCELLLINE, MAXASSOCKEY

	MAXCELLLINE = MAXCELLLINE + 1
	cmd = '''INSERT ALL_CellLine (_CellLine_key, cellLine,
		_CellLine_Type_key, _Strain_key, _Derivation_key, isMutant)
		VALUES (%d, "%s", %d, %d, %d, 1)'''

	update (cmd % (MAXCELLLINE, name, ESCELLLINE, strainKey,
		derivationKey))

	cmd = '''SELECT _Assoc_key
		FROM ALL_Allele_CellLine 
		WHERE _Allele_key = %d''' % alleleKey
	results = select (cmd)

	if len(results[0]) > 0:
		cmd = '''UPDATE ALL_Allele_CellLine
			SET _MutantCellLine_key = %d
			WHERE _Allele_key = %d''' % (MAXCELLLINE, alleleKey)
	else:
		MAXASSOCKEY = MAXASSOCKEY + 1
		cmd = '''INSERT ALL_Allele_CellLine (_Assoc_key, _Allele_key,
			_MutantCellLine_key) VALUES (%d, %d, %d)''' % (
				MAXASSOCKEY, alleleKey, MAXCELLLINE)
	update (cmd)

	return MAXCELLLINE

def deleteAlleleMCL (alleleKey, mclKey):
	# delete the association between the given allele and mutant cell line

	if mclKey != None:
		cmd = '''DELETE FROM ALL_Allele_CellLine
			WHERE _Allele_key = %d
				AND _MutantCellLine_key = %d'''
		update (cmd % (alleleKey, mclKey))
	return

def hookDerivation (mclKey, derivationKey):
	# hook up the given mutant cell line to the given derivation

	cmd = '''UPDATE ALL_CellLine SET _Derivation_key = %d
		WHERE _CellLine_key = %d'''
	update (cmd % (derivationKey, mclKey))
	return

def reconcile (alleles, derivations):
	# reconcile the given sets of alleles (with mutant and parent cell
	# lines) and derivations, updating the database as needed

	matches = 0	# count of matches from allele/MCL to derivations
	case1 = 0
	case2 = 0
	case3 = 0
	case4 = 0
	case5 = 0
	case6 = 0
	case7 = 0
	case8 = 0
	case9 = 0
	case10 = 0
	case11 = 0
	case12 = 0
	case13 = 0
	notImplemented = 0
	missingDerivations = {}

	for row in alleles:
		alleleKey = row['alleleKey']
		provider = row['mclProvider']
		pcl = row['pcl']
		pclKey = row['pclKey']
		mcl = row['mcl']
		alleleType = row['alleleType']
		strain = row['pclStrain']
		strainKey = row['pclStrainKey']

		needNewMCL = False	# need to create a new MCL?
		key = None	# 3-item tuple to use to find derivation

		# case 3 : allele is wild type
		#	a. no allele/MCL relationship
		if row['isWildType'] == 1:
			case3 = case3 + 1
			deleteAlleleMCL (alleleKey, row['mclKey'])

		# mutant cell line is "Not Applicable"
		elif mcl == NA:
			# case 1 : both cell lines N/A
			#	a. no allele/MCL relationship
			if pcl == NA:
				case1 = case1 + 1
				deleteAlleleMCL (alleleKey, row['mclKey'])

			# case 2 : mutant N/A, parent N/S
			#	a. create new N/S mutant cell line
			#	b. hook up to right N/S derivation
			elif pcl == NS:
				case2 = case2 + 1
				key = (NS, pcl, alleleType, strain)
				needNewMCL = True

			# case 4 : mutant N/A, parent specified (and is not
			#		"Other: see notes")
			#	a. create new N/S mutant cell line
			#	b. hook up to right specified derivation
			elif pcl != 'Other (see notes)':
				case4 = case4 + 1
				key = (NS, pcl, alleleType, strain)
				needNewMCL = True

			# case 6 : mutant N/A, parent is "Other: see notes"
			#	a. if parent cell line is 1100 (strain NA),
			#		use 1069 (strain NS)
			#	b. hook up to right derivation
			else:
				case6 = case6 + 1
				if pclKey == 1100:
					pclKey = 1069
				key = (NS, pcl, alleleType, strain)

		# mutant cell line is "Not Specified"
		elif mcl == NS:
			# case 9 : mutant N/S, parent N/A
			#	a. create new N/S mutant cell line
			#	b. hook up right N/S derivation
			if pcl == NA:
				key = (NS, NS, alleleType, strain)
				needNewMCL = True
				case9 = case9 + 1

			# case 10 : mutant N/S, parent N/S
			#	a. create new N/S mutant cell line
			#	b. hook up right N/S derivation
			elif pcl == NS:
				key = (NS, pcl, alleleType, strain)
				needNewMCL = True
				case10 = case10 + 1

			# case 11 : mutant N/S, parent is "Other: see notes"
			#	a. if parent cell line is 1100 (NA),
			#		use 1069 (NS)
			#	b. hook up to right derivation
			elif pcl == 'Other (see notes)':
				case11 = case11 + 1
				if pclKey == 1100:
					pclKey = 1069
					pcl = "Not Specified"
				key = (NS, pcl, alleleType, strain)

			# case 8 : mutant N/S, parent specified and is not
			#		"Other (see notes)"
			#	a. create new N/S mutant cell line
			#	b. hook up right N/S derivation
			else:
				case8 = case8 + 1
				key = (NS, pcl, alleleType, strain)
				needNewMCL = True


		# mutant cell line is specified
		elif mcl != 'Other (see notes)':
			# case 12 : mutant specified, parent N/A
			#	a. hook up to right N/S derivation (not N/A)
			if pcl == NA:
				case12 = case12 + 1
				if provider:
				    key = (provider, NS, alleleType, strain)
				else:
				    key = (NS, NS, alleleType, strain)

			# case 5 : mutant specified, parent N/S
			#	a. hook up to right derivation
			elif pcl == NS:
				case5 = case5 + 1
				if provider:
				    key = (provider, pcl, alleleType, strain)
				else:
				    key = (NS, pcl, alleleType, strain)

			# case 13 : mutant specified, parent "Other: see..."
			#	a. if parent cell line is 1100 (NA),
			#		use 1069 (NS)
			#	b. hook up to right derivation
			elif pcl == 'Other (see notes)':
				case13 = case13 + 1
				if pclKey == 1100:
					pclKey = 1069
					pcl = "Not Specified"
				if provider:
				    key = (provider, pcl, alleleType, strain)
				else:
				    key = (NS, pcl, alleleType, strain)


			# case 7 : mutant specified, parent specified
			#	a. hook up to right derivation
			else:
				case7 = case7 + 1
				if provider:
				    key = (provider, pcl, alleleType, strain)
				else:
				    key = (NS, pcl, alleleType, strain)

		# mutant cell line is "Other: see notes"...  should not occur
		else:
			notImplemented = notImplemented + 1

		# if we have a key to look up (to pick the right derivation),
		# then use it

		if key != None:
			if derivations.has_key (key):
				matches = matches + 1
				derivKey = derivations[key]['_Derivation_key']

				# add a new MCL, if needed
				if needNewMCL:
					mclKey = addMCL (row['alleleKey'],
						key[0], strainKey, derivKey)

				# otherwise, hook up existing MCL
				else:
					hookDerivation (row['mclKey'],
						derivKey)
			else:
				if missingDerivations.has_key(key):
					missingDerivations[key] = 1 + \
						missingDerivations[key]
				else:
					missingDerivations[key] = 1

				# any ones where we can't find the right
				# derivation, just hook them to a bogus one
				# and the ALO load will figure it out

				key = (NS, NS, NS, NS)
				derivKey = derivations[key]['_Derivation_key']

				if needNewMCL:
					mclKey = addMCL (row['alleleKey'],
						key[0], strainKey, derivKey)
				else:
					hookDerivation (row['mclKey'],
						derivKey)

	md = missingDerivations.items()
	# sort by descending count of occurrences
	md.sort(lambda a, b : cmp(b[1], a[1]))

	debug ('Found %d matching derivations' % matches)
	debug ('  %d alleles with N/A MCL, N/S PCL' % case2)
	debug ('  %d alleles with N/A MCL, "Other: see notes" PCL' % case6)
	debug ('  %d alleles with N/A MCL, specified PCL' % case4)
	debug ('  %d alleles with N/S MCL, N/A PCL' % case9)
	debug ('  %d alleles with N/S MCL, N/S PCL' % case10)
	debug ('  %d alleles with N/S MCL, "Other: see notes" PCL' % case11)
	debug ('  %d alleles with N/S MCL, specified PCL' % case8)
	debug ('  %d alleles with specified MCL, N/A PCL' % case12)
	debug ('  %d alleles with specified MCL, N/S PCL' % case5)
	debug ('  %d alleles with specified MCL, "Other: see notes" PCL' % \
		case13)
	debug ('  %d alleles with specified MCL, specified PCL' % case7)
	debug ('Removed %d MCL assoc for alleles' % (case1 + case3))
	debug ('  %d alleles with N/A MCL, PCL' % case1)
	debug ('  %d wild-type alleles with no MCL' % case3)
	debug ('Left %d alleles with non-implemented MCL/deriv' % \
		notImplemented)
	debug ('Missing %d necessary derivations:' % len(missingDerivations))

	for (key, count) in md:
		debug ('  %d : %s' % (count, key))
	return

def main():
	global FP
	FP = open ('mclDerivations.log', 'w')

	initialize()
	derivations = getDerivations()
	alleles = getAlleles()
	reconcile (alleles, derivations)

	FP.close()
	return

if __name__ == '__main__':
	main()
