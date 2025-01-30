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
 
cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG

select m.chromosome, m.symbol, a.accid, a._logicaldb_key, t.term, s.*
from MRK_Marker m, SNP_ConsensusSnp_Marker s, SNP_Accession a, voc_term t
where s._marker_key = m._marker_key
and s._consensussnp_key = a._object_key
and a._mgitype_key = 30
and a.accid in ('rs45635990')
and s._fxn_key = t._term_key
order by m.symbol, a.accid
;

select m._marker_key, s._consensussnp_key, m.chromosome, m.symbol, ma.accid, a.accid
from MRK_Marker m, zSNP_ConsensusSnp_Marker s, SNP_Accession a, ACC_Accession ma
where s._marker_key = m._marker_key
and m.chromosome = 'Y'
and s._consensussnp_key = a._object_key
and a._mgitype_key = 30
and m._marker_key = ma._object_key
and ma._mgitype_key = 2
and ma._logicaldb_key = 1
and ma.preferred = 1
and not exists (select 1 from SNP_ConsensusSnp_Marker ss
	where s._consensussnp_key = ss._consensussnp_key
	and s._marker_key = ss._marker_key
	)
;

EOSQL

