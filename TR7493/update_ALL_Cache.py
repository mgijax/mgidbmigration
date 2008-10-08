#!/usr/local/bin/python

# Purpose: to update some or all rows in the ALL_Cache table in mgd
#	see USAGE below for more information
# History:
#	01/20/2008 - jsb - added for Gene Trap LF release (TR7493)

import sys
import getopt
import tempfile
import runCommand
import db
import Profiler

USAGE = '''Usage: %s [-a <key>][-g <key>][-m <key>] <db server> <db name> <db user> <db password file>
	-a : update/add cache table entry for the specified _Allele_key
	-g : update/add cache table entries for all alleles of the 
		specified _Genotype_key
	-m : update/add cache table entries for all alleles of the specified
		_Marker_key
    Notes:
    	1. All changes are isolated to the ALL_Cache table.
	2. At most one of -a, -g, or -m may be specified.
	3. If none of -a, -g, or -m are specified, we do a delete & regenerate
	   on the whole ALL_Cache table.
	4. The final four command-line parameters are to specify database
	   access information.  Normally, these are passed in by the wrapper
	   script, update_ALL_Cache.csh, using values from mgiconfig.  If
	   you call this script directly without using the wrapper, you need
	   to specify them.
''' % sys.argv[0]

#-----------------------------------------------------------------------------

###---------------###
###--- globals ---###
###---------------###

ALLELE_TABLE = None		# name of temp table with selected alleles
PRO = Profiler.Profiler()	# for runtime profiling
BCP_THRESHOLD = 200		# max number of rows to add by inline SQL
BCP = '/opt/sybase/12.5/OCS-12_5/bin/bcp'	# path to bcp executable

#-----------------------------------------------------------------------------

###-----------------###
###--- functions ---###
###-----------------###

def message (
	s	# string; message to timestamp and add to profile
	):
	# Purpose: add message 's' to the profile with a timestamp
	# Returns: nothing
	# Assumes: nothing
	# Effects: updates contents of object 'PRO'
	# Throws: nothing

	PRO.stamp(s)
	return

#-----------------------------------------------------------------------------

def bailout (
	s,			# string; error message for the user
	showUsage = True	# boolean; show usage message above error?
	):
	# Purpose: give an error message and exit this script
	# Returns: to the shell
	# Assumes: we can write to stderr
	# Effects: writes to stderr, exits to shell
	# Throws: SystemExit to exit this script

	if showUsage:
		sys.stderr.write (USAGE)
	sys.stderr.write ('Error: %s\n' % s)
	sys.exit(1)

#-----------------------------------------------------------------------------

def processCommandLine ():
	# Purpose: parse the user's command-line and do basic handling of the
	#	parameters found
	# Returns: nothing
	# Assumes: nothing
	# Effects: 1. reads password file from file system; 2. does database
	#	login and test query; 3. builds #tmp_alleles temp table in
	#	the database
	# Throws: SystemExit if any problems are detected, using bailout() to
	#	give the user an appropriate message to stderr

	global ALLELE_TABLE

	# basic command-line processing; look for at most one of three flags
	# and exactly four extra arguments (for database access)

	try:
		opts, args = getopt.getopt (sys.argv[1:], 'a:g:m:')
	except:
		bailout ('Invalid command-line parameters')

	if len(args) < 4:
		bailout ('Incomplete database-access parameters')
	elif len(args) > 4:
		bailout ('Too many command-line parameters')

	if len(opts) > 1:
		bailout ('Too many options.  Only use one of -a, -g, or -m.')

	# get the password from the specified password file

	try:
		fp = open (args[3], 'r')
		password = fp.readline().strip()
		fp.close()
	except:
		bailout ('Cannot read password file: %s' % args[3])

	# do the database login and try a test query

	try:
		db.set_sqlLogin (args[2], password, args[0], args[1])
		db.useOneConnection(1)
		db.sql ('SELECT COUNT(1) FROM MGI_dbInfo', 'auto')
	except:
		bailout ('Database login failed')

	cmd = None	# SQL statement for building temp table #tmp_alleles
	keyType = None	# string; identifies the type of key given by user

	for (option, value) in opts:

		# user specified an allele key?
		if option == '-a':
			cmd = '''SELECT _Allele_key
				INTO #tmp_alleles
				FROM ALL_Allele
				WHERE _Allele_key = %s''' % value
			keyType = 'allele'

		# user specified a marker key?
		elif option == '-m':
			cmd = '''SELECT _Allele_key
				INTO #tmp_alleles
				FROM ALL_Allele
				WHERE _Marker_key = %s''' % value
			keyType = 'marker'
		
		# user specified a genotype key?
		elif option == '-g':
			cmd = '''SELECT _Allele_key
				INTO #tmp_alleles
				FROM GXD_AlleleGenotype
				WHERE _Genotype_key = %s''' % value
			keyType = 'genotype'
		else:
			bailout ('Unkown command-line option: %s' % option)

	# If we defined a command for temp table generation, then the user
	# only wants to regenerate a subset of ALL_Cache, not the full table.
	# In this case, use 'cmd' to load those alleles into #tmp_alleles.

	if cmd:
		try:
			db.sql (cmd, 'auto')
			ALLELE_TABLE = '#tmp_alleles'
		except:
			bailout ('Query failed with an error: %s' % \
				cmd.replace ('\n', ' '))

		# check that we found alleles using the user's given key; if
		# not, this is an error

		results = db.sql ('SELECT COUNT(1) FROM %s' % ALLELE_TABLE,
				'auto')
		if results[0][''] < 1:
			bailout ('Failed to find alleles for %s key %s' % \
				(keyType, value))

		# add an index to the temp table, to speed future processing

		try:
			db.sql ('''CREATE UNIQUE INDEX #tmp_all_key
				ON %s (_Allele_key)''' % ALLELE_TABLE, 'auto')
		except:
			bailout ('Failed to index %s' % ALLELE_TABLE)

	message ('Processed command-line')
	return 

