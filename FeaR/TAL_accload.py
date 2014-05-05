#!/usr/local/bin/python

#
#	To load Accession IDs  recreated TAL alleles
#
# Inputs:
#
#	file of recreated allele cell lines 
#
# Outputs:
#
#       BCP files:
#
#       ACC_Accession.bcp               Accession records
#
#       Diagnostics file of all input parameters and SQL commands
#       Error file
#
# History
#
# 05/01/2014	sc
#	- TR
#

import sys
import os
import string
import accessionlib
import db
import mgi_utils
import loadlib

#globals

#
# from configuration file
#
user = os.environ['MGD_DBUSER']
passwordFileName = os.environ['MGD_DBPASSWORDFILE']

#DEBUG = 0		# if 0, not in debug mode
DEBUG = 1		# if 0, not in debug mode
TAB = '\t'		# tab
CRT = '\n'		# carriage return/newline

bcpon = 1		# can the bcp files be bcp-ed into the database?  default is yes.

diagFile = ''		# diagnostic file descriptor
errorFile = ''		# error file descriptor
accFile = ''            # file descriptor
accTable = 'ACC_Accession'
accFileName = accTable + '.bcp'

diagFileName = ''	# diagnostic file name
errorFileName = ''	# error file name

accKey = 0              # ACC_Accession._Accession_key
mgiKey = 0              # ACC_AccessionMax.maxNumericPart

mgiTypeKey = 11		# ALL_Allele
mgiPrefix = "MGI:"

loaddate = loadlib.loaddate

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
 
# Purpose: open bcp, diagnostic files and connection to db
# Returns: nothing
# Assumes: nothing
# Effects: initializes global variables
#          exits if files cannot be opened
# Throws: nothing

def init():
    global diagFile, errorFile, errorFileName, diagFileName
    global accFile
 
    db.useOneConnection(1)
    db.set_sqlUser(user)
    db.set_sqlPasswordFromFile(passwordFileName)
 
    diagFileName = 'accload.diagnostics'
    errorFileName = 'accload.error'

    try:
        diagFile = open(diagFileName, 'w')
    except:
        exit(1, 'Could not open file %s\n' % diagFileName)
		
    try:
        errorFile = open(errorFileName, 'w')
    except:
        exit(1, 'Could not open file %s\n' % errorFileName)
		
    try:
        accFile = open(accFileName, 'w')
    except:
        exit(1, 'Could not open file %s\n' % accFileName)

    # Log all SQL
    db.set_sqlLogFunction(db.sqlLogAll)

    # Set Log File Descriptor
    db.set_sqlLogFD(diagFile)

    diagFile.write('Start Date/Time: %s\n' % (mgi_utils.date()))
    diagFile.write('Server: %s\n' % (db.get_sqlServer()))
    diagFile.write('Database: %s\n' % (db.get_sqlDatabase()))

    errorFile.write('Start Date/Time: %s\n\n' % (mgi_utils.date()))

    return

# Purpose:  sets global primary key variables
# Returns:  nothing
# Assumes:  nothing
# Effects:  sets global primary key variables
# Throws:   nothing

def setPrimaryKeys():

    global accKey, mgiKey

    results = db.sql('select maxKey = max(_Accession_key) + 1 from ACC_Accession', 'auto')
    accKey = results[0]['maxKey']

    results = db.sql('select maxKey = maxNumericPart + 1 from ACC_AccessionMax ' + \
        'where prefixPart = "%s"' % (mgiPrefix), 'auto')
    mgiKey = results[0]['maxKey']

# Purpose:  BCPs the data into the database
# Returns:  nothing
# Assumes:  nothing
# Effects:  BCPs the data into the database
# Throws:   nothing

def bcpFiles():

    bcpdelim = "|"

    if DEBUG or not bcpon:
        return

    accFile.close()

    bcpI = 'cat %s | bcp %s..' % (passwordFileName, db.get_sqlDatabase())
    bcpII = '-c -t\"|" -S%s -U%s' % (db.get_sqlServer(), db.get_sqlUser())

    bcp1 = '%s%s in %s %s' % (bcpI, accTable, accFileName, bcpII)

    for bcpCmd in [bcp1]:
	diagFile.write('%s\n' % bcpCmd)
	os.system(bcpCmd)

    return

# Purpose:  processes data
# Returns:  nothing
# Assumes:  nothing
# Effects:  verifies and processes each line in the input file
# Throws:   nothing

def processFile():

    global accKey, mgiKey

    createdByKey = 1001
    fp = open('TAL_Old_Ids.txt', 'r')

    row = 0
    for line in fp.readlines():
        error = 0

	(mgiID, preferred, cellline) = map(string.strip, string.split(line, '\t') )
        results = db.sql('''select ac._Allele_key from 
	    	ALL_Allele_CellLine ac, ALL_CellLine c
		where c.cellline = "%s"
		and c._CellLine_key = ac._MutantCellLine_key''' % cellline, 'auto')
	alleleKey = results[0]['_Allele_key']

	# update existing MGI ID to non-preferred
        db.sql('''update ACC_Accession 
		set preferred = 0
		where _MGIType_key = 11
		and preferred = 1
		and _Object_key = %s
		and prefixPart = "MGI:" ''' % alleleKey, None)

	# Add new preferred ID and non-preferred where dups
        # MGI Accession ID for the allelearker
        accFile.write('%s|%s%s|%s|%s|1|%s|%s|0|%s|%s|%s|%s|%s\n' \
            % (accKey, mgiPrefix, mgiKey, mgiPrefix, mgiKey, alleleKey, preferred, mgiTypeKey, \
	       createdByKey, createdByKey, loaddate, loaddate))
        accKey = accKey + 1
        mgiKey = mgiKey + 1

	row = row + 1

    #
    # Update the AccessionMax value
    #

    if not DEBUG:
        db.sql('exec ACC_setMax %d' % (row), None)

#
# Main
#

init()
setPrimaryKeys()
processFile()
bcpFiles()
exit(0)

