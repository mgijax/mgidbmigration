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
db.sql('delete from VOC_Term where _vocab_key = 135',None)
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

inFile = open('ageExclude.txt', 'r')
seqNum = 1
db.sql('delete from VOC_Term where _vocab_key = 181',None)
for line in inFile.readlines():
	term = line[:-1].replace("'","''")
	addSQL = '''
	insert into VOC_Term values(
	(select max(_Term_key) + 1 from VOC_Term),181,'%s',null,null,%d,0,1001,1001,now(),now());
	''' % (term, seqNum)
	seqNum += 1
	print(addSQL)
	db.sql(addSQL, None)
	db.commit()
inFile.close()

inFile = open('cat2Exclude.txt', 'r')
seqNum = 1
db.sql('delete from VOC_Term where _vocab_key = 182',None)
for line in inFile.readlines():
	term = line[:-1].replace("'","''")
	addSQL = '''
	insert into VOC_Term values(
	(select max(_Term_key) + 1 from VOC_Term),182,'%s',null,null,%d,0,1001,1001,now(),now());
	''' % (term, seqNum)
	seqNum += 1
	print(addSQL)
	db.sql(addSQL, None)
	db.commit()
inFile.close()

inFile = open('cat2Terms.txt', 'r')
seqNum = 1
db.sql('delete from VOC_Term where _vocab_key = 183',None)
for line in inFile.readlines():
	term = line[:-1].replace("'","''")
	addSQL = '''
	insert into VOC_Term values(
	(select max(_Term_key) + 1 from VOC_Term),183,'%s',null,null,%d,0,1001,1001,now(),now());
	''' % (term, seqNum)
	seqNum += 1
	print(addSQL)
	db.sql(addSQL, None)
	db.commit()
inFile.close()

db.useOneConnection(0)

