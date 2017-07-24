#!/usr/local/bin/python

'''
#
# migration of bib_dataset/bib_dataset_assoc to bib_workflow_status, bib_workflow_tag
# for additional Tumor
#
'''
 
import sys 
import os
import db
import mgi_utils

db.setTrace()

wf_status = '%s|%s|%s|%s|1|1001|1001|%s|%s\n'

currentDate = mgi_utils.date('%m/%d/%Y')

#
# tumor
#
def tumor_status():

   wf_status_bcp = open('wf_status_tumor_more.bcp', 'w+')

   results = db.sql('select max(_Assoc_key) + 1 as nextAssocKey from BIB_Workflow_Status', 'auto')
   assocStatusKey = results[0]['nextAssocKey']

   counter = 0

   results = db.sql('''
        select r._Refs_key
	from BIB_Refs r
	where not exists (select 1 from BIB_Workflow_Status s
	        where s._Group_key = 31576667
		and r._Refs_key = s._Refs_key)
   	''', 'auto')
   for r in results:
      wf_status_bcp.write(wf_status % (assocStatusKey, r['_Refs_key'], tumorKey, notroutedKey, currentDate, currentDate))
      assocStatusKey += 1
      counter += 1
   print 'Tumor           | NOT ROUTED (other)| %d\n' % (counter)

   wf_status_bcp.close()
   
#
# Main
#

db.useOneConnection(1)

tumorKey = db.sql('''
select t._Term_key from VOC_Vocab v, VOC_Term t 
where v.name = 'Workflow Group' and v._Vocab_key = t._Vocab_key and t.term = 'Tumor'
''')[0]['_Term_key']

notroutedKey = db.sql('''
select t._Term_key from VOC_Vocab v, VOC_Term t 
where v.name = 'Workflow Status' and v._Vocab_key = t._Vocab_key and t.term = 'Not Routed'
''')[0]['_Term_key']

# Tumor
#
tumor_status()

db.useOneConnection(0)

