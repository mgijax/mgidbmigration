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

inFile = open('cat1Exclude.txt', 'r')
seqNum = 1
for line in inFile.readlines():
	term = line[:-1].replace("'","''")
	addSQL = '''
	insert into VOC_Term values(
	(select max(_Term_key) + 1 from VOC_Term),135,'%s',null,null,%d,0,1001,1001,now(),now());
	''' % (term, seqNum)
	seqNum += 1
	print(addSQL)
	db.sql(addSQL, None)
	db.commit()
inFile.close()

#(select _Vocab_key from VOC_Vocab where name = 'Workflow Tag'),'%s',null,null,%d,0,1001,1001,now(),now());

db.useOneConnection(0)

