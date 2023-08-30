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
 
#2. For references only associated with only genotypes annotated to 'no 
#phenotypic analysis (MP:0003012)', add PWI lit triage tag 
#'AP:NoPhenotypicAnalysis'. Many will already have been tagged. Can be done as a 
#manual clean-up by mnk if needed.

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG

#
# References
# annot type = MP/Genotype
# MP:0003012/no phenotypic analysis
#
select distinct c.jnumid, s.strain, c._refs_key
from voc_annot v, voc_evidence e, 
bib_citation_cache c, gxd_genotype g, prb_strain s
where v._annottype_key = 1002
and v._term_key = 293594
and v._annot_key = e._annot_key
and e._refs_key = c._refs_key
and v._object_key = g._genotype_key
and g._strain_key = s._strain_key
order by jnumid
;

EOSQL

date |tee -a $LOG

