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

results = db.sql('select _SynonymType_key from MGI_SynonymType where synonymType = "synonym"', 'auto')
for r in results:
    synTypeKey = r['_SynonymType_key']

results = db.sql('select n = max(_Synonym_key) + 1 from MGI_Synonym', 'auto')
for r in results:
    synKey = r['n']

fp = open('synonym.txt', 'r')

for line in fp.readlines():
     tokens = string.split(line[:-1], '\t')

     strain = tokens[0]
     synonym = tokens[1]

     results = db.sql('select _Strain_key from PRB_Strain where strain = "%s"' % (strain), 'auto')
     for r in results:
	 strainKey = r['_Strain_key']

     cmd = 'insert into MGI_Synonym values(%d,%d,10,%d,null,"%s",1086,1086,getdate(),getdate())' % (synKey,strainKey,synTypeKey,synonym)
     db.sql(cmd, None)
     synKey = synKey + 1

cmds = []
cmds.append('select s1._Synonym_key into #todelete ' + \
	'from MGI_Synonym s1 , MGI_Synonym s2 ' + \
	'where s1._MGIType_key = 10 and s1._SynonymType_key = 1001 ' + \
	'and s2._MGIType_key = 10 and s2._SynonymType_key = 1000 ' + \
	'and s1._Object_key = s2._Object_key ' + \
	'and s1.synonym = s2.synonym')

cmds.append('delete MGI_Synonym from #todelete d, MGI_Synonym s where d._Synonym_key = s._Synonym_key')
db.sql(cmds, None)

fp.close()

exit(0)
