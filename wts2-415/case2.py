#
# 2. For references only associated with only genotypes annotated to 'no 
# phenotypic analysis (MP:0003012)', add PWI lit triage tag 
# 'AP:NoPhenotypicAnalysis'. Many will already have been tagged. Can be done as a 
# manual clean-up by mnk if needed.
# 
# Example:
# J:133638 - 2 genotypes both annotated to no phenotypic analysis
# 

import sys 
import os
import db

db.setTrace()

print('\n\ncase 2 start: add PWI lit triage tag AP:NoPhenotypicAnalysis\n')

results = db.sql('''
select distinct c.jnumid, s.strain, c._refs_key
from voc_annot v, voc_evidence e, 
bib_citation_cache c, gxd_genotype g, prb_strain s
where v._annottype_key = 1002
and v._term_key = 293594
and v._annot_key = e._annot_key
and e._refs_key = c._refs_key
and v._object_key = g._genotype_key
and g._strain_key = s._strain_key
and not exists (select 1 from BIB_Workflow_Tag tg where c._refs_key = tg._refs_key and tg._tag_key = 31576706)
order by jnumid
''', 'auto')

addSQL = ''
for r in results:
        addSQL += "insert into BIB_Workflow_Tag values(nextval('bib_workflow_tag_seq')," + str(r['_refs_key']) + ", 31576706, 1001, 1001, now(), now());\n"

print(addSQL)
#db.sql(addSQL, None)
#db.commit()
print(len(results))

print('\n\ncase 2 end: add PWI lit triage tag AP:NoPhenotypicAnalysis\n')
