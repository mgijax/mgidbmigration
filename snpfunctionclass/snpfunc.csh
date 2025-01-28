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

--select _term_key, term from voc_term 
--where _vocab_key = 79
--and term in (
--'CTCF binding site',
--'enhancer',
--'histone modification',
--'imprinting control region',
--'insulator',
--'insulator binding site',
--'intronic regulatory region',
--'locus control region',
--'matrix attachment site',
--'open chromatin region',
--'origin of replication',
--'promoter',
--'promoter flanking region',
--'response element',
--'silencer',
--'splice enhancer',
--'transcriptional cis regulatory region',
--'transcription factor binding site'
--)
--;

-- SNP Function Class/49
--select t._term_key, t.term, a.accid 
--from voc_term t, acc_accession a 
--where t._vocab_key = 49
--and a._mgitype_key = 13
--and t._term_key = a._object_key
--;
--select _term_key, term from voc_term where _vocab_key = 79 order by term;
--select * from mgi_translation where _translationtype_key = 1014;
--select distinct s._fxn_key, t.term from snp.dp_snp_marker s, voc_term t where s._fxn_key = t._term_key;
--select distinct s._fxn_key, t.term from snp.snp_consensussnp_marker s, voc_term t where s._fxn_key = t._term_key;
--select t._term_key, t.term, s.badname, a.accid
--from voc_term t, mgi_translation s, acc_accession a
--where t._vocab_key = 49
--and s._translationtype_key = 1014
--and s._object_key = t._term_key
--and t._term_key = a._object_key
--and a._mgitype_key = 13
--;

EOSQL

# new translation
${PYTHON} translationload.py
${DBUTILS}/pgdbutilities/bin/bcpin.csh ${MGD_DBURL} ${MGD_DBNAME} MGI_Translation ${DBUTILS}/mgidbmigration/snpfunctionclass MGI_Translation.bcp "|" "\n" mgd
${MGD_DBSCHEMADIR}/autosequence/MGI_Translation_drop.object
${MGD_DBSCHEMADIR}/autosequence/MGI_Translation_create.object

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG
select t._term_key, t.term, s.badname, a.accid
from voc_term t, mgi_translation s, acc_accession a
where t._vocab_key = 49
and s._translationtype_key = 1014
and s._object_key = t._term_key
and t._term_key = a._object_key
and a._mgitype_key = 13
;

drop index if exists snp.SNP_ConsensusSnp_Marker_idx_consensussnp_key;

EOSQL

