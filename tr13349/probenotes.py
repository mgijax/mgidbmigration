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

db.setTrace()

#
# Main
#

outFile = open('probenotes.txt', 'w')

results = db.sql('''
select a.accID, n.*
from prb_notes n, acc_accession a
where n._probe_key = a._object_key
and a._mgitype_key = 3
'''
, 'auto')

for r in results:
    note = r['note'].replace('\r', ' ')
    note = note.replace('\n', ' ')
    outFile.write(r['accID'] + '\t' + note + '\n')

outFile.close()

