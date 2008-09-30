#!/usr/local/bin/python

import sys
import os
import db
import string

USAGE = '''Usage: %s <file> <vocab> <J#> <ldb> <user> <pwd> <server> <db>
	<file>   : name of input file
	<vocab>  : name of the vocabulary in the database
	<J#>     : accession ID for reference for vocabulary
	<ldb>    : logical database key for originator of vocabulary terms
	<user>   : name of the database user for the load
	<pwd>    : password file for given username
	<server> : name of the database server
	<db>     : name of the database

	Note: This script should not run while any other Inserts occur for
	the VOC_Vocab and VOC_Term tables.

	Loads a simple vocabulary into the VOC_* tables in the given database
	as the given username.  If the vocabulary already exists in that
	database, then we only add new terms to the existing vocabulary.

	Each line of the input file will contain the information for one
	vocabulary term.  It must contain the term itself, then a tab, then
	the term's abbreviation.  If the vocabulary already exists, then we
	will only add new terms to it, and they will be added in order after
	the existing terms in the database.

	Error and status messages are written to stderr.
''' % sys.argv[0]

###------------------------------------------------------------------------###

def bailout (
	s,			# string; error message to give to user
	showUsage = True	# boolean; show usage statement first or not?
	):
	# Purpose: exit this script with an error message
	# Returns: does not return
	# Assumes: nothing
	# Modifies: writes to stderr, exits script
	# Throws: SystemExit exception to exit this script

	if showUsage:
		sys.stderr.write (USAGE)
	sys.stderr.write ('Error: ' + s + '\n')
	sys.exit(1)

###------------------------------------------------------------------------###

def processArgs ():
	# Purpose: process the command-line arguments to get us ready for
	#	real processing, including doing error-checking of the parms
	# Returns: tuple with seven items -- list of strings (input lines),
	#	string (vocab name), integer (vocab key), string (J#),
	#	integer (reference key), integer (logical db key), string
	#	(logical db name)
	# Assumes: the user account specified will have write privileges
	# Modifies: reads from the file system, queries the database
	# Throws: propagates SystemExit from bailout() if errors occur

	if len(sys.argv) < 9:
		bailout ('Too few command-line arguments')
	elif len(sys.argv) > 9:
		bailout ('Too many command-line arguments')

	[ file, vocab, jnum, ldb, user, pwd, server, dbname ] = sys.argv[1:]

	# see if we can read the input file, exit if not

	try:
		fp = open (file, 'r')
		inputLines = map (string.strip, fp.readlines())
		fp.close()
	except:
		bailout ('Cannot read input file: %s' % file)

	# see if we can read the password file, exit if not

	try:
		fp = open (pwd, 'r')
		password = fp.readline().strip()
		fp.close()
	except:
		bailout ('Cannot read password file: %s' % pwd)

	# see if we can log in to the database, exit if not

	db.set_sqlLogin (user, password, server, dbname)
	try:
		db.sql ('SELECT COUNT(1) FROM MGI_dbInfo', 'auto')
	except:
		bailout ('Database login failed')

	# try to look up the key for the given vocabulary name

	results = db.sql ('''SELECT _Vocab_key, _Refs_key, _LogicalDB_key
		FROM VOC_Vocab 
		WHERE name = "%s"''' % vocab, 'auto')
	if not results:
		vocabKey = None
		dbRefsKey = None
		dbLdbKey = None
	else:
		vocabKey = results[0]['_Vocab_key']
		dbRefsKey = results[0]['_Refs_key']
		dbLdbKey =  results[0]['_LogicalDB_key']

	# try to look up the key for the given J#

	results = db.sql ('''SELECT _Object_key
		FROM ACC_Accession
		WHERE _MGIType_key = 1		-- reference
			AND _LogicalDB_key = 1	-- MGI
			AND accID = "%s"''' % jnum, 'auto')
	if not results:
		bailout ('Unknown reference ID: %s' % jnum)
	refsKey = results[0]['_Object_key']

	if dbRefsKey and (dbRefsKey != refsKey):
		bailout ('Mismatching _Refs_key: %s has %d, vocab has %d' % \
			(jnum, refsKey, dbRefsKey))

	# confirm that ldb is a valid logical database key

	try:
		ldbKey = int(ldb)
	except:
		bailout ('Invalid _LogicalDB_key: %s not an integer' % ldb)

	results = db.sql ('''SELECT name
		FROM ACC_LogicalDB
		WHERE _LogicalDB_key = %d''' % ldbKey, 'auto')
	if not results:
		bailout ('Unknown _LogicalDB_key: %d' % ldbKey)
	ldbName = results[0]['name']

	if dbLdbKey and (dbLdbKey != ldbKey):
		bailout ('Mismatching _LogicalDB_key: vocab has %d, not %d' \
			% (dbLdbKey, ldbKey))

	return inputLines, vocab, vocabKey, jnum, refsKey, ldbKey, ldbName

