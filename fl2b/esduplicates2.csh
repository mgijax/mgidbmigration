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

select distinct rfv._relationship_key, rfv._object_key_1, rfv._object_key_2 as _marker_key, rfv._category_key, rfv.categoryterm, rfv.relationshipterm, rfv.qualifierterm, rfv.evidenceterm, a.accid as allelesymbol_id, rfv.allelesymbol, vt.term as allele_status, rfv.markersymbol, rfv.jnumid
INTO TEMP temp1
from MGI_Relationship_FEAR_View rfv, acc_accession a, all_allele al, voc_term vt
where a._logicaldb_key = 1
and a._mgitype_key = 11
and a.prefixpart = 'MGI:'
and rfv._category_key = 1004
and vt._vocab_key = 37
and a._object_key = rfv._object_key_1
and al._allele_key = rfv._object_key_1
and al._allele_status_key = vt._term_key
;

create index idx1 on temp1 (_relationship_key, _marker_key)
;

select distinct t1._relationship_key, t1.allelesymbol_id, t1.allelesymbol, t1.allele_status, t1._marker_key, mv.symbol, mv.commonname
into temp temp2
from temp1 t1, mrk_marker_view mv
where mv._organism_key != 1
and mv._marker_key = t1._marker_key
;

create index idx2 on temp2 (_marker_key)
;

select distinct _object_key as _marker_key, accid as ncbi_id
into temp temp3
from acc_accession
where _logicaldb_key = 55
and _mgitype_key = 2
;

create index idx3 on temp3 (_marker_key)
;

select distinct t2._relationship_key, t2.allelesymbol_id, t2.allelesymbol, t2.allele_status, t2.symbol, t3.ncbi_id, t2.commonname
into temp temp4
from temp2 t2
LEFT OUTER JOIN temp3 t3 on (t2._marker_key = t3._marker_key)
;

create index idx4 on temp4 (_relationship_key)
;

select distinct allelesymbol_id, allelesymbol, symbol, count(distinct _relationship_key) as relationships
into temp temp5
from temp4
group by allelesymbol_id, allelesymbol, symbol
having count(distinct _relationship_key) > 1
;

create index idx5 on temp5 (allelesymbol_id, allelesymbol)
;

select distinct t4._relationship_key, t5.allelesymbol_id, t5.allelesymbol, t4.allele_status, t5.symbol, t4.ncbi_id, t4.commonname
from temp4 t4, temp5 t5
where t4.allelesymbol_id = t5.allelesymbol_id
and t4.allelesymbol = t5.allelesymbol
and t4.symbol = t5.symbol
order by allelesymbol
;

select distinct min(t4._relationship_key) as keepKey, t5.allelesymbol_id, t5.allelesymbol, t4.allele_status, t5.symbol, t4.ncbi_id, t4.commonname
into temp temp6
from temp4 t4, temp5 t5
where t4.allelesymbol_id = t5.allelesymbol_id
and t4.allelesymbol = t5.allelesymbol
and t4.symbol = t5.symbol
group by t5.allelesymbol_id, t5.allelesymbol, t4.allele_status, t5.symbol, t4.ncbi_id, t4.commonname
order by allelesymbol
;

select temp4.*, temp6.* from temp4, temp6 
where temp4.allelesymbol_id = temp6.allelesymbol_id
and temp4._relationship_key != temp6.keepKey;
;

delete from mgi_relationship r using temp4, temp6 
where temp4.allelesymbol_id = temp6.allelesymbol_id
and temp4._relationship_key != temp6.keepKey
and temp4._relationship_key = r._relationship_key
;

EOSQL

