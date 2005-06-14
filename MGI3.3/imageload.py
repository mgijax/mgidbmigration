#!/usr/local/bin/python

#
# Program: imageload.py
#
# Original Author: Lori Corbani
#
# Purpose:
#
#	To load new Images into IMG Structures
#	Assumes that each Image record has a non-null PIX ID
#
#	IMG_Image
#	IMG_ImagePane
#	MGI_Note
#	MGI_NoteChunk
#	ACC_Accession
#
# Requirements Satisfied by This Program:
#
# Usage:
#	program.py
#	-S = database server
#	-D = database
#	-U = user
#	-P = password file
#	-M = mode
#
# Envvars:
#
# Inputs:
#
#	Fields 1-5 are required
#
#       Image file, a tab-delimited file in the format:
#		field 1: Image Type (full size or thumbnail)
#		field 2: Reference (J:####)
#		field 3: X Dimension
#		field 4: Y Dimension
#		field 5: PIX ID (PIX:#####)
#		field 6: Related Image PIX ID (PIX:####)
#               field 7: Figure Label
#               field 8: Copyright Note
#               field 9: Caption
#		field 10: |-delimited list of Panes (full size only)
#		field 11: |-delimited list of MGI objects to associate to first Image Pane
#
# Outputs:
#
#       BCP files:
#
#       IMG_Image.bcp			master Image records
#	IMG_ImagePane.bcp		Image Pane records
#	MGI_Note.bcp			Caption records
#	MGI_NoteChunk.bcp		Caption records
#       ACC_Accession.bcp               Accession records
#
#       Diagnostics file of all input parameters and SQL commands
#       Error file
#
# Exit Codes:
#
# Assumes:
#
#	That no one else is adding records to the database.
#
# Bugs:
#
# Implementation:
#

import sys
import os
import string
import getopt
import db
import mgi_utils
import accessionlib
import loadlib

#globals

DEBUG = 0		# if 0, not in debug mode
TAB = '\t'		# tab
CRT = '\n'		# carriage return/newline
bcpdelim = TAB		# bcp file delimiter

bcpon = 1		# can the bcp files be bcp-ed into the database?  default is yes.

datadir = os.environ['IMGLOADDATADIR']	# directory which contains the data files

diagFile = ''		# diagnostic file descriptor
errorFile = ''		# error file descriptor

# input files

inImageFile1 = ''         # file descriptor
inImageFile2 = ''         # file descriptor

inImageFileName = datadir + '/image.txt'

# output files

outImageFile = ''	# file descriptor
outNoteFile = ''	# file descriptor
outPaneFile = ''	# file descriptor
outAccFile = ''         # file descriptor
outAssocFile = ''       # file descriptor

imageTable = 'IMG_Image'
noteTable = 'MGI_Note'
noteChunkTable = 'MGI_NoteChunk'
paneTable = 'IMG_ImagePane'
accTable = 'ACC_Accession'
assocTable = 'IMG_ImagePane_Assoc'

outImageFileName = datadir + '/' + imageTable + '.bcp'
outNoteFileName = datadir + '/' + noteTable + '.bcp'
outNoteChunkFileName = datadir + '/' + noteChunkTable + '.bcp'
outPaneFileName = datadir + '/' + paneTable + '.bcp'
outAccFileName = datadir + '/' + accTable + '.bcp'
outAssocFileName = datadir + '/' + assocTable + '.bcp'

diagFileName = ''	# diagnostic file name
errorFileName = ''	# error file name
passwordFileName = ''	# password file name

mode = ''		# processing mode (load, preview)

createdBy = os.environ['CREATEDBY']

# primary keys

imageKey = 0            # IMG_Image._Image_key
paneKey = 0		# IMG_ImagePane._ImagePane_key
noteKey = 0		# MGI_Note._Note_key
accKey = 0              # ACC_Accession._Accession_key
mgiKey = 0              # ACC_AccessionMax.maxNumericPart
assocKey = 0		# IMG_ImagePane_Assoc._Assoc_key
createdByKey = ''

