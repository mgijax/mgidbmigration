#!/usr/local/bin/python

import sys
import os
import string
import db
import reportlib

CRT = reportlib.CRT
SPACE = reportlib.SPACE
TAB = reportlib.TAB
PAGE = reportlib.PAGE


reportFile = os.environ['RPTFILE']

#
# Open the report file.
#
try:
    fpRpt = open(reportFile, 'w')
except:
    print('Cannot open report file: ' + reportFile)
    exit(1)

#
# Get all the new nomen markers and corresponding MGI IDs.
#
cmd = []
cmd.append('select a.accID, n.symbol ' + \
           'from ACC_Accession a, NOM_Marker n ' + \
           'where a._MGIType_key = 21 and ' + \
                 'a._LogicalDB_key = 1 and ' + \
                 'a._Object_key = n._Nomen_key and ' + \
                 'n._CreatedBy_key = 1093 and ' + \
                 'n.creation_date >= "9/4/2012" ' + \
           'order by accID')

results = db.sql(cmd,'auto')

#
# Write the records to the report file.
#
for r in results[0]:
    fpRpt.write('%s\t%s\n' % (r['accID'], r['symbol']))

fpRpt.close()
