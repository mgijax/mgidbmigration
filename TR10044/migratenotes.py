#!/usr/local/bin/python

#
# select all GO Annotation Notes
#

import sys
import os
import re
import string
import db
import mgi_utils
import reportlib

#
# from configuration file
#
user = os.environ['MGD_DBUSER']
passwordFileName = os.environ['MGD_DBPASSWORDFILE']
errorFileName = 'migratenotes.error'

deleteSQL = 'delete from MGI_Note where _Note_key = %s\n'
deleteCMD = ''

propertyMap = {}
propertyFileName = 'VOC_Evidence_Property.bcp'
propertyFile = open(propertyFileName, 'w')
errorFile = open(errorFileName, 'w')

db.useOneConnection(1)
db.set_sqlUser(user)
db.set_sqlPasswordFromFile(passwordFileName)

# next property key
results = db.sql('select maxKey = max(_EvidenceProperty_key) + 1 from VOC_Evidence_Property', 'auto')
if results[0]['maxKey'] is None:
    propertyKey = 1000
else:
    propertyKey = results[0]['maxKey']

# cache property vocabulary
results = db.sql('select _Term_key, term from VOC_Term where _Vocab_key = 82', 'auto')
for r in results:
    key = r['_Term_key']
    value = r['term']
    propertyMap[value] = key

# read existing note data
results = db.sql('''
	select distinct a.accID, m.symbol, n._Object_key, n._Note_key, note = rtrim(nc.note) ,
               n._CreatedBy_key, n._ModifiedBy_key, 
	       cdate = convert(char(20), n.creation_date, 100),
	       mdate = convert(char(20), n.modification_date, 100)
        from VOC_Annot_View a, VOC_Evidence e, MGI_Note n, MGI_NoteChunk nc, MRK_Marker m
        where a._AnnotType_key = 1000 
        and a._Annot_key = e._Annot_key 
        and n._NoteType_key = 1008 
        and n._Object_key = e._AnnotEvidence_key 
	and n._Note_key = nc._Note_key 
	and a._Object_key = m._Marker_key
	order by m.symbol, n._Note_key, nc.sequenceNum
	''', 'auto')

info = {}
for r in results:
    key = r['_Note_key']

    if not info.has_key(key):
	info[key] = r

notes = {}
for r in results:
    key = r['_Note_key']
    value = string.replace(r['note'], '\\n', '\n')

    if not notes.has_key(key):
	notes[key] = []
    notes[key].append(value)

notekeys = notes.keys()
notekeys.sort()

# for each note

for k in notekeys:

    accID = info[k]['accID']
    symbol = info[k]['symbol']
    objectKey = info[k]['_Object_key']
    cby = info[k]['_CreatedBy_key']
    mby = info[k]['_ModifiedBy_key']
    cdate = info[k]['cdate']
    mdate = info[k]['mdate']

    seqnum = 1
    stanza = 1

    allnotestr = string.join(notes[k], '')
    print '\n' + allnotestr

    #t1 = string.split(allnotestr, 'text:')
    tokens = string.split(allnotestr, '\n')

    foundMap = 0
    foundEvidence = 0

    for t in tokens:
        for n in propertyMap:
	    t = string.replace(t, 'Gene_Product', 'gene product')
	    t = string.replace(t, 'protein product', 'gene product')
	    if string.find(t, n) >= 0:
	      foundMap = 1
	      splitT = string.split(t,n)
	      if splitT[0] == '' and splitT[1] != '':
		  pValues = string.split(t, ':')
		  pTerm = pValues[0]
		  pValue = string.join(pValues[1:], ':')
		  pValue = string.lstrip(pValue)
		  pValue = string.rstrip(pValue)
		  if pValue != '':
		      # ok, good to add to property file
		      if not propertyMap.has_key(pTerm):
	     	          print 'ERROR: property'
			  print '\t' + symbol + '\t' + accID + '\t' + pTerm + '\t' + pValue
		      elif len(pValue) > 255:
	     	          print 'VALUE TOO LONG'
			  print '\t' + symbol + '\t' + accID + '\t' + pTerm + '\t' + pValue
	     	      else:
			  print '\t' + symbol + '\t' + accID + '\t' + pTerm + '\t' + pValue

		          if pTerm == 'evidence':
			      foundEvidence = foundEvidence + 1

			      if foundEvidence > 1:
			          stanza = stanza + 1
			          seqnum = 1
				  print 'NEW STANZA'

                          propertyFile.write('%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n' \
                            % (propertyKey, objectKey, propertyMap[pTerm], stanza, seqnum, pValue, \
                               cby, mby, cdate, mdate))

			  seqnum = seqnum + 1
                          propertyKey = propertyKey + 1
			  deleteCMD = deleteCMD + deleteSQL % (k)

        if foundMap == 0:
	    print '\t' + symbol + '\t' + accID + '\tNot Migrated'

propertyFile.close()

bcpProperty = 'cat %s | bcp %s..%s in %s -c -t\"\t" -e %s -S%s -U%s' \
                % (passwordFileName, db.get_sqlDatabase(), \
                'VOC_Evidence_Property', propertyFileName, errorFileName, \
		db.get_sqlServer(), db.get_sqlUser())

os.system(bcpProperty)
db.sql(deleteCMD, None)

db.useOneConnection(0)
 