# accession constants

imageMgiTypeKey = '9'	  # Image
alleleMgiTypeKey = '11'	  # Allele
genotypeMgiTypeKey = '12' # Genotype
imageNoteTypeKey = '1023' # Image Note Type for Caption
mgiPrefix = "MGI:"	  # Prefix for MGI accession ID
accLogicalDBKey = '1'	  # Logical DB Key for MGI accession ID
accPrivate = '0'	  # Private status for MGI accession ID (false)
accPreferred = '1'	  # Preferred status MGI accession ID (true)
pixPrefix = 'PIX:'	  # Prefix for PIX
pixLogicalDBKey = '19'	  # Logical DB Key for PIX ID
pixPrivate = '1'	  # Private status for PIX ID (true)

# dictionaries to cache data for quicker lookup

imgTypeDict = {}
alleleDict = {}
genotypeDict = {}

loaddate = loadlib.loaddate

# Purpose: displays correct usage of this program
# Returns: nothing
# Assumes: nothing
# Effects: exits with status of 1
# Throws: nothing
 
def showUsage():
    usage = 'usage: %s -S server\n' % sys.argv[0] + \
        '-D database\n' + \
        '-U user\n' + \
        '-P password file\n' + \
        '-M mode\n'

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
#          exits if files cassoc be opened
# Throws: nothing

def init():
    global diagFile, errorFile, inputFile, errorFileName, diagFileName, passwordFileName
    global mode, createdByKey
    global outImageFile, outNoteFile, outNoteChunkFile, outPaneFile, outAccFile, outAssocFile
    global inImageFile1, inImageFile2
    global alleleDict, genotypeDict
 
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
        elif opt[0] == '-M':
            mode = opt[1]
        else:
            showUsage()

    # User must specify Server, Database, User and Password
    password = string.strip(open(passwordFileName, 'r').readline())
    if server == '' or database == '' or user == '' or password == '' \
	or mode == '':
        showUsage()

    # Initialize db.py DBMS parameters
    db.set_sqlLogin(user, password, server, database)
    db.useOneConnection(1)
 
    fdate = mgi_utils.date('%m%d%Y')	# current date
    diagFileName = sys.argv[0] + '.' + fdate + '.diagnostics'
    errorFileName = sys.argv[0] + '.' + fdate + '.error'

    try:
        diagFile = open(diagFileName, 'w')
    except:
        exit(1, 'Could not open file %s\n' % diagFileName)
		
    try:
        errorFile = open(errorFileName, 'w')
    except:
        exit(1, 'Could not open file %s\n' % errorFileName)
		
    # Input Files

    try:
        inImageFile1 = open(inImageFileName, 'r')
        inImageFile2 = open(inImageFileName, 'r')
    except:
        exit(1, 'Could not open file %s\n' % inImageFileName)

    # Output Files

    try:
        outImageFile = open(outImageFileName, 'w')
    except:
        exit(1, 'Could not open file %s\n' % outImageFileName)

    try:
        outNoteFile = open(outNoteFileName, 'w')
    except:
        exit(1, 'Could not open file %s\n' % outNoteFileName)

    try:
        outNoteChunkFile = open(outNoteChunkFileName, 'w')
    except:
        exit(1, 'Could not open file %s\n' % outNoteChunkFileName)

    try:
        outPaneFile = open(outPaneFileName, 'w')
    except:
        exit(1, 'Could not open file %s\n' % outPaneFileName)

    try:
        outAccFile = open(outAccFileName, 'w')
    except:
        exit(1, 'Could not open file %s\n' % outAccFileName)

    try:
        outAssocFile = open(outAssocFileName, 'w')
    except:
        exit(1, 'Could not open file %s\n' % outAssocFileName)

    # Log all SQL
    db.set_sqlLogFunction(db.sqlLogAll)

    # Set Log File Descriptor
    db.set_sqlLogFD(diagFile)

    diagFile.write('Start Date/Time: %s\n' % (mgi_utils.date()))
    diagFile.write('Server: %s\n' % (server))
    diagFile.write('Database: %s\n' % (database))
    diagFile.write('User: %s\n' % (user))

    errorFile.write('Start Date/Time: %s\n\n' % (mgi_utils.date()))

    createdByKey = loadlib.verifyUser(createdBy, 0, errorFile)

    results = db.sql('select _Object_key, accID from ACC_Accession where _MGIType_key = %s ' % (alleleMgiTypeKey) + \
	'and _LogicalDB_key = 1 and prefixPart = "MGI:" and preferred = 1', 'auto')
    for r in results:
	alleleDict[r['accID']] = r['_Object_key']

    results = db.sql('select _Object_key, accID from ACC_Accession where _MGIType_key = %s ' % (genotypeMgiTypeKey) + \
	'and _LogicalDB_key = 1 and prefixPart = "MGI:" and preferred = 1', 'auto')
    for r in results:
	genotypeDict[r['accID']] = r['_Object_key']

    return