#-----------------------------------------------------------------------------

def getOne (
	cmd, 		# string; SQL statement that returns a single row
	column = None	# string; name of desired column returned by 'cmd'
	):
	# Purpose: retrieve a single column's value from a given SQL statement
	#	that returns a single row (just a convenience function)
	# Returns: integer or string, whatever the column's value is
	# Assumes: can query the database
	# Effects: queries the database
	# Throws: SystemExit to exit this script in case of failure
	# Notes: If 'column' is not specified, we expect 'cmd' to return a
	#	single column, and that is the one whose value we return.

	# get a one-line version of 'cmd' for error-reporting & do the query

	cmdOut = cmd.replace ('\n', ' ')
	try:
		results = db.sql (cmd, 'auto')
	except:
		bailout ('Query failed: %s' % cmdOut)

	# ensure that we found exactly one row

	if not results:
		bailout ('Query found no rows: %s' % cmdOut)
	if len(results) > 1:
		bailout ('Query found more than one row: %s' % cmdOut)

	# if the user told us what column to return, then return that one

	if column:
		if not results[0].has_key(column):
			bailout ('Desired column (%s) not in results of: %s' \
				% (column, cmdOut))
		else:
			return results[0][column]

	# user did not specify a particular column, so return the one returned
	# by the query

	columns = results[0].keys()
	if len(columns) != 1:
		bailout ('Multiple columns returned by: %s' % cmdOut)
	return results[0][columns[0]]

#-----------------------------------------------------------------------------

def getTermKey (
	vocab,		# string; name of vocabulary
	term		# string; name of term in that vocabulary
	):
	# Purpose: retrieve the _Term_key for the given 'term' within 'vocab'
	# Returns: integer
	# Assumes: can query the database
	# Effects: queries the database
	# Throws: uses bailout() to raise SystemExit if an error occurs 

	termKey = getOne ('''select vt._Term_key
		from VOC_Term vt, VOC_Vocab vv
		where vv.name = "%s"
			and vt.term = "%s"
			and vv._Vocab_key = vt._Vocab_key''' % (vocab, term))
	return termKey

#-----------------------------------------------------------------------------

