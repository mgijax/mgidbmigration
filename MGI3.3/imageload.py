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
#	Assumes that each Image has at most one Image Pane which is null
#
#	IMG_Image
#	IMG_ImagePane
#       IMG_ImagePane_Assoc
#	MGI_Note
#	MGI_NoteChunk
#       MGI_Reference_Assoc
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
#       Image file, a tab-delimited file in the format:
#		field 1: PIX ID (PIX:#####)			required
#		field 2: Image Type (Full Size or Thumbnail)	required
#		field 3: Thumbnail Image PIX ID (PIX:####)	optional
#		field 4: X Dimension				required
#		field 5: Y Dimension				required
#		field 6: Reference (J:####)			required
#               field 7: Figure Label				required
#               field 8: Caption				required
#               field 9: Copyright				optional
#		field 10: Created by				required
#
#	Association file, a tab-delimited file in the format:
#		field 1: PIX ID (PIX:#####)			required
#		field 2: MGI ID (MGI:#####)			required
#		field 3: References (J:, pipe delimited)	required
#		field 4: Is Primary (Y or N)			required
#		field 5: Created by				required
#
# Outputs:
#
#       BCP files:
#
#       IMG_Image.bcp			master Image records
#	IMG_ImagePane.bcp		Image Pane records
#	IMG_ImagePane_Assoc.bcp		Image Pane records
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

inImageFileName1 = datadir + '/image.txt'
inImageFileName2 = datadir + '/imagepaneassoc.txt'

# output files

outImageFile = ''	# file descriptor
outNoteFile = ''	# file descriptor
outPaneFile = ''	# file descriptor
outAccFile = ''         # file descriptor
outAssocFile = ''       # file descriptor
outRefAssocFile = ''    # file descriptor

imageTable = 'IMG_Image'
paneTable = 'IMG_ImagePane'
noteTable = 'MGI_Note'
noteChunkTable = 'MGI_NoteChunk'
accTable = 'ACC_Accession'
assocTable = 'IMG_ImagePane_Assoc'
refassocTable = 'MGI_Reference_Assoc'

outImageFileName = datadir + '/' + imageTable + '.bcp'
outPaneFileName = datadir + '/' + paneTable + '.bcp'
outNoteFileName = datadir + '/' + noteTable + '.bcp'
outNoteChunkFileName = datadir + '/' + noteChunkTable + '.bcp'
outAccFileName = datadir + '/' + accTable + '.bcp'
outAssocFileName = datadir + '/' + assocTable + '.bcp'
outRefAssocFileName = datadir + '/' + refassocTable + '.bcp'

diagFileName = ''	# diagnostic file name
errorFileName = ''	# error file name
passwordFileName = ''	# password file name

mode = ''		# processing mode (load, preview)

# primary keys

imageKey = 0            # IMG_Image._Image_key
paneKey = 0		# IMG_ImagePane._ImagePane_key
noteKey = 0		# MGI_Note._Note_key
accKey = 0              # ACC_Accession._Accession_key
mgiKey = 0              # ACC_AccessionMax.maxNumericPart
assocKey = 0		# IMG_ImagePane_Assoc._Assoc_key
refassocKey = 0		# MGI_Reference_Assoc._Assoc_key

# accession constants

imageMGITypeKey = '9'	  	# Image
alleleMGITypeKey = '11'	 	# Allele
genotypeMGITypeKey = '12'	# Genotype
imagePaneAssocMGITypeKey = '29' # Image Pane Association
captionNoteTypeKey = '1024' 	# Image Note Type for Caption
copyrightNoteTypeKey = '1023' 	# Image Note Type for Caption
mgiPrefix = "MGI:"	  	# Prefix for MGI accession ID
accLogicalDBKey = '1'	  	# Logical DB Key for MGI accession ID
accPrivate = '0'	  	# Private status for MGI accession ID (false)
accPreferred = '1'	  	# Preferred status MGI accession ID (true)
pixLogicalDBKey = '19'	  	# Logical DB Key for PIX ID
pixPrivate = '1'	  	# Private status for PIX ID (true)
figureLabelDefault = '1'	# Default value for Figure Label
paneLabelDefault = ''		# Default value for Image Pane
refAssocTypeKey = '1020'        # Ref Assoc Type for Image Pane Associations

