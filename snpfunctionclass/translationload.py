'''
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

transTypeKey = 1014
userKey = 1031
vocabKey = 49

loaddate = loadlib.loaddate

inputFile = open('fxnClass.goodbad', 'r')
outputFile = open('MGI_Translation.bcp', 'w')
                
results = db.sql(''' select nextval('mgi_translation_seq') as maxKey ''', 'auto')
transKey = results[0]['maxKey']
lineNum = 0
seqNum = 1

# do not delete; simply add new translations
#db.sql('delete from MGI_Translation where _translationtype_key = %s' % (transTypeKey), None)
#db.commit()

for line in inputFile.readlines():
    lineNum = lineNum + 1

    tokens = str.split(line[:-1], '|')

    objectID = tokens[0]
    objectDescription = tokens[1]
    term = tokens[2]
    #userID = tokens[3]

    objectKey = loadlib.verifyTerm(objectID, vocabKey, objectDescription, lineNum, None)

    # add term to translation file
    values = [transKey, transTypeKey, objectKey, term, seqNum, userKey, userKey, loaddate, loaddate]
    strvalues = []
    for v in values:
        strvalues.append(str(v))
    outputFile.write('%s\n' % ("|".join(strvalues)))
    transKey = transKey + 1
    seqNum = seqNum + 1

inputFile.close()
outputFile.close()

