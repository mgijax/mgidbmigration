#!/usr/local/bin/python

'''
#
# convert (copy) /mgi/all/Jfiles/ over to /data/littriage directory
#
# 1. read /mgi/all/Jfiles/
# 2. find MGI:xxxxx for J:
# 3. rename file from Jxxxxx.pdf to xxxxx.pdf (numeric part of MGI:xxxxx)
# 4. copy xxxxx.pdf to appropriate /data/littriage/ path 
# 	using Pdfpath.py/getPdfpath('/data/littriage', 'MGI:xxxxx')
#
'''

import sys 
import os
import re
import db
import PdfParser
import PubMedAgent
import Pdfpath

#db.setTrace(1)

masterTriageDir = '/data/littriage'
parentDir = '/mgi/all/Jfiles'
litparser = os.getenv('LITPARSER')

PdfParser.setLitParserDir(litparser)

mgifilecount = 0
sql = ''

# 1. read /mgi/all/Jfiles/

refLookup = {}
results = db.sql('''select mgiID, _Refs_key from BIB_Citation_Cache''', 'auto')
for r in results:
    key = r['mgiID']
    value = r['_Refs_key']
    refLookup[key] = []
    refLookup[key].append(value)

for mgifilePath in os.listdir(masterTriageDir):

    fullFilePath = os.path.join(masterTriageDir, mgifilePath)

    if not os.path.isdir(fullFilePath):
        continue

    for pdfFile in os.listdir(fullFilePath):

	fullpdfFile = os.path.join(fullFilePath, pdfFile)

	mgiID = pdfFile
	mgiID = mgiID.replace('.pdf', '')
	mgiID = 'MGI:' + mgiID

	if mgiID not in refLookup:
	    continue

	results = refLookup[mgiID]
	refsKey = results[0]

	try:
	    pdf = PdfParser.PdfParser(fullpdfFile)
	    extractedText = pdf.getText()
	    if extractedText != None:
                extractedText = re.sub(r'[^\x00-\x7F]','', extractedText)
                extractedText = extractedText.replace('\\', '\\\\')
                extractedText = extractedText.replace('\n', '\\n')
                extractedText = extractedText.replace('\r', '\\r')
                extractedText = extractedText.replace('|', '\\n')
                extractedText = extractedText.replace("'", "''")
	        db.sql('''
	    	    update BIB_Workflow_Data 
		    set hasPDF = 1, 
		    extractedText = E'%s' where _Refs_key = %s
		    ''' % (extractedText, refsKey), None)
	    else:
	        db.sql('''
	    	        update BIB_Workflow_Data set hasPDF = 1 where _Refs_key = %s
		        ''' % (refsKey), None)
	except:
	        db.sql('''
	    	        update BIB_Workflow_Data set hasPDF = 1 where _Refs_key = %s
		        ''' % (refsKey), None)

        db.commit()
        mgifilecount += 1
	print 'successful: ', mgiID, fullpdfFile

#db.sql(sql, None)
#db.commit()

print ''
print 'mgi file count: ', str(mgifilecount)
print ''

