#!/usr/local/bin/python

# Remove ALL italic tags from ALL for MLC_Text and MLC_Text_edit
# TR 1103



import os 
import sys
import regex
import regsub
import string
import getopt
import mgdlib

# ************ Global variables ************

# italic_list = []  # the global list containing all HTML strings with italic 
		  #tags on both ends

###########################

SERVER = os.environ['DSQUERY']          # database access info...
USER = 'mgd_dbo'
DATABASE = os.environ['MGD']
PASSWORD = ''

BLOCK_SIZE = 50			# process how many MLC records in a batch?

USAGE = '''
%s [-S server][-D database][-U user][-P password][-b block_size]
	[-e extraction] [-u update]

Defaults:
	server =     "%s"
	database =   "%s"
	user =       "%s"
	password =   "%s"
	block_size = "%s"
	

The block_size is the number of MLC records to process in one batch.

You can use either option "-e" or option "-u", but not both each time.

''' % (sys.argv[0], SERVER, DATABASE, USER, PASSWORD, BLOCK_SIZE)

# ************ Functions ************


def process_options ():
	# Purpose: process the command line options
	# Returns: strings to extract or update database 
	# Assumes: if block size is specified, it is an integer
	# Effects: updates global varibles SERVER, USER, DATABASE, PASSWORD,
	#	   and BLOCK_SIZE
	# Throws: ValueError if the specified block size is not an integer

	global SERVER, USER, DATABASE, PASSWORD, BLOCK_SIZE
	extract = ''
	update  = ''
	try:
		optlist, args = getopt.getopt (sys.argv[1:], 'S:U:D:P:b:e:u:')	
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
			PASSWORD = value
		elif parm == '-b':
			BLOCK_SIZE = string.atoi (value)
		elif parm == '-e':
			extract = value
		elif parm == '-u':
			update = value
			
	if BLOCK_SIZE > 200:
		print USAGE
		print 'Please use a block_size <= 200'
		sys.exit(-1)
	mgdlib.set_sqlLogin (USER, PASSWORD, SERVER, DATABASE)
	return ( extract, update )

def simpleSubstitute (old, new, s):
	# Purpose: substitute string "new" for string "old" (a regular
	#	expression) wherever "old" occurs in "s"
	# Returns: the string after substitutions
	# Assumes: nothing
	# Effects: nothing
	# Throws: nothing

	return regsub.gsub (old, new, s)


def convert (text):
	# Purpose: convert the string "text" from the old-style MLC notation
	#	to the new HTML-based notation.
	# Returns: the string after all conversion steps
	# Assumes: nothing
	# Effects: nothing
	# Throws: nothing

## jsb - The line below is necessary to let Sybase know that the quotes
## in a string are part of the string, rather than a string delimiter.
## You'll probably need to do something similar, as some of the MLC text
## records have quotes within them.

	text = simpleSubstitute ('"','""', text)	# for Sybase...
	return text


