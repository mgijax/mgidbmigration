#!/usr/local/bin/python

#
#	Delete Orphaned Genotypes
#
# Inputs:
#
#	database
#
# Outputs:
#
#	inline deletes
#
# History
#
# 02/08/2016	sc

#

import sys
import os
import string
import accessionlib
import db
import mgi_utils
import loadlib

db.useOneConnection(1)

fpIn = open('GXD_OrphanGenotype.genoIds', 'r')

delCt = 0
notDelCt = 0
for id in fpIn.readlines():
    results = db.sql(''' select _Object_key
	from ACC_Accession
	where _MGIType_key = 12
	and _LogicalDB_key = 1
	and accid = '%s' ''' % string.strip(id), 'auto')
    if results == []:
	notDelCt += 1
	continue
    delCt += 1
    genotypeKey = results[0]['_Object_key']
    db.sql('''delete from GXD_Genotype where _Genotype_key = %s''' % genotypeKey, None)
db.commit()

print 'Genotypes not in the database: %s' % notDelCt
print 'Genotypes deleted from the database: %s' % delCt

db.useOneConnection(0)
