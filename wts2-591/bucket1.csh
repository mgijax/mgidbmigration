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

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG
 
\echo '\nbucket 1: simple'
\echo '\n1. marker type != Transgene'
\echo '\n2. marker != Gt(ROSA)26Sor, Col1a1, Hprt'
\echo '\n3. no Relationships/Expresses Component'
\echo '\nexample: Pten<tm1Hwu>'
\echo '\n\n'

select 
a.symbol as alleleSymbol, a1.accid as alleleID,
m.symbol as markerSymbol, a2.accid as markerID,
substring(t.term,1,50) as doTerm, a3.accid as doID,
b.jnumid, b.short_citation

from all_allele a, acc_accession a1,
mrk_marker m, acc_accession a2,
voc_annot va, voc_evidence e, voc_term t, acc_accession a3,
bib_citation_cache b

where a._allele_key = a1._object_key
and a1._mgitype_key = 11
and a1._logicaldb_key = 1
and a1.preferred = 1
and a1.prefixPart = 'MGI:'

and a._marker_key not in (1092, 37270, 1647950)
and a._marker_key = m._marker_key
and m._marker_key = a2._object_key
and a2._mgitype_key = 2
and a2._logicaldb_key = 1
and a2.preferred = 1
and a2.prefixPart = 'MGI:'
and m._marker_type_key != 12

and a._allele_key = va._object_key
and va._annottype_key = 1021
and va._annot_key = e._annot_key

and va._term_key = a3._object_key
and a3._mgitype_key = 13
and a3._logicaldb_key = 191
and a3.preferred = 1
and va._term_key = t._term_key

and e._refs_key = b._refs_key

-- allele does not have a mgi_relationship
and not exists (select 1 from mgi_relationship mr where a._allele_key = mr._object_key_1 and mr._category_key in (1004))

--and a.symbol in ('Pten<tm1Hwu>', 'Gt(ROSA)26Sor<tm1(CAG-Kcnj11*,-GFP)Nich>')

order by a.symbol, b.jnumid
;

EOSQL

date |tee -a $LOG

