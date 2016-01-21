#!/usr/local/bin/python

#
#	Update ACC_Accession - add RR ID for all existing genotypes
#
# Inputs:
#
#	database
#
# Outputs:
#
#	inline inserts
#
# History
#
# 01/19/2016	sc

#

import sys
import os
import string
import accessionlib
import db
import mgi_utils
import loadlib

db.useOneConnection(1)
genoWithRRList = []
results = db.sql('''select _Object_key as genotypeKey
        from ACC_Accession
        where _MGIType_key = 12
        and _LogicalDB_key = 179
	and prefixPart = 'RRID:MGI:' ''', 'auto')
for r in results:
    genoWithRRList.append(r['genotypeKey'])

print 'Querying for all genotype MGI IDs'
results = db.sql('''select accID, _Object_key
	from ACC_Accession
	where _MGIType_key = 12 
	and _LogicalDB_key = 1
	and preferred = 1
	and prefixPart = 'MGI:' ''', 'auto')

print 'Creating RR IDs'
ct = 0

# static attributes
userKey = 1001
logicalDbKey = 179
mgiType = 'Genotype'

genotypeDict = {}
for r in results:
    objectKey = r['_Object_key']
    if objectKey in genoWithRRList:
	continue
    ct+=1
    mgiID = r['accID']
    rrID = 'RRID:%s' % mgiID
    db.sql('''select * from ACC_insertNoChecks(%s, %s, '%s', %s, '%s')''' % (userKey, objectKey, rrID, logicalDbKey, mgiType), 'auto')
db.commit()
print 'RR IDs added to %s genotypes' % ct
db.useOneConnection(1)
