#!/usr/local/bin/python

import os
import sys
import string
import db
import mgi_utils

todayDate = mgi_utils.date('%m/%d/%Y')

outFile = open('BIB_DataSets_Assoc.bcp', 'w')

dataset = {}
cmd = 'select _DataSet_key, abbreviation from BIB_DataSets'
results = db.sql(cmd, 'auto')
for r in results:

	key = r['abbreviation']

	if r['abbreviation'] == 'Probes/Seq':
		key = 'Probes'

	if r['abbreviation'] == 'MLC/Allele':
		key = 'MLC'

	dataset[key] = r['_DataSet_key']

assocKey = 1000

cmd = 'select _Refs_key, dbs from BIB_Refs where dbs is not null'
results = db.sql(cmd, 'auto')

for r in results:
	refsKey = r['_Refs_key']
	dbs = string.strip(r['dbs'])
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
				outFile.write('%s\t' % (assocKey) + \
					'%s\t' % (refsKey) + \
					'%s\t' % (dataset[d1]) + \
					'%s\t' % (neverUsed) + \
					'1000\t1000\t%s\t%s\n' % (todayDate, todayDate))

				assocKey = assocKey + 1
			elif d1 != "Matrix":
				print str(refsKey)
				print '*' + d1 + '*'

outFile.close()

