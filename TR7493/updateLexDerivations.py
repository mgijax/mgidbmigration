#!/usr/local/bin/python

# Program:
# Purpose:
# Requirements: See TR9681
# System Requirements Satisfied by This Program:
#       Usage:
#       Uses:
#       Envvars:
#		1. MGD_DBPASSWORDFILE
#		2. MGD_DBNAME
#		3. MGD_DBSERVER
#		4. MGD_DBUSER
#       Inputs:
#	    1. /mgi/all/wts_projects/9600/9681/Lexicon_Lex2.txt
#       Outputs:
#           1. Updates Lexicon MCLs with Lex1 or Lex2 derivations
#
#       Exit Codes:
#       Other System Requirements:
# Assumes:
# Implementation:
#	For each Lexicon MCL *present in* Lexicon_Lex2.txt:
#	    Update its derivation 
#		to "Lexicon Genetics Gene Trap Library Lex2 129S5/SvEvBrd"
#	For each Lexicon MCL *NOT in" Lexicon_Lex2.txt:
#               to "Lexicon Genetics Gene Trap Library Lex1 129S5/SvEvBrd"
#       Modules:

import sys
import db
import os
import string
import time

#
# global variables
#

# for time stamping
STARTTIME = time.time()

# derivation key for Lex1/Lex2
lex1Key = -1
lex2Key = -2

# update statement to update a sequence to ACTIVE
updateStatement = '''UPDATE ALL_CellLine SET _Derivation_key = %d
            WHERE cellLine = "%s"'''

# full path to file of lex2 cellLine IDs
lex2FilePath = '/mgi/all/wts_projects/9600/9681/Lexicon_Lex2.txt'
print "lex2FilePath: %s" % lex2FilePath

# Lex 1 derivation name
lex1Deriv = 'Lexicon Genetics Gene Trap Library Lex-1 129S5/SvEvBrd'

# Lex 2 derivation name
lex2Deriv = 'Lexicon Genetics Gene Trap Library Lex-2 129S5/SvEvBrd'

# Lex2 MCL IDs
lex2MCLList = []

# Purpose:
# Return:
# Assumes:
# Effects:
# Throws:
# Notes: (opt)
# Example: (opt)

def bailout (msg):
    print msg
    sys.exit(1)

# Purpose:
# Return:
# Assumes:
# Effects:
# Throws:
# Notes: (opt)
# Example: (opt)

def preprocess ():
    global lex1, lex2, lex2MCLList
    
    # make sure the input file exists
    if not os.path.exists(lex2FilePath):
            bailout("Cannot find Lex 2 file: %s" % lex2FilePath)

    # query to get Lex1 and Lex2 derivation keys
    derivQuery = '''SELECT _Derivation_key
	        FROM ALL_CellLine_Derivation
       	 	WHERE name = "%s"'''

    # get Lex1 derivation key
    results = db.sql(derivQuery % lex1Deriv, 'auto')
    lex1Key = results[0]['_Derivation_key']
    print "Lex1 Derivation: %s Lex1 Key %s" %(lex1Deriv, lex1Key)
    if lex1Key == None:
	bailout("Cannot resolve Derivation to key: %s" % lex1Deriv)

    # get Lex2 derivation key
    results = db.sql(derivQuery % lex2Deriv, 'auto')
    lex2Key = results[0]['_Derivation_key']
    print "Lex2 Derivation: %s Lex2 Key %s" %(lex2Deriv, lex2Key)
    if lex2Key == None:    
        bailout("Cannot resolve Derivation to key: %s" % lex2Deriv)
 
    #  put Lex2 MCLs from file into a list
    inFile = open(lex2FilePath, 'r')
    for line in inFile.readlines():
        lex2MCLList.append(string.strip(line) )
    print "Input file has %s records" % len(lex2MCLList)
    inFile.close()
		
# Purpose: 
# Return:
# Assumes:
# Effects:
# Throws:
# Notes: (opt)
# Example: (opt)

def process ():

    cmds = []
    
    #  get all Lexicon MCLs from the database
    results = db.sql('''SELECT accID, _Object_key as _CellLine_key 
	FROM ACC_Accession 
	WHERE _LogicalDB_key = 96 
	AND _MGIType_key = 28 
	AND preferred = 1
	ORDER BY accID''', 'auto')

    # update each Lex MCL in database to Lex1 or Lex2
    for r in results:
        mclID = r['accID']
        mclKey = r['_CellLine_key']

	if mclID in lex2MCLList:
	    cmds.append(updateStatement % (lex2Key, mclKey))
	    print "UPDATE: %s to Lex2" % mclID
	else:
	    cmds.append(updateStatement % (lex1Key, mclKey))
	    print "UPDATE: %s to Lex1" % mclID

    return cmds

# Purpose:
# Return:
# Assumes:
# Effects:
# Throws:
# Notes: (opt)
# Example: (opt)

def updateDatabase (cmds):
    dbServer = os.environ['MGD_DBSERVER']
    dbName = os.environ['MGD_DBNAME']
    dbUser = os.environ['MGD_DBUSER']
    dbPasswordFile = os.environ['MGD_DBPASSWORDFILE']
    dbPassword = string.strip(open(dbPasswordFile,'r').readline())
    db.set_sqlLogin(dbUser, dbPassword, dbServer, dbName)

    # process in batches of 100
    total = len(cmds)

    try:
	    db.useOneConnection(1)
	    while cmds:
		    print 'Current running time (secs): %s' % (time.time() - STARTTIME)
		    db.sql (cmds[:100], 'auto')
		    cmds = cmds[100:]
	    db.useOneConnection(0)
    except:
	    bailout ('Failed during database updates')

    print 'Processed %d Lex1/Lex2 updates' % total
    print 'Total running time (secs): %s' % (time.time() - STARTTIME)
    return

#
# Main
#

print "Loading Lex2 MCL ID lookup"
preprocess ()

print "Creating update commands"
cmds = process ()

print "Updating database"
print "Total updates: %s " % len(cmds)
#updateDatabase (cmds)