def buildNewRows():
	# Purpose: construct the new data rows which can be added to ALL_Cache
	# Returns: list of lists; each sublist has four integer items -- one
	#	for each column in ALL_Cache
	# Assumes: can query the database
	# Effects: queries the database
	# Throws: uses bailout() to raise SystemExit if an error occurs 

	# get controlled vocab values

	qtlTypeKey = getTermKey ("Allele Type", "QTL")
	cellLineKey = getTermKey ("Allele State", "Cell Line")
	mouseLineKey = getTermKey ("Allele State", "Mouse Line")
	originKey = getTermKey ("Strain Association Type", "Strain of Origin")
	specimenKey = getTermKey ("Strain Association Type",
		"Strain of Specimen")

	message ('retrieved five vocab terms')

	# retrieve basic allele info (if we have a temp table, then only get
	# the needed alleles; otherwise, get all alleles)

	if ALLELE_TABLE:
		results = db.sql ('''select a._Allele_key, a._Allele_Type_key
			from ALL_Allele a, %s t
			where a._Allele_key = t._Allele_key''', 'auto')
	else:
		results = db.sql ('''select _Allele_key, _Allele_Type_key
			from ALL_Allele''', 'auto')

	alleles = {}	# maps allele key to [state, refs, strain assoc type]

	for row in results:
		if row['_Allele_Type_key'] == qtlTypeKey:
			strainAssocType = specimenKey
		else:
			strainAssocType = originKey

		# Assume that a given allele only exists as a cell line; we
		# will come back later and update those which have been in
		# mice (which are the alleles cited as part of genotypes).
		# We will also come back to fill in the state reference later.

		alleles[row['_Allele_key']] = [
				cellLineKey,		# state key
				None,			# state refs key
				strainAssocType,	# assoc type key
				]

	message ('retrieved basic allele info')

	# Get a list of alleles present in mice (those alleles cited in 
	# genotypes).  If we have a temp table, then only get the desired
	# alleles; otherwise, get all.  For each of these alleles, update
	# their state in 'alleles'.

	if ALLELE_TABLE:
		results = db.sql ('''select distinct g._Allele_key
			from GXD_AlleleGenotype g, %s t
			where g._Allele_key = t._Allele_key''', 'auto')
	else:
		results = db.sql ('''select distinct _Allele_key
			from GXD_AlleleGenotype''', 'auto')

	for row in results:
		alleles[row['_Allele_key']][0] = mouseLineKey

	message ('retrieved genotype info')

	# We now need to look up the state reference for each allele that is
	# part of a genotype.  This will be the earliest reference for an MP
	# annotation for that allele's genotype.  If we have a temp table,
	# then only get the desired alleles; otherwise, get all.

	if ALLELE_TABLE:
		fromClause = ', %s t' % ALLELE_TABLE
		whereClause = 'and t._Allele_key = gag._Allele_key'
	else:
		fromClause = ''
		whereClause = ''

	results = db.sql ('''select distinct gag._Allele_key, ve._Refs_key,
			r.year, a.numericPart
		from GXD_AlleleGenotype gag %s, VOC_Annot va,
			VOC_Evidence ve, BIB_Refs r, ACC_Accession a
		where va._AnnotType_key = 1002 %s
			and va._Annot_key = ve._Annot_key
			and va._Object_key = gag._Genotype_key
			and ve._Refs_key = r._Refs_key
			and ve._Refs_key = a._Object_key
			and a._MGIType_key = 1
			and a._LogicalDB_key = 1
			and a.preferred = 1
			and a.private = 0
			and a.prefixPart = "J:"
		order by gag._Allele_key, r.year, a.numericPart''' % (
			fromClause, whereClause), 'auto')

	# Because of the ordering of the above query, the first reference for
	# a given allele will be the earliest (the desired) one.  Update
	# 'alleles' with this one.

	for row in results:
		alleleKey = row['_Allele_key']
		if alleles[alleleKey][1] == None:
			alleles[alleleKey][1] = row['_Refs_key']

	message ('retrieved state refs info')

	# Generate the list of rows to add to ALL_Cache from 'alleles'.

	alleleRows = []
	for (key, columns) in alleles.items():
		alleleRows.append ( [key] + columns )

	message ('collated new allele rows')

	return alleleRows

#-----------------------------------------------------------------------------

def deleteOldRows():
	# Purpose: remove from ALL_Cache the rows we are going to replace
	# Returns: nothing
	# Assumes: can write to ALL_Cache in the database
	# Effects: deletes rows from ALL_Cache
	# Throws: uses bailout() which throws SystemExit if an error occurs

	# if we have a temp table, then only delete the specified rows;
	# otherwise, delete all

	if ALLELE_TABLE:
		cmd = '''delete from ALL_Cache
			where _Allele_key in (
				select _Allele_key
				from %s)''' % ALLELE_TABLE
	else:
		cmd = 'delete from ALL_Cache'

	try:
		db.sql (cmd, 'auto')
	except:
		bailout ('Failed to delete rows from ALL_Cache')

	message ('deleted old rows from ALL_Cache')
	return

