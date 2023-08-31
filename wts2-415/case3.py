#
#3. 
#Delete all 'no phenotypic analysis (MP:0003012)' annotations 
#Delete genotypes (unless annotated to another term)
#Example: Genotype MGI:3842698 involves: 129S1/SvImJ  Abcb1a<tm1Kane>/Abcb1a<+>
# 

import sys 
import os
import db

db.setTrace()

print('\n\ncase 3 start: delete all "no phenotypic analysis (MP:0003012)" annotations\n')

db.sql('''
select distinct a.accid, substring(n.note,1,100) as note, s.strain, c.jnumid, v._annot_key, g._genotype_key
into temp table annotations
from voc_annot v, voc_evidence e, 
bib_citation_cache c, gxd_genotype g, prb_strain s, mgi_note n,
acc_accession a
where v._annottype_key = 1002
and v._term_key = 293594
and v._annot_key = e._annot_key
and e._refs_key = c._refs_key
and v._object_key = g._genotype_key
and g._strain_key = s._strain_key
and g._genotype_key = n._object_key
and n._notetype_key = 1016
and g._genotype_key = a._object_key
and a._mgitype_key = 12
and a.prefixpart = 'MGI:'
and a._logicaldb_key = 1
and not exists (select 1 from voc_annot vv 
        where v._object_key = vv._object_key
        and vv._annottype_key = 1002
        and v._term_key = vv._term_key
        and vv._term_key != 293594
        )
order by note
''', None)

db.sql('''create index idx1 on annotations(_genotype_key)''', None)

aresults = db.sql('select * from annotations', 'auto')

deleteSQL = ''
for r in aresults:
        print(r)
        deleteSQL += "delete from voc_annot where _annot_key = " + str(r['_annot_key']) + ";\n"

print(deleteSQL)
print(len(aresults))
db.sql(deleteSQL, None)
db.commit()

gresults = db.sql('''
select a._genotype_key
from annotations a
where not exists (select 1 from voc_annot vv where a._genotype_key = vv._object_key and vv._annottype_key = 1002)
and not exists (select 1 from prb_strain_genotype vv where a._genotype_key = vv._genotype_key)
and not exists (select 1 from gxd_expression vv where a._genotype_key = vv._genotype_key)
and not exists (select 1 from gxd_htsample vv where a._genotype_key = vv._genotype_key)
''', 'auto')

deleteSQL = ''
for r in gresults:
        print(r)
        deleteSQL += "delete from gxd_genotype where _genotype_key = " + str(r['_genotype_key']) + ";\n"
print(deleteSQL)
print(len(gresults))
db.sql(deleteSQL, None)
db.commit()

results = db.sql('''
select distinct a.accid, substring(n.note,1,100) as note, s.strain, c.jnumid, v._annot_key, g._genotype_key
from voc_annot v, voc_evidence e, 
bib_citation_cache c, gxd_genotype g, prb_strain s, mgi_note n,
acc_accession a
where v._annottype_key = 1002
and v._term_key = 293594
and v._annot_key = e._annot_key
and e._refs_key = c._refs_key
and v._object_key = g._genotype_key
and g._strain_key = s._strain_key
and g._genotype_key = n._object_key
and n._notetype_key = 1016
and g._genotype_key = a._object_key
and a._mgitype_key = 12
and a.prefixpart = 'MGI:'
and a._logicaldb_key = 1
and not exists (select 1 from voc_annot vv 
        where v._object_key = vv._object_key
        and vv._annottype_key = 1002
        and v._term_key = vv._term_key
        and vv._term_key != 293594
        )
order by note
''', 'auto')
print(len(results))

print('\n\ncase 3 end: delete all "no phenotypic analysis (MP:0003012)" annotations\n\n')

