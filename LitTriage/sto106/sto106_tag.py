#!/usr/local/bin/python

import sys 
import os
import db

db.setTrace()

inFile = open('/mgi/all/wts_projects/12200/12250/sto106/sto106TagsToAdd.txt', 'r')

for line in inFile.readlines():
   tokens = line[:-1].split('\t')

   pubmedID = tokens[0]
   tag = tokens[1]
   print pubmedID, tag

   results = db.sql('''
   	select r._Refs_key, r.pubmedID
	from BIB_Citation_Cache r
	where r.pubmedID = '%s'
	''' % (pubmedID), 'auto')
   for r in results:
      if tag == 'MGI:Discard':
        sql = 'update BIB_Refs set isDiscard = 1 where _Refs_key = %s' % (r['_Refs_key'])
      else:
         sql = '''
      	 insert into BIB_WorkFlow_Tag 
	 values((select max(_Assoc_key) + 1 from BIB_WorkFlow_Tag),
	 %s,
	 (select _Term_key from VOC_Term where _Vocab_key = 129 and term = '%s'),
	 1001,1001,now(),now())
	 ''' % (r['_Refs_key'], tag)
#      sql = '''
#  	delete from BIB_WorkFlow_Tag
#	where _Refs_key = %s
#	and _Tag_key = (select _Term_key from VOC_Term where _Vocab_key = 129 and term = '%s')
#	''' % (r['_Refs_key'], tag)
      print sql
      db.sql(sql, None)
      db.commit()

inFile.close()