###------------------------------------------------------------------------###

def parseLines (
	inputLines	# list of strings; input lines from the data file
	):
	# Purpose: parse the input lines to extract the terms and their
	#	abbreviations
	# Returns: list of two-item lists; each sublist has the term as its
	#	first item and its abbreviation as its second item
	# Assumes: nothing
	# Modifies: nothing
	# Throws: propagates SystemExit from bailout() if there are lines with
	#	the wrong number of items on them

	terms = []	# list to be returned (see description above)
	i = 1		# line number of line being processed
	invalid = []	# list of line numbers with wrong number of items

	for line in inputLines:
		items = line.split('\t')
		if len(items) < 2:
			invalid.append(i)
		terms.append (items)
		i = i + 1

	if invalid:
		bailout ('Line(s) with wrong number of columns: %s' % \
			', '.join (map (str, invalid)))
	return terms

###------------------------------------------------------------------------###

def createVocabulary (
	vocabName, 	# string; name of vocabulary to be created
	refsKey, 	# integer; reference for the vocabulary
	ldbKey		# integer; logical db for the vocabulary
	):
	# Purpose: create a new vocabulary with the given 'vocabName'
	# Returns: integer _Vocab_key for the new vocabulary
	# Assumes: nobody is inserting records into VOC_Vocab while this
	#	function is running
	# Modifies: writes to the VOC_Vocab table in the database
	# Throws: propagates SystemExit if problems occur

	# find the current highest vocab key

	cmd1 = 'SELECT MAX(_Vocab_key) FROM VOC_Vocab'

	results = db.sql (cmd1, 'auto')
	if not results:
		vocabKey = 1
	else:
		vocabKey = results[0][''] + 1

	# add a new record for the new vocabulary

	cmd2 = '''INSERT VOC_Vocab (_Vocab_key, _Refs_key, _LogicalDB_key,
			isSimple, isPrivate, name)
		VALUES (%d, %d, %d, %d, %d, "%s")''' % (vocabKey, refsKey,
			ldbKey, 1, 0, vocabName)
	try:
		results = db.sql (cmd2, 'auto')
	except:
		bailout ('Cannot create new vocabulary "%s" as key %d' % \
			(vocabName, vocabKey))

	return vocabKey

###------------------------------------------------------------------------###

def getNewTerms (
	vocabKey, 	# integer; key of vocabulary to which we are adding
	terms		# list of two-item lists, as from parseLines()
	):
	# Purpose: determine which of the given 'terms' are new when compared
	#	with the terms currently in the database for the 'vocabKey'
	# Returns: list of two-item lists (a subset of 'terms')
	# Assumes: nothing
	# Modifies: writes to stderr if any of the 'terms' or their
	#	abbreviations already exist in the database for this vocab
	# Throws: propagates SystemExit if there are problems accessing the db

	# retrieve the existing terms and abbreviations for the vocabulary,
	# and store a case-insensitive version of each

	oldTerms = {}	# maps term to its abbreviation
	oldAbbrev = {}	# simply tracks existence of abbreviation

	try:
		results = db.sql ('''SELECT term, abbreviation
			FROM VOC_Term
			WHERE _Vocab_key = %d''' % vocabKey, 'auto')
	except:
		bailout ('Failed to retrieve existing terms for vocab %d' % \
			vocabKey)

	for row in results:
		term = row['term'].lower()
		abbrev = row['abbreviation'].lower()

		oldTerms[term] = abbrev
		oldAbbrev[abbrev] = 1

	# go through the new terms & abbreviations to see which are new

	existingTerms = []	# rows from 'terms' which match by term
	existingAbbrev = []	# rows from 'terms' which match by abbrev
	newTerms = []		# rows from 'terms' which should be added

	for row in terms:
		lowerTerm = row[0].lower()
		lowerAbbrev = row[1].lower()

		if oldTerms.has_key (lowerTerm):
			existingTerms.append (row)
		elif oldAbbrev.has_key (lowerAbbrev):
			existingAbbrev.append (row)
		else:
			newTerms.append (row)

	# report any terms which we will not add (and why), but do not fail
	# because of it

	if existingTerms or existingAbbrev:
		sys.stderr.write ('Did not add these terms:\n')
		for [term, abbrev] in existingTerms:
			sys.stderr.write ('  "%s" : term already exists\n' % \
				term)
		for [term, abbrev] in existingAbbrev:
			sys.stderr.write (
				'  "%s" : abbrev (%s) already exists\n' % \
					(term, abbrev))
	return newTerms

