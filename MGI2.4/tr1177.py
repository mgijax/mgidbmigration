#!/usr/local/bin/python

import os
import sys
import cgi
import string
#import regsub
import getopt
import db

## Global variables

DATABASE	= ''
SERVER		= ''
USER		= ''
PASSWORD	= ''
FILENAME	= ''

CV_Type		= {}	# CV_Type [lowercase type] = key
CV_Mode		= {}	# CV_Mode [lowercase mode] = key
CV_Mutation	= {}	# CV_Mutation [lowercase mutation] = key

allele_symbol	= {}	# allele_symbol [symbol] = (name, key, marker symbol,
			#	marker key)
allele_name	= {}	# allele_name [(name, marker symbol)] = (symbol, key,
			#	marker key)
ref_keys	= {}	# ref_keys [j num] = _Refs_key
strain_keys	= {}	# strain_keys [strain name] = _Strain_key

withdrawns	= {}	# withdrawns [symbol] = (current_symbol, current_key)

max_key		= None	# highest allele key allocated so far


reviewed_bits = { 'Yes' : 1, 'No' : 0 }


USAGE = '''
	%s -U <user> -P <pwd> [-S <srvr>][-D <db>] <fn>

	-U : login to the database using the given username
	-P : login to the database using the given password
	-S : login to the given database server (current: %s)
	-D : login to the given database (current: %s)

	<fn> : path to the input file
'''

## Global constants - Columns in the spreadsheet

C_GENE 		= 0
C_ALLELE_SYMBOL	= 1
C_MODE		= 2
C_STRAIN	= 3
C_ALLELE_TYPE	= 4
C_REVIEWED	= 5
C_ALLELE_NAME	= 6
C_RESOURCE	= 7
C_REF		= 8
C_USED_IN	= 9
C_OTHER_NAME	= 10
C_CURATOR	= 11
C_MOL_MUTATION	= 12
C_MOL_REF	= 13
C_MOL_NOTES	= 14
C_NOTE		= 15

C_COUNT		= 16		# count of the columns

fp = open ('tr1177.py.log', 'w')

## Functions:

def usage ():
	return USAGE % (sys.argv[0], SERVER, DATABASE)

def initialize ():
	global SERVER, DATABASE

	if os.environ.has_key ('DSQUERY'):
		SERVER = os.environ ['DSQUERY']
	if os.environ.has_key ('MGD'):
		DATABASE = os.environ ['MGD']
	return

def debug (s):
	fp.write ('%s\n' % s)
	return

def bailout (s):
	debug (s)
	sys.exit (-1)

def process_options ():
	global SERVER, DATABASE, USER, PASSWORD, FILENAME

	try:
		optlist, args = getopt.getopt (sys.argv[1:], 'S:D:U:P:')
	except getopt.error:
		bailout (usage())

	if len(args) != 1:
		bailout ("Too many arguments.\n\n" + usage())
	FILENAME = args[0]

	for (option, value) in optlist:
		if option == '-S':
			SERVER = value
		elif option == '-D':
			DATABASE = value
		elif option == '-U':
			USER = value
		elif option == '-P':
			PASSWORD = value

	if (USER == '') or (PASSWORD == ''):
		bailout ("Must specify user and password.\n\n" + usage())

	db.set_sqlLogin (USER, PASSWORD, SERVER, DATABASE)
	return

def sql (x):
	return db.sql (x, 'auto')

