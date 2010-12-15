#!/usr/local/bin/python

'''
#
# Report:
#       Enter TR # and describe report inputs/output
#
# History:
#
# lec	01/18/99
#	- created
#
'''
 
import os
import sys 
import string
import db
import reportlib

CRT = reportlib.CRT
SPACE = reportlib.SPACE
TAB = reportlib.TAB
PAGE = reportlib.PAGE

#
# Main
#

user = os.environ['MGD_DBUSER']
passwordFileName = os.environ['MGD_DBPASSWORDFILE']
db.set_sqlUser(user)
db.set_sqlPasswordFromFile(passwordFileName)

db.useOneConnection(1)

results = db.sql('''
select s.*
from GXD_Structure s, GXD_StructureName sn
where s._Structure_key = sn._Structure_key
and sn.mgiAdded = 1
and s.printName like "%#%"
''', 'auto')

for r in results:
    key = r['_Structure_key']
    name = r['printName']
    newname = string.replace(name, '#', '')
    db.sql('update GXD_Structure set printName = "%s" where _Structure_key = %s' \
	% (newname, key), None)

results = db.sql('''
select sn.*
from GXD_StructureName sn
where sn.mgiAdded = 1
and sn.structure like "%#%"
''', 'auto')

for r in results:
    key = r['_StructureName_key']
    name = r['structure']
    newname = string.replace(name, '#', '')
    db.sql('update GXD_StructureName set structure = "%s" where _StructureName_key = %s' \
	% (newname, key), None)

db.useOneConnection(0)