###------------------------------------------------------------------------###

def addTerms (
	vocabKey, 	# integer; vocabulary key
	newTerms	# list of two-item lists; as from getNewTerms()
	):
	# Purpose: actually add the terms in 'newTerms' to the vocabulary
	#	identified by 'vocabKey' in the database
	# Returns: nothing
	# Assumes: 1. none of the terms (or their abbreviations) in 'newTerms'
	#	already exist for this 'vocabKey' in the database; 2. nothing
	#	else is adding records to VOC_Term while this function runs
	# Modifies: inserts records into VOC_Term in the database; writes
	#	messages to stderr
	# Throws: propagates all exceptions

	# get the current highest term key, so we know what to add after

	results = db.sql ('SELECT MAX(_Term_key) FROM VOC_Term', 'auto')
	if results:
		termKey = results[0]['']
	else:
		termKey = 0

	# get the current highest sequence number for this vocabulary, so we
	# know what to add after

	results = db.sql ('''SELECT MAX(sequenceNum)
			FROM VOC_Term
			WHERE _Vocab_key = %d''' % vocabKey, 'auto')
	if results:
		if results[0][''] != None:
			seqNum = results[0]['']
		else:
			seqNum = 0
	else:
		seqNum = 0

	# template of SQL statement for additions

	template = '''INSERT VOC_Term (_Term_key, _Vocab_key, term,
			abbreviation, sequenceNum, isObsolete)
		VALUES (%d, ''' + str(vocabKey) + ', "%s", "%s", %d, 0)'

	# do the additions

	failed = []		# list of inserts which failed
	succeeded = 0		# count of inserts which succeeded

	for [term, abbrev] in newTerms:
		termKey = termKey + 1
		seqNum = seqNum + 1

		cmd = template % (termKey, term, abbrev, seqNum)

		try:
			db.sql (cmd, 'auto')
			succeeded = succeeded + 1
		except:
			failed.append (cmd)

	# error reporting

	if failed:
		sys.stderr.write ('These insert statements failed:\n')
		for cmd in failed:
			sys.stderr.write ('  ' + cmd + '\n')

	# success reporting

	print '%d terms were successfully added for vocab %d\n' \
		% (succeeded, vocabKey)
	return

###------------------------------------------------------------------------###

def main ():
	# Purpose: main processing routine
	# Returns: nothing
	# Assumes: user specified on command-line can write to database
	# Modifies: reads from file system, writes to database, writes to
	#	stderr
	# Throws: propagates SystemExit if errors occur

	inputLines, vocab, vocabKey, jnum, refsKey, ldbKey, ldbName = \
		processArgs()
	terms = parseLines (inputLines)

	if vocabKey == None:
		vocabKey = createVocabulary (vocab, refsKey, ldbKey)
		sys.stderr.write ('created vocab key %d\n' % vocabKey)

	addTerms (vocabKey, getNewTerms (vocabKey, terms))
	sys.stderr.write ('normal exit\n')
	return

###------------------------------------------------------------------------###

# main program

if __name__ == '__main__':
	main()
