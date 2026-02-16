import sys 
import os
import db

db.setTrace()

#
# Main
#

inFile = open('CellCopyrights.txt', 'r')
for line in inFile.readlines():
    tokens = line[:-1].split('\t')
    term = tokens[0]
    abbrev = tokens[1]
    defin = tokens[2]

    cmd = "insert into VOC_Term values(nextval('voc_term_seq'), 48, '%s', '%s', '%s', 1, 0, 1001, 1001, now(), now())" % (term, abbrev, defin)
    #print(cmd)
    db.sql(cmd, None)

inFile.close()
db.commit()

db.sql("select count(*) from VOC_resetTerms(48)", None)
db.commit()

