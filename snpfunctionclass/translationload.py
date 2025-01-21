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
'''

import sys
import os
import db
import loadlib

inputFile = 'fxnClass.goodbad'
transFileName = 'MGI_Translation.bcp'
transTypeKey = 1014
userKey = 1031
transFile = ''

loaddate = loadlib.loaddate

# if 'add' mode, this is reset to max(sequenceNum) + 1
seqNum = 1

try:
    inputFile = open(inputFileName, 'r')
except:
    exit(1, 'Could not open file %s\n' % inputFileName)
                
try:
    transFile = open(transFileName, 'w')
except:
    exit(1, 'Could not open file %s\n' % transFileName)
                
results = db.sql(''' select nextval('mgi_translation_seq') as maxKey ''', 'auto')
transKey = results[0]['maxKey']
lineNum = 0

# For each line in the input file

for line in inputFile.readlines():

    lineNum = lineNum + 1

    # Split the line into tokens
    tokens = str.split(line[:-1], '|')

    objectID = tokens[0]
    objectDescription = tokens[1]
    term = tokens[2]
    #userID = tokens[3]

    if vocabKey > 0:
        objectKey = loadlib.verifyTerm(objectID, vocabKey, objectDescription, lineNum, errorFile)
    else:
        objectKey = loadlib.verifyObject(objectID, mgiTypeKey, objectDescription, lineNum, errorFile)

    # add term to translation file
    values = [transKey, transTypeKey, objectKey, term, seqNum, userKey, userKey, loaddate, loaddate]
    strvalues = []
    for v in values:
        strvalues.append(str(v))
    fp.write('%s\n' % ("|".join(strvalues)))
    transKey = transKey + 1
    seqNum = seqNum + 1

inputFile.close()
fp.close()

