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
import shutil
import db
import Pdfpath

masterTriageDir = '/data/littriage'
parentDir = '/mgi/all/Jfiles'

jfilecount = 0
notmovedPDF = 0
movedPDF = []
duplicatePDF = 0

processType = os.environ['PROCESSTYPE']

# for production (bhmgiapp01)
if processType == '1':
    processPDF = 1
    processWF = 0
    jfileset = 'J'

# for development (bhmgidevapp01)
elif processType == '2':
    processPDF = 1
    processWF = 0
    jfileset = 'J240'

# for development
else:
    processPDF = 1
    #processPDF = 0
    processWF = 1
    jfileset = 'J240'
    #jfileset = 'J'

print 'processPDF= ', processPDF, ', processWF= ', processWF, ', jfileset= ', jfileset

# 1. read /mgi/all/Jfiles/

for jfilePath in os.listdir(parentDir):

    #jfilecount += 1

    fullFilePath = os.path.join(parentDir, jfilePath)

    if not os.path.isdir(fullFilePath):
	#print 'not a jfile folder: ', fullFilePath
	#notmovedPDF += 1
        continue

    print fullFilePath
    if fullFilePath == parentDir + '/saved':
        continue

    #print fullFilePath

    for pdfFile in os.listdir(fullFilePath):

        if not pdfFile.startswith(jfileset) or not pdfFile.endswith('.pdf'):
            continue

        jfilecount += 1

	fullpdfFile = os.path.join(fullFilePath, pdfFile)

	#print os.path.getsize(fullpdfFile)

        if os.path.getsize(fullpdfFile) <= 0:
	    print 'pdf is empty: ', fullpdfFile
	    notmovedPDF += 1
	    continue

	# 2. find MGI:xxxxx for J:

	jnumID = pdfFile
	jnumID = jnumID.replace('J', 'J:')
	jnumID = jnumID.replace('d.pdf', '')
	jnumID = jnumID.replace('D.pdf', '')
	jnumID = jnumID.replace('R.pdf', '')
	jnumID = jnumID.replace('.pdf', '')

	results = db.sql('''select _Refs_key, mgiID from BIB_Citation_Cache where jnumID = '%s' ''' % (jnumID), 'auto')
	if len(results) == 0:
	    print 'J: not in MGD: ', jnumID
	    notmovedPDF += 1
	    continue
	refsKey = results[0]['_Refs_key']
        mgiID = results[0]['mgiID']
	prefixPart, numericPart = mgiID.split('MGI:')
	newFileName = numericPart + '.pdf'

        # 3. rename file from Jxxxxx.pdf to xxxxx.pdf (numeric part of MGI:xxxxx)

        newFileDir = Pdfpath.getPdfpath(masterTriageDir, mgiID)

	# 4. copy xxxxx.pdf to appropriate /data/littriage/ path 

	try:
	    if processPDF:
	        os.makedirs(newFileDir)
        except:
	    pass

	try:
	    if processPDF:
	        shutil.copy(fullpdfFile, newFileDir + '/' + newFileName)
	    if processWF:
	        db.sql('update BIB_Workflow_Data set hasPDF = 1 where _Refs_key = %s' % (refsKey), None)
                db.commit()
	    print 'successful: ', jnumID, mgiID, fullpdfFile, ' to: ', newFileDir, newFileName
	    if refsKey not in movedPDF:
	    	movedPDF.append(refsKey)
	    else:
	        duplicatePDF += 1
        except:
	    print 'failed: ', fullpdfFile, ' to: ', newFileDir, newFileName
	    notmovedPDF += 1

print ''
print 'j file count: ', str(jfilecount)
print 'not moved pdfs: ', str(notmovedPDF)
print 'moved pdfs: ', str(len(movedPDF))
print 'duplicate pdfs: ', str(duplicatePDF)
print 'not moved + moved + duplicates: ', str(notmovedPDF + len(movedPDF) + duplicatePDF)
print ''