# dictionaries to cache data for quicker lookup

imgTypeDict = {}		# Image Type: Term key
pixImageKey = {}		# PIX ID: Image key
pixImagePaneKey = {}		# PIX ID: Image Pane key

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
    global mode
    global outImageFile, outNoteFile, outNoteChunkFile, outPaneFile, outAccFile, outAssocFile, outRefAssocFile
    global inImageFile1, inImageFile2
 
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
        inImageFile1 = open(inImageFileName1, 'r')
    except:
        exit(1, 'Could not open file %s\n' % inImageFileName1)

    try:
        inImageFile2 = open(inImageFileName2, 'r')
    except:
        exit(1, 'Could not open file %s\n' % inImageFileName2)

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

    try:
        outRefAssocFile = open(outRefAssocFileName, 'w')
    except:
        exit(1, 'Could not open file %s\n' % outRefAssocFileName)

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

def verifyImageType(
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

    return imgTypeKey

# Purpose:  sets global primary key variables
# Returns:  nothing
# Assumes:  nothing
# Effects:  sets global primary key variables
# Throws:   nothing

def setPrimaryKeys():

    global imageKey, paneKey, accKey, mgiKey, noteKey, assocKey, refassocKey

    results = db.sql('select maxKey = max(_Image_key) + 1 from IMG_Image', 'auto')
    imageKey = results[0]['maxKey']

    results = db.sql('select maxKey = max(_ImagePane_key) + 1 from IMG_ImagePane', 'auto')
    paneKey = results[0]['maxKey']

    results = db.sql('select maxKey = max(_Assoc_key) + 1 from IMG_ImagePane_Assoc', 'auto')
    assocKey = results[0]['maxKey']
    if assocKey is None:
	assocKey = 1000

    results = db.sql('select maxKey = max(_Note_key) + 1 from MGI_Note', 'auto')
    noteKey = results[0]['maxKey']

    results = db.sql('select maxKey = max(_Accession_key) + 1 from ACC_Accession', 'auto')
    accKey = results[0]['maxKey']

    results = db.sql('select maxKey = maxNumericPart + 1 from ACC_AccessionMax ' + \
        'where prefixPart = "%s"' % (mgiPrefix), 'auto')
    mgiKey = results[0]['maxKey']

    results = db.sql('select maxKey = max(_Assoc_key) + 1 from MGI_Reference_Assoc', 'auto')
    refassocKey = results[0]['maxKey']

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
    outRefAssocFile.close()

    bcpI = 'cat %s | bcp %s..' % (passwordFileName, db.get_sqlDatabase())
    bcpII = '-c -t\"%s' % (bcpdelim) + '" -S%s -U%s' % (db.get_sqlServer(), db.get_sqlUser())

    bcp1 = '%s%s in %s %s' % (bcpI, imageTable, outImageFileName, bcpII)
    bcp2 = '%s%s in %s %s' % (bcpI, noteTable, outNoteFileName, bcpII)
    bcp3 = '%s%s in %s %s' % (bcpI, noteChunkTable, outNoteChunkFileName, bcpII)
    bcp4 = '%s%s in %s %s' % (bcpI, paneTable, outPaneFileName, bcpII)
    bcp5 = '%s%s in %s %s' % (bcpI, accTable, outAccFileName, bcpII)
    bcp6 = '%s%s in %s %s' % (bcpI, assocTable, outAssocFileName, bcpII)
    bcp7 = '%s%s in %s %s' % (bcpI, refassocTable, outRefAssocFileName, bcpII)

    for bcpCmd in [bcp1, bcp2, bcp3, bcp4, bcp5, bcp6, bcp7]:
	diagFile.write('%s\n' % bcpCmd)
	os.system(bcpCmd)

    # update the max Accession ID value
    db.sql('exec ACC_setMax %d' % (recordsProcessed), None)

    # update statistics
    db.sql('update statistics %s' % (imageTable), None)
    db.sql('update statistics %s' % (paneTable), None)
    db.sql('update statistics %s' % (assocTable), None)

    return

# Purpose:  processes note data
# Returns:  nothing
# Assumes:  nothing
# Effects:  writes records to MGI_Note bcp files
# Throws:   nothing

def processNote(note, noteTypeKey, createdByKey):

    global noteKey

    outNoteFile.write(str(noteKey) + TAB +  \
		      str(imageKey) + TAB +  \
		      imageMGITypeKey + TAB + \
		      noteTypeKey + TAB + \
	              str(createdByKey) + TAB + \
	              str(createdByKey) + TAB + \
		      loaddate + TAB + loaddate + CRT)

    noteSeq = 1
		
    while len(note) > 255:
        outNoteChunkFile.write(str(noteKey) + TAB + \
			       str(noteSeq) + TAB + \
			       note[:255] + TAB + \
	                       str(createdByKey) + TAB + \
	                       str(createdByKey) + TAB + \
			       loaddate + TAB + loaddate + CRT)
        newnote = note[255:]
        note = newnote
        noteSeq = noteSeq + 1

    if len(note) > 0:
        outNoteChunkFile.write(str(noteKey) + TAB + \
			       str(noteSeq) + TAB + \
			       note + TAB + \
	                       str(createdByKey) + TAB + \
	                       str(createdByKey) + TAB + \
			       loaddate + TAB + loaddate + CRT)

    noteKey = noteKey + 1

# Purpose:  processes image data 1, image records
# Returns:  nothing
# Assumes:  nothing
# Effects:  verifies and processes each line in the input file
# Throws:   nothing

def processImageFile1():

    global inImageFile1
    global imageKey, paneKey, accKey, mgiKey
    global pixImageKey, pixImagePaneKey

    #
    # assign Image keys for each Pix ID
    # assign Image Pane keys for each Pix ID
    #

    for line in inImageFile1.readlines():

        tokens = string.split(line[:-1], TAB)
	pixID = tokens[0]

	pixImageKey[pixID] = imageKey
	imageKey = imageKey + 1

	pixImagePaneKey[pixID] = paneKey
        paneKey = paneKey + 1

    inImageFile1.close()

    # For each line in the input file

    inImageFile1 = open(inImageFileName1, 'r')
    lineNum = 0
    for line in inImageFile1.readlines():

        error = 0
        lineNum = lineNum + 1

        # Split the line into tokens
        tokens = string.split(line[:-1], TAB)

        try:
	    pixID = tokens[0]
	    imageType = tokens[1]
	    tnpixID = tokens[2]
	    xdim = tokens[3]
	    ydim = tokens[4]
	    jnum = tokens[5]
	    figureLabel = tokens[6]
	    caption = tokens[7]
	    copyright = tokens[8]
            createdBy = tokens[9]
        except:
            exit(1, 'Invalid Line (%d): %s\n' % (lineNum, line))

        referenceKey = loadlib.verifyReference(jnum, lineNum, errorFile)
        imageTypeKey = verifyImageType(imageType, lineNum, errorFile)
        createdByKey = loadlib.verifyUser(createdBy, 0, errorFile)

        if referenceKey == 0 or imageTypeKey == 0 or createdByKey == 0:
            # set error flag to true
            error = 1

        # if errors, continue to next record
        if error:
            continue

        # if no errors, process

	imageKey = pixImageKey[pixID]

	if len(tnpixID) > 0:
	    tnimageKey = pixImageKey[tnpixID]
	else:
	    tnimageKey = ''

	if len(figureLabel) == 0:
	    figureLabel = figureLabelDefault

        outImageFile.write(str(imageKey) + TAB + \
	    str(imageTypeKey) + TAB + \
	    str(referenceKey) + TAB + \
	    str(tnimageKey) + TAB + \
	    xdim + TAB + \
	    ydim + TAB + \
	    figureLabel + TAB + \
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
	    imageMGITypeKey + TAB + \
	    accPrivate + TAB + \
	    accPreferred + TAB + \
	    str(createdByKey) + TAB + \
	    str(createdByKey) + TAB + \
	    loaddate + TAB + loaddate + CRT)

        accKey = accKey + 1
        mgiKey = mgiKey + 1

	# PIX ID for the image

	pixPrefix, pixNumeric = accessionlib.split_accnum(pixID)

	outAccFile.write(str(accKey) + TAB + \
	    str(pixID) + TAB + \
	    pixPrefix + TAB + \
	    str(pixNumeric) + TAB + \
	    pixLogicalDBKey + TAB + \
	    str(imageKey) + TAB + \
	    imageMGITypeKey + TAB + \
	    pixPrivate + TAB + \
	    accPreferred + TAB + \
	    str(createdByKey) + TAB + \
	    str(createdByKey) + TAB + \
	    loaddate + TAB + loaddate + CRT)

        accKey = accKey + 1

	# Image Pane

	paneKey = pixImagePaneKey[pixID]
        outPaneFile.write(str(paneKey) + TAB + \
		    str(imageKey) + TAB + \
	            mgi_utils.prvalue(paneLabelDefault) + TAB + \
	            loaddate + TAB + loaddate + CRT)

	# Caption and Copyright

	if len(caption) > 0:
            processNote(caption, captionNoteTypeKey, createdByKey)

	if len(copyright) > 0:
            processNote(copyright, copyrightNoteTypeKey, createdByKey)

    #	end of "for line in inImageFile1.readlines():"

    inImageFile1.close()
    return lineNum

# Purpose:  processes image data file 2, associations
# Returns:  nothing
# Assumes:  nothing
# Effects:  verifies and processes each line in the input file
# Throws:   nothing

def processImageFile2():

    global assocKey, refassocKey

    # For each line in the input file

    lineNum = 0
    for line in inImageFile2.readlines():

        error = 0
        lineNum = lineNum + 1

        # Split the line into tokens
        tokens = string.split(line[:-1], TAB)

        try:
	    pixID = tokens[0]
	    mgiID = tokens[1]
	    jnums = string.split(tokens[2], '|')
	    isPrimary = tokens[3]
            createdBy = tokens[4]
        except:
            exit(1, 'Invalid Line (%d): %s\n' % (lineNum, line))

        createdByKey = loadlib.verifyUser(createdBy, 0, errorFile)

	objectKey = 0

	results = db.sql('select a._Object_key from ACC_Accession a ' + \
	                 'where a.accID = "%s" ' % (mgiID) + \
	                 'and a._MGIType_key = %s ' % (alleleMGITypeKey), 'auto')
        if len(results) > 0:
	    objectKey = results[0]['_Object_key']
	    mgiTypeKey = alleleMGITypeKey

	else:
	    results = db.sql('select a._Object_key from ACC_Accession a ' + \
	                 'where a.accID = "%s" ' % (mgiID) + \
	                 'and a._MGIType_key = %s ' % (genotypeMGITypeKey), 'auto')
            if len(results) > 0:
	        objectKey = results[0]['_Object_key']
	        mgiTypeKey = genotypeMGITypeKey
            else:
		error = 1

	if isPrimary == 'yes':
	    isPrimaryKey = 1
	else:
	    isPrimaryKey = 0

        if objectKey == 0 or createdByKey == 0:
            # set error flag to true
            error = 1

        # if errors, continue to next record
        if error:
            continue

	# Associations

	paneKey = pixImagePaneKey[pixID]

        outAssocFile.write(str(assocKey) + TAB + \
			   str(paneKey) + TAB + \
			   str(mgiTypeKey) + TAB + \
			   str(objectKey) + TAB + \
			   str(isPrimaryKey) + TAB + \
			   str(createdByKey) + TAB + str(createdByKey) + TAB + \
	                   loaddate + TAB + loaddate + CRT)

	# Association References

	for j in jnums:
            referenceKey = loadlib.verifyReference(j, 0, errorFile)
	    outRefAssocFile.write(str(refassocKey) + TAB + \
				  str(referenceKey) + TAB + \
				  str(assocKey) + TAB + \
				  str(imagePaneAssocMGITypeKey) + TAB + \
				  str(refAssocTypeKey) + TAB + \
			          str(createdByKey) + TAB + str(createdByKey) + TAB + \
	                          loaddate + TAB + loaddate + CRT)
	    refassocKey = refassocKey + 1

	assocKey = assocKey + 1

    #	end of "for line in inImageFile1.readlines():"

    inImageFile2.close()

def process():

    recordsProcessed = processImageFile1()
    processImageFile2()
    bcpFiles(recordsProcessed)

#
# Main
#

init()
verifyMode()
setPrimaryKeys()
process()
exit(0)

