#!/usr/local/bin/python

'''
#
# Purpose:
#
#	To load new user/role records into User/Role structures:
#
#	MGI_UserRole
#
# Side Effects:
#
#	None
#
# Input(s):
#
#	A tab-delimited file in the format:
#		field 1: Role Term
#		field 2: Task Term
#
# Parameters:
#	-S = database server
#	-D = database
#	-U = user
#	-P = password file
#	-M = mode (incremental, full, preview)
#	-I = input file of mapping data
#	-C = Created By
#
#	processing modes:
#		incremental - append the data to the existing Role
#
#		full - delete the data from the existing Role/Task
#
#		preview - perform all record verifications but do not load the data or
#		          make any changes to the database.  used for testing or to preview
#			  the load.
#
# Output:
#
#       1 BCP files:
#
#       MGI_UserRole.bcp               Role/Task records
#
#	Diagnostics file of all input parameters and SQL commands
#	Error file
#
# Processing:
#
# History:
#
# lec	02/10/2005
#	- TR 6343; created
#
'''

import sys
import os
import string
import getopt
import regsub
import db
import mgi_utils
import loadlib

#globals

DEBUG = 0		# set DEBUG to false unless preview mode is selected

inputFile = ''		# file descriptor
diagFile = ''		# file descriptor
errorFile = ''		# file descriptor

userroleFile = ''		# file descriptor

diagFileName = ''	# file name
errorFileName = ''	# file name
passwordFileName = ''	# file name

userroleFileName = ''	# file name
userroleTable = 'MGI_UserRole'

mode = ''		# processing mode

roleDict = {}		# dictionary of Roles
userDict = {}		# dictionary of Users

bcpdelim = "|"

roleKey = 0		# Role key
userKey = 0		# Task key
createdByKey = 0		# User Key

userroleKey = 1000

loaddate = loadlib.loaddate	# current date

def showUsage():
	'''
	# requires:
	#
	# effects:
	# Displays the correct usage of this program and exits
	# with status of 1.
	#
	# returns:
	'''
 
	usage = 'usage: %s -S server\n' % sys.argv[0] + \
		'-D database\n' + \
		'-U user\n' + \
		'-P password file\n' + \
		'-M mode\n' + \
		'-I input file\n' + \
		'-C Created By\n'
	exit(1, usage)
 
def exit(status, message = None):
	'''
	# requires: status, the numeric exit status (integer)
	#           message (string)
	#
	# effects:
	# Print message to stderr and exits
	#
	# returns:
	#
	'''
 
	if message is not None:
		sys.stderr.write('\n' + str(message) + '\n')
 
	try:
		inputFile.close()
		diagFile.write('\n\nEnd Date/Time: %s\n' % (mgi_utils.date()))
		errorFile.write('\n\nEnd Date/Time: %s\n' % (mgi_utils.date()))
		diagFile.close()
		errorFile.close()
	except:
		pass

	db.useOneConnection()
	sys.exit(status)
 
def init():
	'''
	# requires: 
	#
	# effects: 
	# 1. Processes command line options
	# 2. Initializes local DBMS parameters
	# 3. Initializes global file descriptors/file names
	# 4. Initializes global keys
	#
	# returns:
	#
	'''
 
	global inputFile, diagFile, errorFile, errorFileName, diagFileName, passwordFileName
	global userroleFile
	global userroleFileName
	global mode, createdByKey
	global roleDict, userDict
 
	try:
		optlist, args = getopt.getopt(sys.argv[1:], 'S:D:U:P:M:I:C:')
	except:
		showUsage()
 
	#
	# Set server, database, user, passwords depending on options
	# specified by user.
	#
 
	server = ''
	database = ''
	user = ''
	password = ''
	inputFileName = ''
	createdBy = ''
 
	for opt in optlist:
                if opt[0] == '-S':
                        server = opt[1]
                elif opt[0] == '-D':
                        database = opt[1]
                elif opt[0] == '-U':
                        user = opt[1]
                elif opt[0] == '-P':
			passwordFileName = opt[1]
                elif opt[0] == '-M':
                        mode = opt[1]
                elif opt[0] == '-I':
                        inputFileName = opt[1]
                elif opt[0] == '-C':
                        createdBy = opt[1]
                else:
                        showUsage()

	# User must specify Server, Database, User and Password
	password = string.strip(open(passwordFileName, 'r').readline())
	if server == '' or \
	   database == '' or \
	   user == '' or \
	   password == '' or \
	   mode == '' or \
	   inputFileName == '' or \
	   createdBy == '':
		showUsage()

	# Initialize db.py DBMS parameters
	db.set_sqlLogin(user, password, server, database)
	db.useOneConnection(1)
 
	fdate = mgi_utils.date('%m%d%Y')	# current date
	head, tail = os.path.split(inputFileName) 
	diagFileName = tail + '.' + fdate + '.diagnostics'
	errorFileName = tail + '.' + fdate + '.error'
	userroleFileName = tail + '.' + fdate + '.' + userroleTable + '.bcp'

	try:
		inputFile = open(inputFileName, 'r')
	except:
		exit(1, 'Could not open file %s\n' % inputFileName)
		
	try:
		diagFile = open(diagFileName, 'w')
	except:
		exit(1, 'Could not open file %s\n' % diagFileName)
		
	try:
		errorFile = open(errorFileName, 'w')
	except:
		exit(1, 'Could not open file %s\n' % errorFileName)
		
	try:
		userroleFile = open(userroleFileName, 'w')
	except:
		exit(1, 'Could not open file %s\n' % userroleFileName)
		
	# Log all SQL
	db.set_sqlLogFunction(db.sqlLogAll)

	# Set Log File Descriptor
	db.set_sqlLogFD(diagFile)

	diagFile.write('Start Date/Time: %s\n' % (mgi_utils.date()))
	diagFile.write('Server: %s\n' % (server))
	diagFile.write('Database: %s\n' % (database))
	diagFile.write('User: %s\n' % (user))
	diagFile.write('Input File: %s\n' % (inputFileName))

	errorFile.write('Start Date/Time: %s\n\n' % (mgi_utils.date()))

	createdByKey = loadlib.verifyUser(createdBy, 0, errorFile)

        results = db.sql('select t._Term_key, t.term from VOC_Term t, VOC_Vocab v ' + \
		'where v.name = "User Role" and v._Vocab_key = t._Vocab_key', 'auto')
        for r in results:
	    roleDict[r['term']] = r['_Term_key']

        results = db.sql('select _User_key, login from MGI_User', 'auto')
        for r in results:
	    userDict[r['login']] = r['_User_key']