# Purpose: verify processing mode
# Returns: nothing
# Assumes: nothing
# Effects: if the processing mode is not valid, exits.
#	   else, sets global variables
# Throws:  nothing

def verifyMode():

    global DEBUG

    if mode == 'preview':
        DEBUG = 1
        bcpon = 0
    elif mode != 'load':
        exit(1, 'Invalid Processing Mode:  %s\n' % (mode))

# Purpose:  verify Image Type
# Returns:  Image Type key if valid, else 0
# Assumes:  nothing
# Effects:  verifies that the Image Type exists in the imgtype dictionary
#	writes to the error file if the Image Type is invalid
# Throws:  nothing

def verifyImgType(
    imgType, 	# Image Type value (string)
    lineNum,	# line number (integer)
    errorFile	   # error file (file descriptor)
    ):

    global imgTypeDict

    imgTypeKey = 0

    if len(imgTypeDict) == 0:
	results = db.sql('select _Term_key, term from VOC_Term_IMGType_View', 'auto')
	for r in results:
	    imgTypeDict[r['term']] = r['_Term_key']

    if imgTypeDict.has_key(imgType):
        imgTypeKey = imgTypeDict[imgType]
    else:
	if errorFile != None:
            errorFile.write('Invalid Image Type (%d): %s\n' % (lineNum, imgType))

    return imgeTypeKey

# Purpose:  sets global primary key variables
# Returns:  nothing
# Assumes:  nothing
# Effects:  sets global primary key variables
# Throws:   nothing

def setPrimaryKeys():

    global imageKey, paneKey, accKey, mgiKey, noteKey, assocKey

    results = db.sql('select maxKey = max(_Image_key) + 1 from IMG_Image', 'auto')
    imageKey = results[0]['maxKey']

    results = db.sql('select maxKey = max(_ImagePane_key) + 1 from IMG_ImagePane', 'auto')
    paneKey = results[0]['maxKey']

    results = db.sql('select maxKey = max(_Assoc_key) + 1 from IMG_ImagePane_Assoc', 'auto')
    assocKey = results[0]['maxKey']

    results = db.sql('select maxKey = max(_Note_key) + 1 from MGI_Note', 'auto')
    noteKey = results[0]['maxKey']

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

