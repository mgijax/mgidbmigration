#!/bin/csh -f

if ( ${?MGICONFIG} == 0 ) then
        setenv MGICONFIG /usr/local/mgi/live/mgiconfig
endif

source ${MGICONFIG}/master.config.csh

cd `dirname $0`

setenv LOG $0.log
rm -rf $LOG
touch $LOG
 
date | tee -a $LOG
 
# Change the reference type in the allele modules of all alleles in genotypes 
# annotated to 'no phenotypic analysis (MP:0003012)' for that publication to 'not used'.`

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG

--
-- Allele/Reference assoc = USED-FC
-- annot type = MP/Genotype
-- MP:0003012/no phenotypic analysis
--
select distinct c.jnumid, aa.symbol, aa.iswildtype, mrt.assoctype, s.strain, mr._assoc_key
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
order by aa.iswildtype, c.jnumid, aa.symbol
;

EOSQL

date |tee -a $LOG

