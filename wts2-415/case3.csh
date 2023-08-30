#!/bin/csh -f

#
# Template
#


if ( ${?MGICONFIG} == 0 ) then
        setenv MGICONFIG /usr/local/mgi/live/mgiconfig
endif

source ${MGICONFIG}/master.config.csh

cd `dirname $0`

setenv LOG $0.log
rm -rf $LOG
touch $LOG
 
date | tee -a $LOG
 
#3. Delete all 'no phenotypic analysis (MP:0003012)' annotations and genotypes 
#unless annotated to another term.
#The list is available in the database https://www.informatics.jax.org/mp/annotations/MP:0003012
#Example: Genotype MGI:3842698 involves: 129S1/SvImJ  Abcb1a<tm1Kane>/Abcb1a<+>

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG

#
# annot type = MP/Genotype
# only contains annotations to MP:0003012/no phenotypic analysis
#
select distinct a.accid, substring(n.note,1,100) as note, s.strain, c.jnumid
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
;

EOSQL

date |tee -a $LOG

