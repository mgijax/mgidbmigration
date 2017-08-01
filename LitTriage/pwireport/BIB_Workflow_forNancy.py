#!/usr/local/bin/python

'''
#
# BIB_Workflow_forNancy.py
#
# Report:
#
# History:
#
# 07/21/2017	lec
#       - TR12250/Lit Triage
#
#
'''
 
import sys 
import os
import db

db.setTrace()

apJournals = [
'Nat Neurosci',
'Neurobiol Aging',
'Neuroscience'
]

goJournals = [
'J Biol Chem',
'Biochem J'
]

gxdJournals = [
'Development',
'Dev Biol',
'Dev Dyn',
'Mech Dev',
'Genes Dev',
'Gene Expr Patterns',
'Dev Cell',
'BMC Dev Biol'
]

tumorJournals= [
'Cancer Cell',
'Cancer Discov',
'Cancer Lett',
'Cancer Res',
'Carcinogenesis',
'Int J Cancer',
'J Natl Cancer Inst',
'Leukemia',
'Mol Cancer Res',
'Nat Rev Cancer',
'Oncogene',
'Semi Cancer Biol'
]

#
# Main
#

ajournals = '\'' + '\',\''.join(apJournals) + '\''
ojournals = '\'' + '\',\''.join(goJournals) + '\''
gjournals = '\'' + '\',\''.join(gxdJournals) + '\''
tjournals = '\'' + '\',\''.join(tumorJournals) + '\''

curatorExclude = 'MGI:curator_%'
discardExclude = 'MGI:Discard'
notSelectedExclude = 'Tumor:NotSelected'

countQuery = '''
	select '%s' as group, count(distinct r._Refs_key) as rCount
	from BIB_Citation_Cache r, BIB_Workflow_Status ws, MGI_User u, VOC_Term wst, VOC_Term gt
	where u._Group_key = ws._Group_key
	and ws._Refs_key = r._Refs_Key
	and r.journal in (%s)
	and ws._Status_key = wst._Term_key
	and wst.term in ('Not Routed')
	and u._Group_key = gt._Term_key
	and gt.abbreviation = '%s'
	and not exists (select 1 from BIB_Workflow_Tag wt, VOC_Term wtt
		where r._Refs_key = wt._Refs_key
		and wt._Tag_key = wtt._Term_key
		and wtt.term like '%s'
		)
	and not exists (select 1 from BIB_Workflow_Tag wt, VOC_Term wtt
		where r._Refs_key = wt._Refs_key
		and wt._Tag_key = wtt._Term_key
		and wtt.term in ('MGI:Discard', 'Tumor:NotSelected')
		)
	'''

fullQuery = countQuery % ('AP', ajournals, 'AP', curatorExclude)
fullQuery += '\nunion\n'
fullQuery += countQuery % ('GXD', gjournals, 'GXD', curatorExclude)
fullQuery += '\nunion\n'
fullQuery += countQuery % ('GO', ojournals, 'GO', curatorExclude)
fullQuery += '\nunion\n'
fullQuery += countQuery % ('Tumor', tjournals, 'Tumor', curatorExclude)
#print fullQuery

login = 'jfinger'
#login = 'csmith'
#login = 'dph'
#login = 'dmk'
results = db.sql('''
	select t._Term_key, t.abbreviation 
	from MGI_User u, VOC_Term t
	where u.login = '%s'
	and u._Group_key = t._Term_key
	''' % (login), 'auto')
for r in results:
    groupKey = r['_Term_key']
    group = r['abbreviation']

if group == 'AP':
    masterjournals = ajournals
elif group == 'GXD':
    masterjournals = gjournals
elif group == 'GO':
    masterjournals = ojournals
elif group == 'Tumor':
    masterjournals = tjournals
elif group == 'QTL':
    masterjournals = 'None'

#results = db.sql('''
print '''
	(
	select r.mgiID, r.journal, 1 as relevance
	from BIB_Citation_Cache r
	where r.journal in (%s)
	and exists (select 1 from BIB_Workflow_Status ws, VOC_Term wst
		where r._Refs_key = ws._Refs_Key
		and ws._Status_key = wst._Term_key
		and wst.term in ('Not Routed')
		and ws._Group_key = %s
		)
	and not exists (select 1 from BIB_Workflow_Tag wt, VOC_Term wtt
		where r._Refs_key = wt._Refs_key
		and wt._Tag_key = wtt._Term_key
		and wtt.term like '%s'
		)
	and not exists (select 1 from BIB_Workflow_Tag wt, VOC_Term wtt
		where r._Refs_key = wt._Refs_key
		and wt._Tag_key = wtt._Term_key
		and wtt.term in ('MGI:Discard', 'Tumor:NotSelected')
		)
	union
	select r.mgiID, r.journal, 2 as relevance
	from BIB_Citation_Cache r
	where r.journal not in (%s)
	and r.journal not in (%s)
	and r.journal not in (%s)
	and r.journal not in (%s)
	and exists (select ws._Refs_key from BIB_Workflow_Status ws, VOC_Term wst
		where r._Refs_key = ws._Refs_Key
		and ws._Status_key = wst._Term_key
		and wst.term in ('Not Routed')
		and ws.isCurrent = 1
		group by _Refs_key having count(*) = 5
		)
	and not exists (select 1 from BIB_Workflow_Tag wt, VOC_Term wtt
		where r._Refs_key = wt._Refs_key
		and wt._Tag_key = wtt._Term_key
		and lower(wtt.term) like 'mgi:curator_%'
		)
	and not exists (select 1 from BIB_Workflow_Tag wt, VOC_Term wtt
		where r._Refs_key = wt._Refs_key
		and wt._Tag_key = wtt._Term_key
		and lower(wtt.term) in ('mgi:discard')
		)
	)
	order by revelance, mgiID
	limit 200
	'''  % (masterjournals, groupKey, curatorExclude, ajournals, ojournals, gjournals, tjournals, curatorExclude)
#	'''  % (masterjournals, groupKey, curatorExclude, ajournals, ojournals, gjournals, tjournals, curatorExclude), 'auto')

#for r in results:
#	print str(r) + '\n'