def bcpFiles(
   recordsProcessed	# number of records processed (integer)
   ):

    if DEBUG or not bcpon:
        return

    outImageFile.close()
    outNoteFile.close()
    outNoteChunkFile.close()
    outPaneFile.close()
    outAccFile.close()
    outAssocFile.close()

    bcpI = 'cat %s | bcp %s..' % (passwordFileName, db.get_sqlDatabase())
    bcpII = '-c -t\"%s' % (bcpdelim) + '" -S%s -U%s' % (db.get_sqlServer(), db.get_sqlUser())

    bcp1 = '%s%s in %s %s' % (bcpI, imageTable, outImageFileName, bcpII)
    bcp2 = '%s%s in %s %s' % (bcpI, noteTable, outNoteFileName, bcpII)
    bcp3 = '%s%s in %s %s' % (bcpI, noteChunkTable, outNoteChunkFileName, bcpII)
    bcp4 = '%s%s in %s %s' % (bcpI, paneTable, outPaneFileName, bcpII)
    bcp5 = '%s%s in %s %s' % (bcpI, accTable, outAccFileName, bcpII)
    bcp6 = '%s%s in %s %s' % (bcpI, accTable, outAssocFileName, bcpII)

    for bcpCmd in [bcp1, bcp2, bcp3, bcp4, bcp5, bcp6]:
	diagFile.write('%s\n' % bcpCmd)
	os.system(bcpCmd)

    # update the max Accession ID value
    db.sql('exec ACC_setMax %d' % (recordsProcessed), None)

    # update statistics
    db.sql('update statistics %s' % (imageTable), None)
    db.sql('update statistics %s' % (noteTable), None)
    db.sql('update statistics %s' % (noteChunkTable), None)
    db.sql('update statistics %s' % (paneTable), None)
    db.sql('update statistics %s' % (assocTable), None)

    return

# Purpose:  processes image data
# Returns:  nothing
# Assumes:  nothing
# Effects:  verifies and processes each line in the input file
# Throws:   nothing

