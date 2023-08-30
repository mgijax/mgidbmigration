#
#
# 1. Change the reference type in the allele modules of all alleles in genotypes 
# annotated to 'no phenotypic analysis (MP:0003012)' for that publication to 'not 
# used'.
# Example: 
# J:207447 2 genotypes, genotype for allele Del(17)4Mom has annotation to no phenotypic analysis, 2 other genotypes have annotations 
# Change the reference type of J:207447/Del(17)4Mom allele record 
# from 'USED-FC' (_refassoctype_key=1017) to 'Not Used' (_refassoctype_key=1014)
#

import sys 
import os
import db

print('\n\ncase 1 start: Change the reference type from USED-FC to Not Used\n')

db.setTrace()

results = db.sql('''
select distinct c.jnumid, aa.symbol, mrt.assoctype, s.strain, mr._assoc_key
from voc_annot v, voc_evidence e, 
bib_citation_cache c, gxd_genotype g, prb_strain s, gxd_allelegenotype ga, all_allele aa,
mgi_reference_assoc mr, mgi_refassoctype mrt
where v._annottype_key = 1002
and v._term_key = 293594
and v._annot_key = e._annot_key
and e._refs_key = c._refs_key
and v._object_key = g._genotype_key
and g._strain_key = s._strain_key
and g._genotype_key = ga._genotype_key
and ga._allele_key = aa._allele_key
and aa._allele_key = mr._object_key
and mr._mgitype_key = 11
and e._refs_key = mr._refs_key
and mr._refassoctype_key = mrt._refassoctype_key
and mrt._refassoctype_key = 1017
order by c.jnumid, aa.symbol
''', 'auto')

updateSQL = ''
for r in results:
        print(r)
        updateSQL += "update mgi_reference_assoc set _refassoctype_key = 1014 where _assoc_key = " + str(r['_assoc_key']) + ";\n"

print(updateSQL)
#db.sql(updateSQL, None)
#db.commit()
print('\n\ncase 1 end: Change the reference type from USED-FC to Not Used\n\n')

