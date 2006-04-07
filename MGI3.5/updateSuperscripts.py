#!/usr/local/bin/python

#
# TR 5617
#
# Remove HTML superscript markup in Marker Synonyms 
#
#

import sys
import os
import string
import re
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

results = db.sql('select _Synonym_key, synonym from MGI_Synonym ' + \
	'where _SynonymType_key between 1004 and 1007 ' + \
	'and synonym like "%<sup>%"', 'auto')

for r in results:

    newsyn = re.sub('<sup>', '<', r['synonym'])
    newsyn = re.sub('</sup>', '>', newsyn)
    newsyn = re.sub('<SUP>', '<', newsyn)
    newsyn = re.sub('</SUP>', '>', newsyn)
    db.sql('update MGI_Synonym set synonym = "%s" where _Synonym_key = %s' % (newsyn, r['_Synonym_key']), None)

db.useOneConnection(0)

