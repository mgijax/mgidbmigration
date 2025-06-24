#
#
# 1. If a PMID has an associated done HT Index Experiment, its GXDHT LitTriage status should = Indexed.
#
# 2. If a PMID has been set to GXDHT=Indexed and it is not done, then its status should be changed to Chosen.
#
# 3. PMIDs whose GXDHT status=Not Routed should be set to New. 
# (This is because this data type is not included in the LitTriage Classifier;
# I picked an incorrect status when we set the system up originally.)
#
# 4. There are PMIDs whose current GXDHT status = Chosen.
# Some will become Indexed when you do the cleanup; otherwise leave them alone; Chosen is a perfectly acceptable status.
#
# 5. None of the other GXDHT statuses --Routed, Full-Coded, Rejected--should be in use.
#
# Just run 1 & 3
#
 
import sys 
import os
import db

db.setTrace()

updateSQL1 = ""
updateSQL3 = ""

# If a PMID has an associated done HT Index Experiment, its GXDHT LitTriage status should = Indexed.
query1 = '''
select c._refs_key, c.pubmedid, c.jnumid, a.accid, t1.term as curationStatus, t2.term as workflowStatus
from GXD_HTExperiment e, MGI_Property p, BIB_Citation_Cache c, BIB_Workflow_Status b, ACC_Accession a, VOC_Term t1, VOC_Term t2
where e._CurationState_key = 20475421
and e._Experiment_key = p._Object_key
and p._mgitype_key = 42
and p._propertyterm_key = 20475430
and p.value = c.pubmedid
and c._refs_key = b._refs_key
and b.isCurrent = 1
and b._Group_key = 114000000
and b._Status_key != 31576673
and e._Experiment_key = a._object_key and a._mgitype_key = 42
and e._CurationState_key = t1._term_key
and b._Status_key = t2._term_key
'''
results = db.sql(query1, 'auto')

print('\n\n1: If a PMID has an associated done HT Index Experiment, its GXDHT LitTriage status should = Indexed')
print('rows:', str(len(results)))
for r in results:
    print(r)
    key = r['_refs_key']
    updateSQL1 += '''update BIB_Workflow_Status w set isCurrent = 0 where w._Group_key = 114000000 and w._refs_key = %s;\n''' % (key)
    updateSQL1 += '''insert into BIB_Workflow_Status values(nextval('bib_workflow_status_seq'),%s,114000000,31576673,1,1001,1001,now(),now());\n''' % (key)

query2 = '''
select c._refs_key, c.pubmedid, c.jnumid, a.accid, t1.term as curationStatus, t2.term as workflowStatus
from GXD_HTExperiment e, MGI_Property p, BIB_Citation_Cache c, BIB_Workflow_Status b, ACC_Accession a, VOC_Term t1, VOC_Term t2
where e._CurationState_key != 20475421
and e._Experiment_key = p._Object_key
and p._mgitype_key = 42
and p._propertyterm_key = 20475430
and p.value = c.pubmedid
and c._refs_key = b._refs_key
and b.isCurrent = 1
and b._Group_key = 114000000
and b._Status_key = 31576673
and e._Experiment_key = a._object_key and a._mgitype_key = 42
and e._CurationState_key = t1._term_key
and b._Status_key = t2._term_key
'''
results = db.sql(query2, 'auto')

print('\n\n2: If a PMID has been set to GXDHT=Indexed and it is not done, then its status should be changed to Chosen.')
print('rows:', str(len(results)))

for r in results:
    print(r)

# PMIDs whose GXDHT status=Not Routed should be set to New. 
# (This is because this data type is not included in the LitTriage Classifier;
# I picked an incorrect status when we set the system up originally.)
query3 = '''
select c._refs_key, c.pubmedid, c.jnumid, a.accid, t1.term as curationStatus, t2.term as workflowStatus
from GXD_HTExperiment e, MGI_Property p, BIB_Citation_Cache c, BIB_Workflow_Status b, ACC_Accession a, VOC_Term t1, VOC_Term t2
where e._Experiment_key = p._Object_key
and p._mgitype_key = 42
and p._propertyterm_key = 20475430
and p.value = c.pubmedid
and c._refs_key = b._refs_key
and b.isCurrent = 1
and b._Group_key = 114000000
and b._Status_key = 31576669
and e._Experiment_key = a._object_key and a._mgitype_key = 42
and e._CurationState_key = t1._term_key
and b._Status_key = t2._term_key
'''
results = db.sql(query3, 'auto')

print('\n\n3: PMIDs whose GXDHT status=Not Routed should be set to New.')
print('rows:', str(len(results)))

for r in results:
    print(r)
    key = r['_refs_key']
    updateSQL3 += '''update BIB_Workflow_Status w set isCurrent = 0 where w._Group_key = 114000000 and w._refs_key = %s;\n''' % (key)
    updateSQL3 += '''insert into BIB_Workflow_Status values(nextval('bib_workflow_status_seq'),%s,114000000,71027551,1,1001,1001,now(),now());\n''' % (key)

if len(updateSQL1) > 0:
    print(updateSQL1)
    db.sql(updateSQL1, None)
    db.commit()
if len(updateSQL3) > 0:
    print(updateSQL3)
    db.sql(updateSQL3, None)
    db.commit()

results = db.sql(query1, 'auto')
print('\n\n1: If a PMID has an associated done HT Index Experiment, its GXDHT LitTriage status should = Indexed')
print('rows:', str(len(results)))
results = db.sql(query2, 'auto')
print('\n\n2: If a PMID has been set to GXDHT=Indexed and it is not done, then its status should be changed to Chosen.')
print('rows:', str(len(results)))
results = db.sql(query3, 'auto')
print('\n\n3: PMIDs whose GXDHT status=Not Routed should be set to New.')
print('rows:', str(len(results)))