def get_db_info ():
	global CV_Type, CV_Mode, CV_Mutation, allele_symbol, allele_name, \
		ref_keys, strain_keys, withdrawns, max_key

	debug ('Getting controlled vocabs from database')
	results = sql ( [
		'select _Allele_Type_key, alleleType from ALL_Type',
		'select _Mode_key, mode from ALL_Inheritance_Mode',
		'select _Mutation_key, mutation from ALL_Molecular_Mutation',
		'''select a._Allele_key, a.symbol, a.name,
				marker_symbol = m.symbol,
				marker_key = m._Marker_key
			from ALL_Allele a, MRK_Marker m
			where a._Marker_key = m._Marker_key''',
		'''select _Object_key, accID
			from ACC_Accession
			where _MGIType_key = 1 and _LogicalDB_key = 1
				and accID like "J:%"''',
		'select _Strain_key, strain from PRB_Strain',
		'''select symbol, current_symbol, _Current_key
			from MRK_Current_View
			where (symbol != current_symbol)''',
		'SELECT max_key=max(_Allele_key) FROM ALL_Allele'
		] )

	for row in results[0]:
		CV_Type [ string.lower (row['alleleType']) ] = \
			row['_Allele_Type_key']
	for row in results[1]:
		CV_Mode [ string.lower (row['mode']) ] = row['_Mode_key']
	for row in results[2]:
		CV_Mutation [ string.lower (row['mutation']) ] = \
			row['_Mutation_key']
	for row in results[3]:
		if allele_symbol.has_key (row['symbol']):
			debug ('<LI> Symbol "%s" is a duplicate' % \
				row['symbol'])
		else:				
			allele_symbol [ row['symbol'] ] = (row['name'], \
				row['_Allele_key'], row['marker_symbol'], \
				row['marker_key'])
		key = (row['name'], row['marker_symbol'])
		if allele_name.has_key (key):
			debug ('''<LI> Name "%s" for symbol "%s" was
				already stored for symbol "%s"''' % \
				(row['name'], cgi.escape (row['symbol']),
				cgi.escape (allele_name[key][0])))
		else:				
			allele_name [key] = (row['symbol'], \
				row['_Allele_key'], row['marker_key'])
	for row in results[4]:
		ref_keys [ row['accID'] ] = row['_Object_key']
	for row in results[5]:
		strain_keys [ row['strain'] ] = row['_Strain_key']
	strain_keys ['Not specified'] = strain_keys ['Not Specified']
	strain_keys ['Not curated'] = strain_keys ['Not Curated']
	for row in results[6]:
		withdrawns [ row['symbol'] ] = (row['current_symbol'],
			row['_Current_key'])
	max_key = results[7][0]['max_key']
	return

def readfile (filename):
	debug ('Reading input file')
	fp = open (filename, 'r')
	lines = fp.readlines()
	fp.close()
	return lines

def parselines (input_lines):
	debug ('Parsing input file')
	mx = 0
	lines = []
	for line in input_lines:
		if len(string.strip (line)) > 0:
			pieces = string.split (line, '\t')
			mx = max (mx, len(pieces))
			lines.append (pieces)
	if mx > C_COUNT:
		bailout ('Data file has too many columns.\n\n' + usage())
	for i in range(0, len(lines)):
		if len(lines[i]) < C_COUNT:
			lines[i] = lines[i] + [''] * (C_COUNT - len(lines[i]))
	return lines

def get_marker_key (s):
	results = sql('''select c._Current_key
			from MRK_Current c, MRK_Marker m
			where m.symbol="%s"
				and m._Marker_key = c._Marker_key''' % s)
	if len(results) > 0:
		return results[0]['_Current_key']
	return None

