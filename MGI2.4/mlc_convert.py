#!/usr/local/bin/python

# TR 148
# convert MLC_Marker.tag from varchar to integer
# convert \L(symbol) to \L(tag)

# modified from original conversion script written by Jon Beal

import sys
import regex
import regsub
import string
import getopt
import db

# ************ Global variables ************

SERVER = 'MGD_DEV'		# database access info...
USER = 'mgd_dbo'
DATABASE = 'mgd_release'
PASSWORD = string.strip(open('/opt/sybase/admin/.mgd_dbo_password', 'r').readline())

BLOCK_SIZE = 50			# process how many MLC records in a batch?

USAGE = '''
%s [-S server][-D database][-U user][-P password file][-F database][-b block_size]

Defaults:
	server =     "%s"
	database =   "%s"
	user =       "%s"
	password =   "%s"
	block_size = "%s"

The block_size is the number of MLC records to process in one batch.

''' % (sys.argv[0], SERVER, DATABASE, USER, PASSWORD, BLOCK_SIZE)

# ************ Functions ************

def convert (marker_tags, text):
	# Purpose: convert the string "text" from \L(symbol) to \L(tag)
	# Returns: the string after all conversion steps
	# Assumes: nothing
	# Effects: nothing
	# Throws: nothing

	for oldtag in marker_tags.keys():
		oldMarkup = '\\L(%s)' % (oldtag)
		newMarkup = 'L(%s)' % (marker_tags[oldtag])
		text = regsub.gsub (oldMarkup, newMarkup, text)

	text = regsub.gsub ('"', '""', text)	# for Sybase
	return text


def process_options ():
	# Purpose: process the command line options
	# Returns: nothing
	# Assumes: if block size is specified, it is an integer
	# Effects: updates global varibles SERVER, USER, DATABASE, PASSWORD,
	#	and BLOCK_SIZE
	# Throws: ValueError if the specified block size is not an integer

	global SERVER, USER, DATABASE, PASSWORD, BLOCK_SIZE

	try:
		optlist, args = getopt.getopt (sys.argv[1:], 'S:U:D:P:b:F:')	
	except getopt.error:
		print USAGE
		sys.exit (-1)

	if len(args) > 0:
		print USAGE
		sys.exit (-1)

	for (parm, value) in optlist:
		if parm == '-S':
			SERVER = value
		elif parm == '-U':
			USER = value
		elif parm == '-D':
			DATABASE = value
		elif parm == '-P':
			PASSWORD = string.strip(open(value, 'r').readline())
		elif parm == '-b':
			BLOCK_SIZE = string.atoi (value)
	if BLOCK_SIZE > 200:
		print USAGE
		print 'Please use a block_size <= 200'
		sys.exit(-1)
	db.set_sqlLogin (USER, PASSWORD, SERVER, DATABASE)
	return


def get_marker_tags (key, tbl):
	# Purpose: get a dictionary of old tag/new tag from the appropriate MLC_Marker tables
	# Returns: see Purpose
	# Assumes: nothing
	# Effects: nothing
	# Throws: sybase.error if there's a problem with db access

	#
	# ex.  for key = 102, old tag/new tag dict will look like this:
	#
	# {'Acy1', 1} {'Bgl-2', 2} {'Mod1', 3}
	#

	if tbl == 'MLC_Text':
		markerTbl = 'MLC_Marker'
	else:
		markerTbl = 'MLC_Marker_edit'

	tagdict = {}
	res = db.sql ('select oldTag = o.tag, newTag = n.tag from %s_Temp o, %s n where o._Marker_key = %d and o._Marker_key = n._Marker_key and o._Marker_key_2 = n._Marker_key_2' % (markerTbl, markerTbl, key), 'auto')
	for rec in res:
		tagdict[rec['oldTag']] = rec['newTag']
	return tagdict
	
def get_keys (tbl):
	# Purpose: get a list of _Marker_keys from 'tbl'
	# Returns: see Purpose
	# Assumes: nothing
	# Effects: nothing
	# Throws: sybase.error if there's a problem with db access

	list = []
	res = db.sql ('select _Marker_key from %s' % tbl, 'auto')
	for rec in res:
		list.append (rec ['_Marker_key'])
	return list
	

def chunk (list, chunk_size = 0):
	# Purpose: split 'list' into sublists of size 'chunk_size'
	# Returns: a list of lists, each of which has at most 'chunk_size'
	#	items.  The concatenation of these lists would equal the
	#	original 'list'.
	# Assumes: chunk_size is a positive integer
	# Effects: nothing
	# Throws: nothing

	
	if (chunk_size == 0) or (len(list) <= chunk_size):
		return [list]
	else:
		return [list[:chunk_size]] + \
			chunk (list [chunk_size:], chunk_size)

	
def get_block (list, tbl):
	# Purpose: get info from database for _Marker_keys in "list"
	# Returns: list of dictionaries, each with keys '_Marker_key' and
	#	'description'
	# Assumes: nothing
	# Effects: nothing
	# Throws: sybase.error if there are database problems

	return db.sql ('''
		select _Marker_key, description
		from %s
		where (_Marker_key in (%s))''' % \
			(tbl, string.join (map (str, list), ', ')), 'auto')


def save_block (list, tbl):
	# Purpose: saves the contents of "list" back to the database.
	# Returns: nothing
	# Assumes: each element in "list" is a dictionary with keys
	#	"_Marker_key" and "description"
	# Effects: alters contents of 'tbl'.description in SERVER:DATABASE
	# Throws: sybase.error if there are database problems

	cmds = []
	for rec in list:
		s = '''
			update %s
			set description = "%s"
			where (_Marker_key = %d)
			''' % (tbl, rec['description'], rec['_Marker_key'])
		cmds.append (s)
	db.sql (cmds, 'auto')
	return


def main ():
	# Purpose: main program
	# Returns: nothing
	# Assumes: nothing
	# Effects: updates MLC text data (MLC_Text.description) and
	#	(MLC_Text_edit.description) in SERVER:DATABASE
	# Throws: nothing

	try:
		process_options ()
	except ValueError:
		print USAGE
		sys.exit (-1)

	for table in ('MLC_Text', 'MLC_Text_edit'):
		done = 0
		all_keys = get_keys (table)
		for key_list in chunk (all_keys, BLOCK_SIZE):
			record_list = get_block (key_list, table)
			for rec in record_list:
				marker_tags = get_marker_tags (rec['_Marker_key'], table)
				rec['description'] = \
					convert (marker_tags, rec['description'])
			save_block (record_list, table)

			done = done + len(record_list)
			s = '%s Saved: %s of %s in %s %s' % (20 * '-', done, 
				len (all_keys), table, 20 * '-')
			print s
			for record in record_list:
				print record['_Marker_key'],
			print
			print '-' * len(s)
			print
	return

if __name__ == '__main__':
	main ()
