#!/usr/local/bin/python

'''
#
# migration of bib_dataset/bib_dataset_assoc to bib_workflow_tag
# for additional Tumor
#
'''
 
import sys 
import os
import db
import mgi_utils

db.setTrace()

wf_tag = '%s|%s|%s|1001|1001|%s|%s\n'

currentDate = mgi_utils.date('%m/%d/%Y')

#
# tumor
#
def tumor_tag():

   wf_tag_bcp = open('wf_tag_tumor_notselected.bcp', 'w+')

   results = db.sql('select max(_Assoc_key) + 1 as nextAssocKey from BIB_Workflow_Tag', 'auto')
   assocStatusKey = results[0]['nextAssocKey']

   counter = 0

   results = db.sql('''
   	select _Refs_key from BIB_Workflow_Status where _Group_key = 31576667 and _Status_key = 31576669
	''', 'auto')
   for r in results:
      wf_tag_bcp.write(wf_tag % (assocStatusKey, r['_Refs_key'], tumorKey, currentDate, currentDate))
      assocStatusKey += 1
      counter += 1
   print 'Tumor           | Tumor:NotSelected | %d\n' % (counter)

   wf_tag_bcp.close()
   
#
# Main
#

db.useOneConnection(1)

tumorKey = db.sql('''
select t._Term_key from VOC_Vocab v, VOC_Term t 
where v.name = 'Workflow Tag' and v._Vocab_key = t._Vocab_key and t.term = 'Tumor:NotSelected'
''')[0]['_Term_key']

# Tumor
#
tumor_tag()

db.useOneConnection(0)

