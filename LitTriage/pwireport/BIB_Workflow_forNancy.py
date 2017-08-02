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

group = 'AP'
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

print '''
	(
	select r.mgiID, r.journal, 1 as relevance
	from BIB_Refs r
	where r.journal in (%s)
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
		and wtt.term like '%s'
		)
	and not exists (select 1 from BIB_Workflow_Tag wt, VOC_Term wtt
		where r._Refs_key = wt._Refs_key
		and wt._Tag_key = wtt._Term_key
		and wtt.term in ('MGI:Discard', 'Tumor:NotSelected')
		)
	union
	select r.mgiID, r.journal, 2 as relevance
	from BIB_Refs r
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
	'''  % (masterjournals, ajournals, ojournals, gjournals, tjournals)

#for r in results:
#	print str(r) + '\n'


