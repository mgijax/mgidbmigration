#!/usr/local/bin/python

import os
import string
import db

outFile = open('mgidataset.sql', 'w')

dataset = {}
cmd = 'select _DataSet_key, abbreviation from BIB_DataSets'
results = db.sql(cmd, 'auto')
for r in results:
	dataset[r['abbreviation']] = r['_DataSet_key']

assocKey = 1000

cmd = 'select _Refs_key, dbs from BIB_Refs where dbs is not null'
results = db.sql(cmd, 'auto')

for r in results:
	refsKey = r['_Refs_key']
	dbs = r['dbs']
	sets = string.split(dbs, '/')

	for s in sets:
		if len(s) > 0:
			d1 = d2 = s
			if string.find(s, '*') >= 0:
				[d1, d2] = string.split(s, '*')

			if d1 != d2:
				neverUsed = 1
			else:
				neverUsed = 0

			if dataset.has_key(d1):
				outFile.write('insert into BIB_DataSets_Assoc values' + \
					'(%s,' % (assocKey) + \
					'%s,' % (refsKey) + \
					'%s,' % (dataset[d1]) + \
					'%s,' % (neverUsed) + \
					'1000,1000,getdate(),getdate())\ngo\n')

				assocKey = assocKey + 1
			else:
				print d1

outFile.close()

