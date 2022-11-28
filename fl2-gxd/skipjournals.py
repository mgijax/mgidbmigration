import sys 
import os
import db
import reportlib

db.setTrace()

db.useOneConnection(1)

inFile = open('skipJournals.txt', 'r')
seqNum = 1
#db.sql('delete from VOC_Term where _vocab_key = 184',None)
for line in inFile.readlines():
        term = line[:-1].replace("'","''")
        addSQL = '''
        insert into VOC_Term values(
        (select max(_Term_key) + 1 from VOC_Term),184,'%s',null,null,%d,0,1001,1001,now(),now());
        ''' % (term, seqNum)
        seqNum += 1
        print(addSQL)
        db.sql(addSQL, None)
        db.commit()
inFile.close()

db.useOneConnection(0)