#-----------------------------------------------------------------------------

def addNewRows (
	alleleRows	# list of lists; as produced by buildNewRows()
	):
	# Purpose: adds the new rows (in 'alleleRows') to ALL_Cache in the
	#	mgd database
	# Returns: nothing
	# Assumes: 1. can write to ALL_Cache; 2. can use bcp; 3. can write
	#	temp file to file system
	# Effects: 1. adds rows to ALL_Cache; 2. may use new shell to run bcp;
	#	3. writes temp file to file system
	# Throws: uses bailout() which throws SystemExit if an error occurs

	# pre-process 'alleleRows' to convert None to null

	ar = []
	for row in alleleRows:
		if row[2] == None:
			row[2] = ''
		ar.append (tuple(row))

	# For small numbers of allele rows (below 'BCP_THRESHOLD'), we will
	# simply use inline SQL to add the rows

	if len(ar) < BCP_THRESHOLD:
		cmd = '''insert ALL_Cache (_Allele_key, _State_key,
				_StateRefs_key, _StrainAssocType_key)
			values (%d, %d, %s, %d)'''

		failed = []	# list of rows for which insert failed

		for allele in ar:
			try:
				db.sql (cmd % allele, 'auto')
			except:
				failed.append (allele)

		# if any addition of any rows failed, report them to stderr
		# and fail

		if failed:
			for allele in failed:
				sys.stderr.write ('Failed to add row: %s\n' \
					% str(allele))
			bailout ('Failures in inline SQL process')

		message ('added %d cache entries by inline SQL' % \
			len(ar) - len(failed))
	else:
		# too many entries for inline SQL (efficiency-wise), so we
		# will instead use bcp

		# string; path to data file we will write and then load
		myFile = tempfile.mktemp()

		# populate temporary data file

		try:
			fp = open (myFile, 'w')
			for allele in ar:
				fp.write ('%d\t%d\t%s\t%d\n' % allele)
			fp.close()
		except:
			bailout ('Cannot write file %s for bcp' % myFile)

		message ('generated temp file for bcp')

		# run bcp to load the file into ALL_Cache

		cmd = '%s %s..ALL_Cache in %s -c -S %s -U %s -P %s' % \
			( BCP, db.get_sqlDatabase(), myFile, 
				db.get_sqlServer(), db.get_sqlUser(),
				db.get_sqlPassword() )

		(stdout, stderr, exitCode) = runCommand.runCommand (cmd)

		# if bcp failed, then report it and fail

		if exitCode:
			sys.stderr.write ('bcp command failed:\n')
			sys.stderr.write (cmd + '\n')
			sys.stderr.write ('stdout:\n')
			sys.stderr.write (stdout + '\n')
			sys.stderr.write ('stderr:\n')
			sys.stderr.write (stderr + '\n')
			sys.stderr.write ('exit code: %d\n' % exitCode)
			bailout ('error in bcp process')

		message ('added %d cache entries by bcp' % len(ar))

		# remove our temp file

		try:
			os.remove (myFile)
		except:
			# non-fatal error

			sys.stderr.write ('Cannot remove temp file %s\n' % \
				myFile)

		message ('removed temp file for bcp')
	return

#-----------------------------------------------------------------------------

def writeProfile():
	# Purpose: dump the profiler's timing data to stdout
	# Returns: nothing
	# Assumes: can write to stdout
	# Effects: writes to stdout
	# Throws: nothing

	print '---------- %s successful ----------' % sys.argv[0]
	PRO.write()
	print '---------- end output %s ----------' % sys.argv[0]
	return

#-----------------------------------------------------------------------------

def main():
	# Purpose: main logic of script
	# Returns: nothing
	# Assumes: see assumptions of all functions called by this one
	# Effects: writes to file system, updates database, uses bcp in a
	#	subshell
	# Throws: propagates any exceptions

	processCommandLine()
	rows = buildNewRows()

	# Note that up to this point, any failures in this script will have
	# occurred before any changes to data in the database have been made.
	# Later failures leave the database in an ambiguous state where one
	# should either: 1. reload it, or 2. completely regenerate data in
	# the ALL_Cache table

	deleteOldRows()
	addNewRows(rows)
	writeProfile()
	return

#-----------------------------------------------------------------------------

###--------------------###
###--- main program ---###
###--------------------###

if __name__ == '__main__':
	main()
