#!/usr/local/bin/python

# TR 148
# create bcp files for MLC_Marker tables
# convert MLC_Marker.tag from varchar to integer

import sys
import string
import getopt
import db

# ************ Global variables ************

SERVER=None
DATABASE=None

USAGE = '''
%s [-S server][-D database][-U user][-P password file][-F database]

Defaults:
	server =     "%s"
	database =   "%s"

''' % (sys.argv[0], SERVER, DATABASE)

# ************ Functions ************

def process_options ():
	# Purpose: process the command line options
	# Returns: nothing
	# Effects: updates global varibles SERVER, DATABASE
	# Throws: ValueError if the specified block size is not an integer

	global SERVER, DATABASE

	try:
		optlist, args = getopt.getopt (sys.argv[1:], 'S:D:')	
	except getopt.error:
		print USAGE
		sys.exit (-1)

	if len(args) > 0:
		print USAGE
		sys.exit (-1)

	for (parm, value) in optlist:
		if parm == '-S':
			SERVER = value
		elif parm == '-D':
			DATABASE = value
	db.set_sqlServer(SERVER)
	db.set_sqlDatabase(DATABASE)
	return


def loadMLCMarker():
	#
	# Create bcp files for the new MLC_Marker tables using MLC_Marker OLD tables.
	# MLC_Marker_Temp.tag is a varchar().  We want to group
	# all MLC_Marker records by _Marker_key and assign numeric tag values
	# (1..x) for each record.  When we hit a new _Marker_key, start the tag
	# values at 1 again.
	#

	for table in ('MLC_Marker_Temp', 'MLC_Marker_Edit_Temp'):
		bcpFile = open('%s.bcp' % (table), 'w')
		cmd = 'select _Marker_key, _Marker_key_2, ' + \
		      'cd = convert(varchar(20), creation_date, 101), ' + \
		      'md = convert(varchar(20), modification_date, 101) ' + \
		      'from %s order by _Marker_key' % (table)
		results = db.sql(cmd, 'auto')
		prevMarker = ''
		tag = 1
		for r in results:
			if prevMarker != r['_Marker_key']:
				tag = 1
			else:
				tag = tag + 1

			bcpFile.write('%d|%d|%d|%s|%s\n' % (r['_Marker_key'], tag, r['_Marker_key_2'], r['cd'], r['md']))
			prevMarker = r['_Marker_key']

		bcpFile.close()

def main ():
	# Purpose: main program
	# Returns: nothing
	# Assumes: nothing
	# Effects: creates bcp files
	# Throws: nothing

	try:
		process_options ()
	except ValueError:
		print USAGE
		sys.exit (-1)

	loadMLCMarker()
	return

if __name__ == '__main__':
	main ()
