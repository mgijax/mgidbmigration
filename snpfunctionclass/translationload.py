#
# Input(s):
#
#	A pipe-delimited file in the format:
#		field 1: Acc ID of Good Name
#		field 2: Good Name
#		field 3: Bad Name
#		field 4: Created By
#
# Output:
#
#       BCP files:
#
#	    MGI_Translation.bcp		Translation records
#
# Processing:
#
#	For each line in the input file:
#
#	1.  Verify the Acc ID of the object (good name ) is valid.  
#	    The MGI Type of the Acc ID must be the same as the MGI Type of the Translation Type.
#	    Duplciate Acc IDs are allowed (a good name can have more than one bad name).
#	    If the verification fails, report the error and skip the record.
#
#	2.  Create MGI_Translation record for the MGI object.
#
# History:
#
'''

import sys
import os
import db
import mgi_utils
import loadlib

#globals

inputFileName = os.environ['TRANSINPUTFILE']
outputFileDir = os.environ['TRANSOUTPUTDIR']
transTypeName = os.environ['TRANSTYPENAME']
transMGIType = os.environ['TRANSMGITYPE']
transCompression = os.environ['TRANSCOMPRESSION']
vocabName = os.environ['VOCABNAME']

inputFile = ''		# file descriptor
diagFile = ''		# file descriptor
errorFile = ''		# file descriptor

transTypeFile = ''	# file descriptor
transFile = ''		# file descriptor

diagFileName = ''	# file name
errorFileName = ''	# file name

transFileName = ''	# file name

bcpdelim = '|'

transTypeKey = 0	# primary key of translation type record
mgiTypeKey = 0		# primary key of translation type mgi type
vocabKey = 0		# primary key of translation's vocabulary

loaddate = loadlib.loaddate

# if 'add' mode, this is reset to max(sequenceNum) + 1
seqNum = 1

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
                transFile.close()
        except:
                pass

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
 
        global inputFile, diagFile, errorFile, errorFileName, diagFileName
        global transFile
        global transFileName
 
        # the default output file names are bases on 'inputFileName'
        head, fileName = os.path.split(inputFileName)
        # rename 'head'
        head = outputFileDir 
        fdate = mgi_utils.date('%m%d%Y')	# current date

        diagFileName = head + '/' + fileName + '.' + fdate + '.diagnostics'
        print(diagFileName)
        errorFileName = head + '/' + fileName + '.' + fdate + '.error'
        print(errorFileName)
        transFileName = 'MGI_Translation.bcp'
        print(transFileName)

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
                transFile = open(transFileName, 'w')
        except:
                exit(1, 'Could not open file %s\n' % transFileName)
                
        # Log all SQL
        db.set_sqlLogFunction(db.sqlLogAll)

        # Set Log File Descriptor
        #db.set_sqlLogFD(diagFile)
        db.set_commandLogFile(diagFileName) 

        diagFile.write('Start Date/Time: %s\n' % (mgi_utils.date()))
        diagFile.write('Server: %s\n' % (db.get_sqlServer()))
        diagFile.write('Database: %s\n' % (db.get_sqlDatabase()))
        diagFile.write('Input File: %s\n' % (inputFileName))

        errorFile.write('Start Date/Time: %s\n\n' % (mgi_utils.date()))

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

        global seqNum

        results = db.sql(''' select nextval('mgi_translation_seq') as maxKey ''', 'auto')
        transKey = results[0]['maxKey']
        if transKey is None:
                transKey = 1000

        lineNum = 0

        # For each line in the input file

        for line in inputFile.readlines():

                error = 0
                lineNum = lineNum + 1

                # Split the line into tokens
                tokens = str.split(line[:-1], '|')

                try:
                        objectID = tokens[0]
                        objectDescription = tokens[1]
                        term = tokens[2]
                        userID = tokens[3]
                except:
                        exit(1, 'Invalid Line (%d): %s\n' % (lineNum, line))
                        continue

                if vocabKey > 0:
                    objectKey = loadlib.verifyTerm(objectID, vocabKey, objectDescription, lineNum, errorFile)
                else:
                    objectKey = loadlib.verifyObject(objectID, mgiTypeKey, objectDescription, lineNum, errorFile)

                userKey = loadlib.verifyUser(userID, lineNum, errorFile)

                if objectKey == 0 or userKey == 0:
                        # set error flag to true
                        error = 1

                # if errors, continue to next record
                if error:
                        continue

                # if no errors, process

                # add term to translation file
                bcpWrite(transFile, [transKey, transTypeKey, objectKey, term, seqNum, userKey, userKey, loaddate, loaddate])
                transKey = transKey + 1
                seqNum = seqNum + 1

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

        #fp.write('%s\n' % (str.join(strvalues, bcpdelim)))
        fp.write('%s\n' % (bcpdelim.join(strvalues)))

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

        bcpI = '%s %s %s' % (os.environ['PG_DBUTILS'] + '/bin/bcpin.csh', db.get_sqlServer(), db.get_sqlDatabase())
        bcpII = '"|" "\\n" mgd'

        transFile.close()

        bcp1 = '%s %s "" %s %s' % (bcpI, 'MGI_Translation', 'MGI_Translation.bcp', bcpII)

        diagFile.write('%s\n' % bcp1)

        print(bcp1)
        os.system(bcp1)
        db.commit()

        db.sql(''' select setval('mgi_translation_seq', (select max(_Translation_key) from MGI_Translation)) ''', None)
        db.commit()

#
# Main
#

init()
processFile()
bcpFiles()
exit(0)

