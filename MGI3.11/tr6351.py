#!/usr/local/bin/python

import sys
import os
import string
import getopt
import db
import mgi_utils

#globals

TAB = '\t'		# tab
CRT = '\n'		# carriage return/newline

diagFile = ''		# diagnostic file descriptor
errorFile = ''		# error file descriptor

diagFileName = ''	# diagnostic file name
errorFileName = ''	# error file name
passwordFileName = ''	# password file name

# Purpose: displays correct usage of this program
# Returns: nothing
# Assumes: nothing
# Effects: exits with status of 1
# Throws: nothing
 
def showUsage():
    usage = 'usage: %s -S server\n' % sys.argv[0] + \
        '-D database\n' + \
        '-U user\n' + \
        '-P password file\n'

    exit(1, usage)
 
# Purpose: prints error message and exits
# Returns: nothing
# Assumes: nothing
# Effects: exits with exit status
# Throws: nothing

def exit(
    status,          # numeric exit status (integer)
    message = None   # exit message (string)
    ):

    if message is not None:
        sys.stderr.write('\n' + str(message) + '\n')
 
    try:
        diagFile.write('\n\nEnd Date/Time: %s\n' % (mgi_utils.date()))
        errorFile.write('\n\nEnd Date/Time: %s\n' % (mgi_utils.date()))
        diagFile.close()
        errorFile.close()
    except:
        pass

    db.useOneConnection(0)
    sys.exit(status)
 
# Purpose: process command line options
# Returns: nothing
# Assumes: nothing
# Effects: initializes global variables
#          calls showUsage() if usage error
#          exits if files cannot be opened
# Throws: nothing

def init():
    global diagFile, errorFile, errorFileName, diagFileName, passwordFileName
 
    try:
        optlist, args = getopt.getopt(sys.argv[1:], 'S:D:U:P:M:')
    except:
        showUsage()
 
    #
    # Set server, database, user, passwords depending on options specified
    #
 
    server = ''
    database = ''
    user = ''
    password = ''
 
    for opt in optlist:
        if opt[0] == '-S':
            server = opt[1]
        elif opt[0] == '-D':
            database = opt[1]
        elif opt[0] == '-U':
            user = opt[1]
        elif opt[0] == '-P':
            passwordFileName = opt[1]
        else:
            showUsage()

    # User must specify Server, Database, User and Password
    password = string.strip(open(passwordFileName, 'r').readline())
    if server == '' or database == '' or user == '' or password == '':
        showUsage()

    # Initialize db.py DBMS parameters
    db.set_sqlLogin(user, password, server, database)
    db.useOneConnection(1)
 
    diagFileName = sys.argv[0] + '.diagnostics'
    errorFileName = sys.argv[0] + '.error'

    try:
        diagFile = open(diagFileName, 'w')
    except:
        exit(1, 'Could not open file %s\n' % diagFileName)
		
    try:
        errorFile = open(errorFileName, 'w')
    except:
        exit(1, 'Could not open file %s\n' % errorFileName)
		
    # Log all SQL
    db.set_sqlLogFunction(db.sqlLogAll)

    # Set Log File Descriptor
    db.set_sqlLogFD(diagFile)

    diagFile.write('Start Date/Time: %s\n' % (mgi_utils.date()))
    diagFile.write('Server: %s\n' % (server))
    diagFile.write('Database: %s\n' % (database))
    diagFile.write('User: %s\n' % (user))

    errorFile.write('Start Date/Time: %s\n\n' % (mgi_utils.date()))

    return

#
# Main
#

init()

fp = open('promoter_cleanup_completed.txt', 'r')

for line in fp.readlines():
     tokens = string.split(line[:-1], '\t')
     accID = tokens[0]
     notes = tokens[2]

     results = db.sql('select _Object_key from ACC_Accession where accid = "%s"' % (accID), 'auto')
     for r in results:
	 key = r['_Object_key']

	 # delete promoter notes
	 db.sql('delete from ALL_Note where _NoteType_key = 3 and _Allele_key = %s' % (key), None)

	 # delete molecular notes
	 db.sql('delete from ALL_Note where _NoteType_key = 2 and _Allele_key = %s' % (key), None)

	 # add new molecular notes

         noteSeq = 1
	 cmds = []
      
         while len(notes) > 255:
	     cmds.append('insert into ALL_Note values(%s,2,%d,0,"%s",getdate(),getdate())' % (key, noteSeq, notes[:255]))
             newnotes = notes[255:]
             notes = newnotes
             noteSeq = noteSeq + 1

         if len(notes) > 0:
	     cmds.append('insert into ALL_Note values(%s,2,%d,0,"%s",getdate(),getdate())' % (key, noteSeq, notes[:255]))

	 db.sql(cmds, None)

fp.close()

db.sql('delete from ALL_NoteType where noteType = "Promoter"', None)

exit(0)

# $Log$