def get_keys (tbl):
	# Purpose: get a list of _Marker_keys from 'tbl'
	# Returns: see Purpose
	# Assumes: nothing
	# Effects: nothing
	# Throws: sybase.error if there's a problem with db access

	list = []
	res = mgdlib.sql ('select _Marker_key from %s' % tbl, 'auto')
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

	return mgdlib.sql ('''
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
	mgdlib.sql (cmds, 'auto')
	return
########################

def find_italics (s, start_pos = 0):

	# does a case-insensitive search to find the next occurrence of an
	# italicized or emphasized substring.  returns a tuple containing
	#	(start position, stop position, the full substring, the
	#		portion of the substring inside the HTML tags)

	start_i = '<I>'
	stop_i = '</I>'
	start_em = '<EM>'
	stop_em = '</EM>'


	upper_s = string.upper (s)
	i_pos = string.find (upper_s, start_i, start_pos)
	em_pos = string.find (upper_s, start_em, start_pos)


	match_str = ''
	start = None
	stop = None
	full_str = ''
	sub_str = ''
	tag_size = None

	if (i_pos == -1) and (em_pos == -1):
		return (start, stop, full_str, sub_str)

	if (i_pos >= 0) and ((em_pos == -1) or (i_pos < em_pos)):
		match_str = stop_i
		start = i_pos
		tag_size = 3
	else:
		match_str = stop_em
		start = em_pos
		tag_size = 4

	match_pos = string.find (upper_s, match_str, start)
	if match_pos == -1:
		return (None, stop, full_str, sub_str)
	stop = match_pos + len(match_str)

	full_str = s[start:stop]
	sub_str = full_str[tag_size:-(tag_size + 1)]
	return (start, stop, full_str, sub_str)

########################
def find_all (s):

	# returns a list containing info about all the italicized or
	# emphasized portions of 's'.  Each list item is a tuple containing
	#	(start position, stop position, full substring, substring
	#		inside the HTML tags)

	all = []
	(start, stop, full_str, sub_str) = find_italics (s)
	while (start is not None):
		all.append ( (start, stop, full_str, sub_str) )
		(start, stop, full_str, sub_str) = find_italics (s, stop)
	return all

########################

def write_to_file(list):

	# Purpose: write a list  to two files named:
	#		 'italic_allresult' : including <I> or <em>
	#	   	 'italic_result' : no <I> or <em>
	# Returns: nothing
	# Assumes: a list   
	# Effects: writes two files to the current directory
	# Throws : nothing
	
	# write tuples to a file ( 4 fields for each tuple)
	fd = open ('italic_allresult', 'w')
	for row in list:
		fd.write(str(row))
		fd.write('\n')
	fd.close()

	
	# get a distinct sublist of sub_str from the list of tuples
	sub_str_list =[]
	for item in list:
		if item[3] not in sub_str_list:
			sub_str_list.append(item[3])

	#write only the sub_str to a file
	fd = open ('italic_result', 'w')
	for row in sub_str_list:
		fd.write(row)
		fd.write('\n')
	fd.close()
########################

def remove_italics(s):

	# Purpose: remove <I> and <em> tags 
	# Returns: a new string with HTML italic tags removed
	# Assumes: a string   
	# Effects: nothing
	# Throws : HTML italic tags

	new_s = ''
	new_start = 0
	(start, stop, full_str, sub_str) = find_italics (s)
	
	while (start is not None):
		new_s = new_s + s[new_start:start] + sub_str
		new_start = stop
		(start, stop, full_str, sub_str) = find_italics (s, stop)
	new_s = new_s + s[new_start:]

	return new_s



def main ():
	# Purpose: main program
	# Returns: nothing
	# Assumes: nothing
	#	   users want to either extract HTML italc tags or remove them 
	# Effects: updates MLC text data (MLC_Text.description) and
	#	(MLC_Text_edit.description) in SERVER:DATABASE
	# Throws: nothing

	italic_list = []

	try:
		(ext, upd) = process_options ()
	except ValueError:
		print USAGE
		sys.exit (-1)

	if (ext == 'extract')  and  (upd == ''):
		for table in ('MLC_Text','MLC_Text_edit'):
			done = 0
			all_keys = get_keys (table)
			for key_list in chunk (all_keys, BLOCK_SIZE):
				record_list = get_block (key_list, table)
	    			for rec in record_list:  # find all italic tags
					rec_list = find_all(rec['description'])
					italic_list = italic_list + rec_list
				write_to_file(italic_list)
				done = done + len(record_list)
				s = '%s Saved: %s of %s in %s %s' % (20 * '-', done, 
				len (all_keys), table, 20 * '-')
				print s
				for record in record_list:
					print record['_Marker_key'],
				print
				print '-' * len(s)
				print

       	elif (ext == '')  and  (upd == 'update'):
		for table in ('MLC_Text','MLC_Text_edit'):
			done = 0
			all_keys = get_keys (table)
			for key_list in chunk (all_keys, BLOCK_SIZE):
				record_list = get_block (key_list, table)
				for rec in record_list:
					rec['description'] =\
						convert(remove_italics (rec['description']))
				save_block(record_list,table)
				done = done + len(record_list)
				s = '%s Saved: %s of %s in %s %s' % (20 * '-', done, 
					len (all_keys), table, 20 * '-')
				print s
				for record in record_list:
					print record['_Marker_key'],
				print
				print '-' * len(s)
				print

	else:
		print(' You can use either option "-e" or option "-u", but not both.\n')
		print USAGE
		sys.exit(-1) 
	return

if __name__ == '__main__':
	main ()