def line_check (line):
	# returns (0/1 for ok?, cleaned up line)

	line = map (string.strip, line)

	mrk_symbol = line[C_GENE]
	all_symbol = line[C_ALLELE_SYMBOL]
	all_name = line[C_ALLELE_NAME]
	all_type = string.lower (line[C_ALLELE_TYPE])
	all_mode = string.lower (line[C_MODE])
	strain = line[C_STRAIN]
	reviewed = line[C_REVIEWED]
	mutations = line[C_MOL_MUTATION]

	mol_ref = line[C_MOL_REF]
	if mol_ref:
		mol_ref = "J:" + mol_ref

	ref = line[C_REF]
	if ref:
		ref = "J:" + ref

	new_line = line[:]			# make copy to alter

	# look up allele & marker info from database

	name1 = symbol1 = key1 = marker1 = mkey1 = None
	name2 = symbol2 = key2 = marker2 = mkey2 = None

	if allele_symbol.has_key (all_symbol):
		(name1, key1, marker1, mkey1) = allele_symbol [all_symbol]
	else:
		# if marker symbol was withdrawn, alter mrk_symbol and
		# all_symbol

		if withdrawns.has_key (mrk_symbol):
			old_mrk = mrk_symbol
			mrk_symbol = withdrawns [mrk_symbol][0]
			new_all_symbol = all_symbol
			if old_mrk == all_symbol [:len(old_mrk)]:
				new_all_symbol = mrk_symbol + \
					all_symbol [len(old_mrk):]
				if allele_symbol.has_key (new_all_symbol):
					all_symbol = new_all_symbol
					(name1, key1, marker1, mkey1) = \
						allele_symbol [all_symbol]
				else:
					new_all_symbol = '%s<%s-%s' % \
						(mrk_symbol, old_mrk,
						all_symbol [len(old_mrk)+1:])
					if allele_symbol.has_key (
						new_all_symbol):
					    all_symbol = new_all_symbol
					    (name1, key1, marker1, mkey1) = \
						allele_symbol [all_symbol]

	if allele_name.has_key ( (all_name, mrk_symbol) ):
		(symbol2, key2, mkey2) = allele_name [(all_name, mrk_symbol)]
		marker2 = mrk_symbol
	
	errors = []

	# problems with allele keys?

	if key1 is None:
		if key2 is None:
			# no match -- we need to insert this allele

			new_line.append (None)		# signal to add record
			mkey = get_marker_key (new_line [C_GENE])
			if mkey is None:
				errors.append ('Unknown marker: "%s"' % \
					new_line[C_GENE])
			else:
				new_line [C_GENE] = mkey
		else:
			new_line [C_GENE] = mkey2
			new_line.append (key2)
	elif (key2 is None) or (key1 == key2):
		new_line [C_GENE] = mkey1
		new_line.append (key1)
	else:
		# assume the key lookup by symbol is correct
		new_line [C_GENE] = mkey1
		new_line.append (key1)

	# problems with references?

	if ref:
		if not ref_keys.has_key (ref):
			errors.append ('Unknown reference "%s"' % ref)
		else:
			new_line [C_REF] = ref_keys [ref]
	else:
		new_line [C_REF] = "null"

	if mol_ref:
		if not ref_keys.has_key (mol_ref):
			errors.append ('Unknown reference "%s"' % mol_ref)
		else:
			new_line [C_MOL_REF] = ref_keys [mol_ref]
	else:
		new_line [C_MOL_REF] = "null"

	# problem with strain?

	if strain_keys.has_key (strain):
		new_line [C_STRAIN] = strain_keys [strain]
	else:
		errors.append ("Unknown strain: %s" % strain)


	# problems with controlled vocabs?

	if CV_Type.has_key (all_type):
		new_line [C_ALLELE_TYPE] = CV_Type [all_type]
	else:
		errors.append ("Unknown allele type: %s" % all_type)

	if CV_Mode.has_key (all_mode):
		new_line [C_MODE] = CV_Mode [all_mode]
	else:
		errors.append ("Unknown inheritance mode: %s" % all_mode)

	# problem with molecular mutations?

	mutation_list = []
	if mutations:
		for item in string.split (string.lower (mutations), '/'):
			if CV_Mutation.has_key (item):
				mutation_list.append (CV_Mutation [item])
			else:
				errors.append ("Unknown mutation: %s" % item)
	new_line [C_MOL_MUTATION] = mutation_list

	# problem with reviwed column?

	if reviewed_bits.has_key (reviewed):
		new_line [C_REVIEWED] = reviewed_bits [reviewed]
	else:
		errors.append ("Unknown reviewed value: %s" % reviewed)

	# report any errors and return appropriate status code

	if errors:
		debug ('<P><CODE>')
		debug (cgi.escape (string.join (line[:4], '    ') + ' ...'))
		debug ('</CODE><BR>')
		for i in range(0, len(errors)):
			debug ("<I>%d. %s</I><BR>" % \
				(i+1, cgi.escape(errors[i])))
		debug ('<P>')
		return (0, line)
	return (1, new_line)


