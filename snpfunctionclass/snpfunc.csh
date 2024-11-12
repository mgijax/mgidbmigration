#!/bin/csh -f

#
# snpcacheload/snpmarker.sh is only running snpmrkwithin.py, which is only using:
# uses SNP_Coord_Cache, MRK_Location_Cache to build new SNP_ConsensusSnp_Marker
# WITHIN_COORD_TERM = 'within coordinates of'
# WITHIN_KB_TERM = 'within distance of'
#
# e4g-68/Analysis: Alliance Molecular Consequence VCF file
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
 
cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG

-- SNP Function Class/49
select _term_key, term from voc_term where _vocab_key = 49;
select * from mgi_translation where _translationtype_key = 1014
--select distinct s._fxn_key, t.term from snp.dp_snp_marker s, voc_term t where s._fxn_key = t._term_key;
--select distinct s._fxn_key, t.term from snp.snp_consensussnp_marker s, voc_term t where s._fxn_key = t._term_key;

EOSQL

setenv SNPLOG snpalliance.log
setenv SNPTSV snpalliance.tsv
rm -rf $SNPLOG $SNPTSV Mrpl15
touch $SNPLOG
$PYTHON snpfunc.py > $SNPLOG
sort $SNPLOG | uniq > $SNPTSV
grep Mrpl15 $SNPTSV > Mrpl15
grep rs46043568 Mrpl15
cut -f1 -d"|" snpalliance.tsv | uniq | wc -l

date |tee -a $LOG