def processImageFile():

    global imageKey, accKey, mgiKey, paneKey, noteKey

    #
    # assign Image keys for each Pix ID
    #

    pixImageKey = {}
    for line in inImageFile1.readlines():
        tokens = string.split(line[:-1], '\t')
	pixID = tokens[4]
	pixImageKey[pixID] = imageKey
	imageKey = imageKey + 1
    inImageFile1.close()

    # For each line in the input file

    lineNum = 0
    for line in inImageFile2.readlines():

        error = 0
        lineNum = lineNum + 1

        # Split the line into tokens
        tokens = string.split(line[:-1], '\t')

        try:
	    imageType = tokens[0]
	    jnum = tokens[1]
	    xdim = tokens[2]
	    ydim = tokens[3]
	    pixID = tokens[4]
	    relatedpixID = tokens[5]
	    figureLabel = tokens[6]
	    copyrightNote = tokens[7]
	    caption = tokens[8]
	    panes = string.split(tokens[9], '|')
	    assocations = string.split(tokens[10], '|')
        except:
            exit(1, 'Invalid Line (%d): %s\n' % (lineNum, line))

        referenceKey = loadlib.verifyReference(jnum, lineNum, errorFile)
        imageTypeKey = verifyImageType(imageType, lineNum, errorFile)

        if referenceKey == 0 or imageTypeKey == 0:
            # set error flag to true
            error = 1

        # if errors, continue to next record
        if error:
            continue

        # if no errors, process

	imageKey = pixImageKey[pixID]

	if len(relatedpixID) > 0:
	    relatedimageKey = pixImageKey[relatedpixID]
	else:
	    relatedimageKey = ''

        outImageFile.write(str(imageKey) + TAB + \
	    str(referenceKey) + TAB + \
	    str(imageTypeKey) + TAB + \
	    str(relatedimageKey) + TAB + \
	    xdim + TAB + \
	    ydim + TAB + \
	    figureLabel + TAB + \
	    copyrightNote + TAB + \
	    str(createdByKey) + TAB + \
	    str(createdByKey) + TAB + \
	    loaddate + TAB + loaddate + CRT)

        # MGI Accession ID for the image

	outAccFile.write(str(accKey) + TAB + \
	    mgiPrefix + str(mgiKey) + TAB + \
	    mgiPrefix + TAB + \
	    str(mgiKey) + TAB + \
	    accLogicalDBKey + TAB + \
	    str(imageKey) + TAB + \
	    imageMgiTypeKey + TAB + \
	    accPrivate + TAB + \
	    accPreferred + TAB + \
	    str(createdByKey) + TAB + \
	    str(createdByKey) + TAB + \
	    loaddate + TAB + loaddate + CRT)

        accKey = accKey + 1
        mgiKey = mgiKey + 1

	# PIX ID for the image

	outAccFile.write(str(accKey) + TAB + \
	    pixPrefix + str(pixID) + TAB + \
	    pixPrefix + TAB + \
	    str(pixID) + TAB + \
	    pixLogicalDBKey + TAB + \
	    str(imageKey) + TAB + \
	    imageMgiTypeKey + TAB + \
	    pixPrivate + TAB + \
	    accPreferred + TAB + \
	    str(createdByKey) + TAB + \
	    str(createdByKey) + TAB + \
	    loaddate + TAB + loaddate + CRT)

        accKey = accKey + 1

	# Image Panes (must have at least one)

	if len(panes) > 0:
	    assocPaneKey = paneKey
	    for p in panes:
                outPaneFile.write(str(paneKey) + TAB + \
		    str(imageKey) + TAB + \
	            p + TAB + \
	            mgi_utils.prvalue(paneLabel) + TAB + \
	            str(createdByKey) + TAB + \
	            str(createdByKey) + TAB + \
	            loaddate + TAB + loaddate + CRT)

                paneKey = paneKey + 1
	else:
	    assocPaneKey = paneKey
            outPaneFile.write(str(paneKey) + TAB + \
		str(imageKey) + TAB + \
	        TAB + \
	        mgi_utils.prvalue(paneLabel) + TAB + \
	        str(createdByKey) + TAB + \
	        str(createdByKey) + TAB + \
	        loaddate + TAB + loaddate + CRT)

	    # create assocations to Image Pane
	    # if len(assocations) > 0:

            paneKey = paneKey + 1

	# Notes

	if len(caption) > 0:

            outNoteFile.write(str(noteKey) + TAB +  \
			      str(imageKey) + TAB +  \
			      imageMgiTypeKey + TAB + \
			      imageNoteTypeKey + TAB + \
	                      str(createdByKey) + TAB + \
	                      str(createdByKey) + TAB + \
			      loaddate + TAB + loaddate + CRT)

            noteSeq = 1
		
            while len(caption) > 255:
                outNoteChunkFile.write(str(noteKey) + TAB + \
				       str(noteSeq) + TAB + \
				       caption[:255] + TAB + \
	                               str(createdByKey) + TAB + \
	                               str(createdByKey) + TAB + \
				       loaddate + TAB + loaddate + CRT)
                newnote = caption[255:]
                caption = newnote
                noteSeq = noteSeq + 1

            if len(caption) > 0:
                outNoteChunkFile.write(str(noteKey) + TAB + \
				       str(noteSeq) + TAB + \
				       caption + TAB + \
	                               str(createdByKey) + TAB + \
	                               str(createdByKey) + TAB + \
				       loaddate + TAB + loaddate + CRT)

	# Assocations

	if len(assocations) > 0:
	    for a in assocations:
		outAssocFile.write(str(assocKey) + TAB + \
				   str(assocPaneKey) + TAB + \
#				   allele or genotype + \
#				   objectKey + TAB + \
#				   isprimary + TAB + \
	                           str(createdByKey) + TAB + \
	                           str(createdByKey) + TAB + \
				   loaddate + TAB + loaddate + CRT)
		assocKey = assocKey + 1

    #	end of "for line in inImageFile1.readlines():"

    inImageFile2.close()
    return lineNum

def process():

    recordsProcessed = processImageFile()
    bcpFiles(recordsProcessed)

#
# Main
#

init()
verifyMode()
setPrimaryKeys()
process()
exit(0)

#
# $Log$
# Revision 1.1  2005/06/10 12:17:36  lec
# MGI 3.3
#
# Revision 1.4  2004/09/16 16:12:15  lec
# TR 6118
#
# Revision 1.3  2004/09/08 19:41:40  lec
# TR 6118
#
# Revision 1.2  2003/09/24 12:30:44  lec
# TR 5154
#
# Revision 1.1  2003/07/16 19:41:09  lec
# TR 4800
#
#
