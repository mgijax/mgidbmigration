#!/usr/local/bin/python

import sys
import os
import string
import regsub
import db

DEBUG = 0

passwordFileName = os.environ['DBPASSWORDFILE']

#
# Main
#

db.useOneConnection(1)
db.set_sqlUser('mgd_dbo')
db.set_sqlPassword(string.strip(open(passwordFileName, 'r').readline()))
db.set_sqlLogFunction(db.sqlLogAll)

print 'convert Strains with "#" to "*"'

results = db.sql('select _Strain_key, strain from PRB_Strain where strain like "% # %"', 'auto')
for r in results:
    newStrain = regsub.gsub('#', '*', r['strain'])
    db.sql('update PRB_Strain set strain = "%s" where _Strain_key = %s' % (newStrain, r['_Strain_key']), None, execute = not DEBUG)

db.useOneConnection(0)

