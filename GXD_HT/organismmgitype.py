#!/usr/local/bin/python

'''
#
# Update sequence number in MGI_Organism_MGIType 
#
'''
 
import sys 
import os
import db

sampleMapping = {1:1, 2:2, 40:3, 106:4, 103:5, 108:6, 11:7, 88:8, 63:9, 10:10, 13:11, 64:12, 86:13, 95:14, 19:15, 20:16, 99:17, 105:18, 94:19, 102:20, 101:21, 97:22, 98:23, 107:24, 104:25, 34:26, 37:27, 100:28, 39:29, 44:30, 84:31}
typeOrgDict = {}

#
# Main
#

db.useOneConnection(1)
results = db.sql('''select mo.* 
	from MGI_Organism_MGIType mo, MGI_Organism m
	where mo._Organism_key = m._Organism_key
	order by m.commonName''', 'auto')
for r in results:
    mgiTypeKey = r['_MGIType_key'] 
    orgKey = r['_Organism_key']
    if mgiTypeKey not in typeOrgDict:
	typeOrgDict[mgiTypeKey] = []
    typeOrgDict[mgiTypeKey].append(orgKey)

for mgiTypeKey in typeOrgDict:
    orgList = typeOrgDict[mgiTypeKey]
    if mgiTypeKey == 43:
	for o in orgList:
	    ct = sampleMapping[o]
	    print '%s %s : %s' % (mgiTypeKey, o, ct)
	    db.sql('''update MGI_Organism_MGIType
                set sequenceNum = %s
                where _MGIType_key = %s
                and _Organism_key = %s''' % (ct, mgiTypeKey, o), 'auto')
    else:
	ct = 1
	for o in orgList:
	    print '%s %s : %s' % (mgiTypeKey, o, ct)
	    db.sql('''update MGI_Organism_MGIType
		set sequenceNum = %s
		where _MGIType_key = %s
		and _Organism_key = %s''' % (ct, mgiTypeKey, o), 'auto')
	    ct += 1
db.commit()
db.useOneConnection(0)
