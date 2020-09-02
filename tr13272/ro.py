import sys 
import os
import db

db.setTrace()

#
# Main
#

inFile = open('ro.txt', 'r')
for line in inFile.readlines():
        tokens = line[:-1].split('\t')
        roid = tokens[0]
        term = tokens[1]
        cmd = '''update voc_term set note = '%s' where _vocab_key = 82 and term = '%s' ''' % (roid, term)
        print(cmd)
        db.sql(cmd, None)

db.commit()