whitespace = {	' ' : 1,	'\t' : 1,	'\n': 1 }

def chunks (s, max_size = 255):
	# split string 's' into a list of strings, each of which is at most
	# 'max_size' characters long.  split at whitespace boundaries where
	# possible (where a single word is longer than 'max_size', it is not
	# possible).

	last = 0
	list = []
	begin = 0
	for i in range (0, len (s)):
		if whitespace.has_key (s[i]):
			last = i
		elif i - begin >= max_size:
			if last > begin:
				list.append (s[begin:last])
				begin = last
			else:
				list.append (s[begin:i])
				begin = i
	if begin < (len(s) - 1):
		list.append (s[begin:])
	return list

# canned SQL statements for loading the data

Q1A = '''INSERT ALL_Allele (_Allele_key, _Refs_key, _Molecular_Refs_key,
		_Marker_key, _Strain_key, _Mode_key, _Allele_Type_key,
		reviewed, userID, symbol, name)
	VALUES (%d, %s, %s,
		%d, %d, %d, %d,
		%d, "%s", "%s", "%s")'''

Q1B = '''UPDATE ALL_Allele
	SET	_Refs_key = %s,
		_Molecular_Refs_key = %s,
		_Marker_key = %d,
		_Strain_key = %d,
		_Mode_key = %d,
		_Allele_Type_key = %d,
		reviewed = %d,
		userID = "%s",
		symbol = "%s",
		name = "%s"
	WHERE _Allele_key = %d'''

Q2 = 'INSERT ALL_Allele_Mutation (_Allele_key, _Mutation_key) VALUES (%d, %d)'

Q3 = 'INSERT %s (_Allele_key, sequenceNum, note) VALUES (%d, %d, "%s")'

def process_line (line):
	# load the data for 'line' to the database.  assumes that the
	# contents of 'line' are valid.
	global max_key

	[ marker_key, all_symbol, mode_key, strain_key,
	  allele_type_key, reviewed, allele_name,
	  resource, ref_key, used_in, other_name,
	  curator, mol_mutation_list, mol_ref_key,
	  mol_note, note, allele_key ] = line

	if allele_key is None:		# need to add a new allele record
		max_key = max_key + 1
		allele_key = max_key
		queries = [ Q1A % (allele_key, ref_key, mol_ref_key,
			marker_key, strain_key, mode_key, allele_type_key,
			reviewed, curator, all_symbol, allele_name) ]

	else:				# update an existing record
		queries = [ Q1B % (ref_key, mol_ref_key, marker_key,
			strain_key, mode_key, allele_type_key, reviewed,
			curator, all_symbol, allele_name, allele_key) ]

	if len(mol_mutation_list) > 0:
		for mutation_key in mol_mutation_list:
			queries.append (Q2 % (allele_key, mutation_key))
	if note:
		notes = chunks (note)
		for i in range (0, len (notes)):
			queries.append (Q3 % ('ALL_Note', allele_key, i + 1, \
				notes[i]))
	if mol_note:
		molecular_notes = chunks (mol_note)
		for i in range (0, len (molecular_notes)):
			queries.append (Q3 % ('ALL_Molecular_Note', \
				allele_key, i + 1, molecular_notes[i]))
	sql (queries)
#	for q in queries:
#		debug (q)
#	debug (40 * '-')

	return

def main ():
	process_options()
	get_db_info()
	lines = parselines (readfile (FILENAME))
	for line in lines:
		(ok, new_line) = line_check (line)
		if ok:
			process_line (new_line)
	return

if __name__ == '__main__':
	initialize()		# set DATABASE and SERVER
	main()

fp.close()
