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

db.useOneConnection(1)

inFile = open('AntibodyCompanyList.txt', 'r')
lineNum = 0
for line in inFile.readlines():
    lineNum = lineNum + 1
    tokens = line[:-1].split('\t')
    term = tokens[0]
    term = term.replace("'", "''")
    sql = "insert into voc_term values(nextval('voc_term_seq'), 179," + \
        "'" + term + "'" + \
        ",null,null," + str(lineNum) + ",null,1000,1000,now(),now())"
    #print(sql)
    db.sql(sql, None)

inFile.close()
db.commit()
db.useOneConnection(0)

