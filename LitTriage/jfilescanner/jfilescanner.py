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

MASTERTRIAGEDIR='/data/loads/lec/littriage'
#MASTERTRIAGEDIR='/data/littriage'

parentDir = '/mgi/all/Jfiles'

wf_data = '%s|%s|31576677|||1001|1001|%s|%s\n'

# 1. read /mgi/all/Jfiles/
    #fileDir = os.path.join(jfilePath, 

for jfilePath in os.listdir(parentDir):

    fullFilePath = os.path.join(parentDir, jfilePath)

    if not os.path.isdir(fullFilePath):
        continue

    #print fullFilePath

    for pdfFile in os.listdir(fullFilePath):

        if not pdfFile.endswith('.pdf'):
            continue
    
	fullpdfFile = os.path.join(fullFilePath, pdfFile)

	#print os.path.getsize(fullpdfFile)

        if os.path.getsize(fullpdfFile) <= 0:
	    continue

	# 2. find MGI:xxxxx for J:

	jnumID = pdfFile
	jnumID = jnumID.replace('J', 'J:')
	jnumID = jnumID.replace('.pdf', '')

	results = db.sql('''select _Refs_key, mgiID from BIB_Citation_Cache where jnumID = '%s' ''' % (jnumID), 'auto')
	if len(results) == 0:
	    continue
	refsKey = results[0]['_Refs_key']
        mgiID = results[0]['mgiID']
	prefixPart, numericPart = mgiID.split('MGI:')
	newFileName = numericPart + '.pdf'

        # 3. rename file from Jxxxxx.pdf to xxxxx.pdf (numeric part of MGI:xxxxx)

        newFileDir = Pdfpath.getPdfpath(MASTERTRIAGEDIR, mgiID)

	# 4. copy xxxxx.pdf to appropriate /data/littriage/ path 

	try:
	    os.makedirs(newFileDir)
	except:
	    pass

	try:
	    shutil.copy(fullpdfFile, newFileDir + '/' + newFileName)
	    print 'successful: ', jnumID, mgiID, fullpdfFile, ' to: ', newFileDir, newFileName
        except:
	    print 'failed: ', fullpdfFile, ' to: ', newFileDir, newFileName

	print ''

