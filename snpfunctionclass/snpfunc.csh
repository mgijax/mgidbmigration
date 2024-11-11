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
--select distinct s._fxn_key, t.term from snp.dp_snp_marker s, voc_term t where s._fxn_key = t._term_key;
--select distinct s._fxn_key, t.term from snp.snp_consensussnp_marker s, voc_term t where s._fxn_key = t._term_key;

-- SNP Function Class/50
--select _term_key, term  from voc_term where _vocab_key = 50;
--select distinct s._varclass_key, t.term from snp.snp_coord_cache s, voc_term t where s._varclass_key = t._term_key;
--select distinct s._varclass_key, t.term from snp.snp_consensussnp s, voc_term t where s._varclass_key = t._term_key;
--select distinct s._varclass_key, t.term from snp.snp_subsnp s, voc_term t where s._varclass_key = t._term_key;

-- SNP Submitter Handle/51
--select _term-key, term from voc_term where _vocab_key = 51;
--select distinct s._snphandle_key, t.term from snp.snp_subsnp s, voc_term t where s._subhandle_key = t._term_key;
--select distinct s._snphandle_key, t.term from snp.snp_population s, voc_term t where s._subhandle_key = t._term_key;

EOSQL

$PYTHON snpfunc.py | tee -a $LOG

date |tee -a $LOG