def verifyMode():
	'''
	# requires:
	#
	# effects:
	#	Verifies the processing mode is valid.  If it is not valid,
	#	the program is aborted.
	#	Sets globals based on processing mode.
	#	Deletes data based on processing mode.
	#
	# returns:
	#	nothing
	#
	'''

	global DEBUG

	if mode == 'preview':
		DEBUG = 1
	elif mode not in ['incremental', 'full']:
		exit(1, 'Invalid Processing Mode:  %s\n' % (mode))

        if mode == 'full':
	    db.sql('truncate table %s' % userroleTable, None)

def processFile():
	'''
	# requires:
	#
	# effects:
	#	Reads input file
	#	Verifies and Processes each line in the input file
	#
	# returns:
	#	nothing
	#
	'''

	results = db.sql('select max(_UserRole_key) from MGI_UserRole', 'auto')
	if results[0][''] is None:
	    userroleKey = 1000
        else:
	    userroleKey = results[0]['']

	lineNum = 0

	# For each line in the input file

	for line in inputFile.readlines():

		error = 0
		lineNum = lineNum + 1

		# Split the line into tokens
		tokens = string.split(line[:-1], '\t')

		try:
			role = tokens[0]
			users = tokens[1]
		except:
			exit(1, 'Invalid Line (%d): %s\n' % (lineNum, line))

		roleKey = roleDict[role]

		for u in string.split(users, ', '):
		    userKey = userDict[u]

		    if roleKey == 0 or userKey == 0:
			    # set error flag to true
			    error = 1

		    # if errors, continue to next record
		    if error:
			    continue

		    # if no errors, process

		    bcpWrite(userroleFile, [userroleKey, roleKey, userKey, createdByKey, createdByKey, loaddate, loaddate])
		    userroleKey = userroleKey + 1

#	end of "for line in inputFile.readlines():"


def bcpWrite(fp, values):
	'''
	#
	# requires:
	#	fp; file pointer of bcp file
	#	values; list of values
	#
	# effects:
	#	converts each value item to a string and writes out the values
	#	to the bcpFile using the appropriate delimiter
	#
	# returns:
	#	nothing
	#
	'''

	# convert all members of values to strings
	strvalues = []
	for v in values:
		strvalues.append(str(v))

	fp.write('%s\n' % (string.join(strvalues, bcpdelim)))

def bcpFiles():
	'''
	# requires:
	#
	# effects:
	#	BCPs the data into the database
	#
	# returns:
	#	nothing
	#
	'''

	userroleFile.close()

	cmd = 'cat %s | bcp %s..%s in %s -c -t\"%s" -S%s -U%s' \
		% (passwordFileName, db.get_sqlDatabase(), \
	   	userroleTable, userroleFileName, bcpdelim, db.get_sqlServer(), db.get_sqlUser())

	diagFile.write('%s\n' % cmd)

	if DEBUG:
		return

	os.system(cmd)

#
# Main
#

init()
verifyMode()
processFile()
bcpFiles()
exit(0)

