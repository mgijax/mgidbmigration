#!/usr/local/bin/python

# convert old MLC to new HTML-based MLC

# Jon Beal

# assumptions:
#	0. old \< and \> tags will become &lt; and &gt;
#	1. old \beginpre and \endpre tags will become <PRE> and </PRE>
#	2. old \L{...} tags will become \L(...)
#	3. old <...> tags will become <SUP>...</SUP>
#	4. old >...< tags will become <SUB>...</SUB>
#	5. old {...} tags will become <I>...</I>
#	6. a newline followed by one or more spaces will become <P>
#	7. old (MIM xxxxxx) and (xxxxxx, OMIM) tags will become
#		\Link(xxxxxx, OMIM)

import sys
import regex
import regsub
import string
import getopt
import mgdlib

# ************ Global variables ************

NewLine = '\n'

re_beginpre = '\\\\beginpre'
re_endpre = '\\\\endpre'
re_paragraph = '%s +' % NewLine
re_locus = regex.compile ('\\\\L{\([^}]*\)}')	# group 1 = locus info
re_italics = regex.compile ('{\([^}]*\)}')	# group 1 = italicized info
re_omim_1 = regex.compile ('(MIM *\([0-9]+\))')
re_omim_2 = regex.compile ('(\([0-9]+\), *O?MIM)')

BeginPre = '<PRE>'
EndPre = '</PRE>'
BeginSubscript = '<SUB>'
EndSubscript = '</SUB>'
BeginSuperscript = '<SUP>'
EndSuperscript = '</SUP>'
Paragraph = '%s<P>' % NewLine
Locus = '\L(%s)'		# fill in locus info
Italics = '<I>%s</I>'		# fill in italics info
Omim_1 = '(MIM %s)'		# used to convert from re_omim_2 to re_omim_1
OmimLink = '(OMIM \Link(%s, OMIM))'	# the actual new link to OMIM

SERVER = 'MGD_DEV'		# database access info...
USER = 'mgd_public'
DATABASE = 'mgd_release'
PASSWORD = ''

BLOCK_SIZE = 50			# process how many MLC records in a batch?

USAGE = '''
%s [-S server][-D database][-U user][-P password][-b block_size]

Defaults:
	server =     "%s"
	database =   "%s"
	user =       "%s"
	password =   "%s"
	block_size = "%s"

The block_size is the number of MLC records to process in one batch.

''' % (sys.argv[0], SERVER, DATABASE, USER, PASSWORD, BLOCK_SIZE)

# ************ Functions ************


def simpleSubstitute (old, new, s):
	# Purpose: substitute string "new" for string "old" (a regular
	#	expression) wherever "old" occurs in "s"
	# Returns: the string after substitutions
	# Assumes: nothing
	# Effects: nothing
	# Throws: nothing

	return regsub.gsub (old, new, s)


def reSubstitute (
	re,	# a compiled regular expression which has one group
	new,	# a string with one %s included for substitution
	s	# the string to search
	):
	# Purpose: replace "re" with "new" wherever "re" occurs in "s",
	#	taking the data from "re.group(1)" and substituting it for
	#	"%s" in "s".
	# Returns: the string after substitutions
	# Assumes: nothing
	# Effects: nothing
	# Throws: nothing

	where = re.search (s)
	while (where != -1):
		all, portion = re.group (0,1)
		s = s[:(where)] + (new % portion) + s[(where + len(all)):]
		where = re.search (s, where + 1)
	return s


def doAngleBrackets (s):
	# Purpose: go through "s", and convert >...< and <...> pairs to HTML
	#	subscript and superscript notation, respectively.
	# Returns: the string "s" after substitutions
	# Assumes: any instances of \> and \< have already been converted to
	#	&gt; and &lt; respectively
	# Effects: nothing
	# Throws: nothing

	net = 0			# (count of <) - (count of >)
	t = ''
	for c in s:
		if c == '<':
			if net >= 0:
				t = t + BeginSuperscript
			else:
				t = t + EndSubscript
			net = net + 1
		elif c == '>':
			if net <= 0:
				t = t + BeginSubscript
			else:
				t = t + EndSuperscript
			net = net - 1
		else:
			t = t + c
	return t


def convert (text):
	# Purpose: convert the string "text" from the old-style MLC notation
	#	to the new HTML-based notation.
	# Returns: the string after all conversion steps
	# Assumes: nothing
	# Effects: nothing
	# Throws: nothing

	text = simpleSubstitute ('\\\\<', '&lt;', text)
	text = simpleSubstitute ('\\\\>', '&gt;', text)
	text = doAngleBrackets (text)
	text = simpleSubstitute (re_beginpre, BeginPre, text)
	text = simpleSubstitute (re_endpre, EndPre, text)
	text = simpleSubstitute (re_paragraph, Paragraph, text)
	text = reSubstitute (re_locus, Locus, text)
	text = reSubstitute (re_italics, Italics, text)
	text = reSubstitute (re_omim_2, Omim_1, text)
	text = reSubstitute (re_omim_1, OmimLink, text)
	text = simpleSubstitute ('"','""', text)	# for Sybase...
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
		optlist, args = getopt.getopt (sys.argv[1:], 'S:U:D:P:b:')	
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
	if BLOCK_SIZE > 200:
		print USAGE
		print 'Please use a block_size <= 200'
		sys.exit(-1)
	mgdlib.set_sqlLogin (USER, PASSWORD, SERVER, DATABASE)
	return


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
				rec['description'] = \
					convert (rec['description'])
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
