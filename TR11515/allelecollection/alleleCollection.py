#!/usr/local/bin/python

'''
#
# 1) use rules to set ALL_Allele._Collection_key field
#
'''
 
import sys 
import os
import db
import reportlib
import mgi_utils

CRT = reportlib.CRT
SPACE = reportlib.SPACE
TAB = reportlib.TAB
PAGE = reportlib.PAGE

DEBUG = 0

user = os.environ['MGD_DBUSER']
passwordFileName = os.environ['MGD_DBPASSWORDFILE']
db.set_sqlUser(user)
db.set_sqlPasswordFromFile(passwordFileName)

#
#
# main
#

db.useOneConnection(1)

newTerm = {}
results = db.sql('select _Term_key, term from VOC_Term where _Vocab_key = 92', 'auto')
for r in results:
	key = r['term']
	value = r['_Term_key']
	newTerm[key] = []
	newTerm[key].append(value)
print '\nnewTerms....'
print newTerm

db.useOneConnection(0)

