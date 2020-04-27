#!/usr/local/bin/python
#
# Report:
#       Enter TR # and describe report inputs/output
#
# History:
#
# lec	01/18/99
#	- created
#
 
import sys 
import os
import db
import reportlib

db.setTrace()

CRT = reportlib.CRT
SPACE = reportlib.SPACE
TAB = reportlib.TAB
PAGE = reportlib.PAGE

#
# Main
#

db.useOneConnection(1)

inFile = open('UniProtKB_switch.txt', 'r')
for line in inFile.readlines():

    checkValue = line[:-1]

    cmd = '''
    select distinct m.symbol, e._annotevidence_key, e.inferredfrom
    from VOC_Annot a, VOC_Evidence e, MGI_User u, MRK_Marker m
    where a._annottype_key = 1000
    and a._annot_key = e._annot_key
    and e._evidenceterm_key = 111
    and e._createdby_key = u._user_key
    and u.login not like 'GOA%'
    and u.login not like 'NOCTUA%'
    and u.login not in ('uniprotload')
    and a._Object_key = m._Marker_key
    '''
    cmd = cmd + "and e.inferredfrom like '%" + checkValue + "%'"
    print(cmd)

    results = db.sql(cmd, 'auto')

    for r in results:
        print(r)
        key = r['_annotevidence_key']
        inferredfrom = r['inferredfrom']
        tokens = checkValue.split(':')
        ldb = tokens[0]
        id = tokens[1]
        newValue = 'PR:' + id
        inferredfrom = inferredfrom.replace(checkValue, newValue)
        sql = '''update VOC_Evidence set inferredfrom = '%s' where _annotevidence_key = %s''' % (inferredfrom, key)
        print(sql)
        db.sql(sql)
        db.commit()

inFile.close()
db.useOneConnection(0)

