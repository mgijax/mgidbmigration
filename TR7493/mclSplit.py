#!/usr/local/bin/python

# Purpose:
#	1. split mutant cell lines which have multiple IDs into single cell
#		lines, each with a single ID
#	2. keep the same allele associations for those split cell lines
# Assumes:
#	1. exclusive write-access to the database
# Alterations:
#	1. Adds new mutant cell lines to ALL_CellLine.
#	2. Changes _Object_key for some records in ACC_Accession.
#	3. Adds new allele/MCL associations to ALL_Allele_CellLine.

import sys
import db
import time

USAGE = 'Usage: %s <db user> <password file> <db server> <db name>\n' % \
	sys.argv[0]

STARTTIME = time.time()		# time (in seconds) at start of script run
MAXCELLLINE = None		# maximum _CellLine_key in ALL_CellLine so far
MAXASSOCKEY = None		# maximum _Assoc_key in ALL_Allele_CellLine
FP = None			# file pointer; for logging update statments

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

	global MAXCELLLINE, MAXASSOCKEY

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

	# look up the maximum cell line key in the database so far

	results = select ('SELECT MAX(_CellLine_key) FROM ALL_CellLine')
	MAXCELLLINE = results[0]['']

	# look up the maximum assoc key in the database so far

	results = select ('SELECT MAX(_Assoc_key) FROM ALL_Allele_CellLine')
	MAXASSOCKEY = results[0]['']

	debug ('finished initialization')
	return

def getCellLines():
	# get a list of mutant cell lines which have multiple IDs

	cmd = '''SELECT c._CellLine_key, a._Accession_key, a.accID, c.cellLine
		INTO #tmp_cellLines
		FROM ACC_Accession a,
			ALL_CellLine c
		WHERE a._MGIType_key = 28
			AND a.private = 0
			AND a._Object_key = c._CellLine_key
			AND c.isMutant = 1
			AND EXISTS (SELECT 1 FROM ACC_Accession b
				WHERE a._Object_key = b._Object_key
				    AND b.private = 0
				    AND b._MGIType_key = 28
				    AND a.accID != b.accID)'''
	select(cmd)
	select('CREATE INDEX #cellLineKey ON #tmp_cellLines (_CellLine_key)')
	debug ('built temp table of multi-ID MCL')

	cmd = '''SELECT t._CellLine_key, t._Accession_key, t.accID,
			c._Assoc_key, c._Allele_key, t.cellLine
		FROM #tmp_cellLines t, ALL_Allele_CellLine c
		WHERE t._CellLine_key = c._MutantCellLine_key'''
	results = select(cmd)

	dict = {}
	for row in results:
		c = row['_CellLine_key']
		id = (row['accID'], row['_Accession_key'])
		allele = (row['_Allele_key'], row['_Assoc_key'])

		if not dict.has_key(c):
			dict[c] = {
				'ids' : [ id ],
				'alleles' : [ allele ],
				'cellLine' : row['cellLine'],
				}
		else:
			dict[c]['ids'].append (id)
			dict[c]['alleles'].append (allele)

	debug ('got info for %d multi-ID MCL' % len(dict))
	return dict

def updateDatabase (cellLines):
	# make all necessary database updates for the given 'cellLines'
	global MAXCELLLINE, MAXASSOCKEY

	newMCL = '''INSERT ALL_CellLine (_CellLine_key, cellLine,
			_CellLine_Type_key, _Strain_key, _Derivation_key,
			isMutant, _CreatedBy_key, _ModifiedBy_key,
			creation_date, modification_date)
		SELECT %d, "%s", _CellLine_Type_key, _Strain_key,
			_Derivation_key, isMutant, _CreatedBy_key,
			_ModifiedBy_key, creation_date, modification_date
		FROM ALL_CellLine
		WHERE _CellLine_key = %d'''

	newAssoc = '''INSERT ALL_Allele_CellLine (_Assoc_key, _Allele_key,
			_MutantCellLine_key, _CreatedBy_key, _ModifiedBy_key,
			creation_date, modification_date)
		SELECT %d, %d, %d, _CreatedBy_key, _ModifiedBy_key,
			creation_date, modification_date
		FROM ALL_Allele_CellLine
		WHERE _Assoc_key = %d'''

	updateAcc = '''UPDATE ACC_Accession
		SET _Object_key = %d
		WHERE _Accession_key = %d'''

	getMods = '''SELECT _ModifiedBy_key,
			mod_date = convert(char(10), modification_date, 101)
		FROM ALL_CellLine
		WHERE _CellLine_key = %d'''

	updateName = '''UPDATE ALL_CellLine
		SET cellLine = "%s",
			_ModifiedBy_key = %d,
			modification_date = "%s"
		WHERE _CellLine_key = %d'''

	mclCt = 0
	accCt = 0
	assocCt = 0
	nameCt = 0
	asisCt = 0

	for (cellLineKey, cellLine) in cellLines.items():
		ids = cellLine['ids']
		alleles = cellLine['alleles']
		name = cellLine['cellLine']

		# for each extra ID...
		for (id, accKey) in ids[1:]:
			# create a new MCL for each extra ID
			MAXCELLLINE = MAXCELLLINE + 1
			update (newMCL % (MAXCELLLINE, id, cellLineKey))
			mclCt = mclCt + 1

			# update the accID to point to the new object
			update (updateAcc % (MAXCELLLINE, accKey))
			accCt = accCt + 1

			# link each to the existing set of alleles
			for (alleleKey, assocKey) in alleles:
				MAXASSOCKEY = MAXASSOCKEY + 1
				update (newAssoc % (MAXASSOCKEY, alleleKey,
					cellLineKey, assocKey))
				assocCt = assocCt + 1

		# update name of cell line #1
		if (name != ids[0][0]):
			results = select(getMods % cellLineKey)
			modKey = results[0]['_ModifiedBy_key']
			modDate = results[0]['mod_date']

			update(updateName % (ids[0][0], modKey, modDate,
				cellLineKey))
			nameCt = nameCt + 1
		else:
			asisCt = asisCt + 1

	debug ('Finished database updates:')
	debug ('  created %d new MCL' % mclCt)
	debug ('  updated %d ID associations' % accCt)
	debug ('  added %d allele associations' % assocCt)
	debug ('  updated %d existing MCL names' % nameCt)
	debug ('  left %d existing MCL names as-is' % asisCt)
	return

def main():
	global FP
	FP = open ('mclSplit.log', 'w')

	initialize()
	updateDatabase(getCellLines())

	FP.close()
	return

if __name__ == '__main__':
	main()
