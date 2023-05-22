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

select isr._gellanestructure_key, isr._emapa_term_key, t1._vocab_key as badvoc, t1.term as term1, t2._vocab_key as goodvoc, t2._term_key, t2.term as term2
into temp table toupdate1
from GXD_GelLaneStructure isr, voc_term t1, voc_term t2
where isr._emapa_term_key = t1._term_key and t1._vocab_key = 91
and t1.term = t2.term
and t2._vocab_key = 90
order by t1.term
;

select isr._resultstructure_key, isr._emapa_term_key, t1._vocab_key as badvoc, t1.term as term1, t2._vocab_key as goodvoc, t2._term_key, t2.term as term2
into temp table toupdate2
from gxd_isresultstructure isr, voc_term t1, voc_term t2
where isr._emapa_term_key = t1._term_key and t1._vocab_key = 91
and t1.term = t2.term
and t2._vocab_key = 90
order by t1.term
;

select s.*, t1._vocab_key as badvoc, t1.term as term1, t2._vocab_key as goodvoc, t2._term_key, t2.term as term2
into temp table toupdate3
from mgi_setmember s, voc_term t1, voc_term t2
where s._object_key = t1._term_key and t1._vocab_key = 91
and s._set_key = 1046
and t1.term = t2.term
and t2._vocab_key = 90
order by t1.term
;

--GXD_HTSample_create.object:     _Emapa_key              int                     null,
select isr._sample_key, isr._emapa_key, t1._vocab_key as badvoc, t1.term as term1, t2._vocab_key as goodvoc, t2._term_key, t2.term as term2
into temp table toupdate4
from gxd_htsample isr, voc_term t1, voc_term t2
where isr._emapa_key = t1._term_key and t1._vocab_key = 91
and t1.term = t2.term
and t2._vocab_key = 90
order by t1.term
;

--GXD_HTSample_RNASeqSet_create.object:   _Emapa_key              int           

select isr._rnaseqset_key, isr._emapa_key, t1._vocab_key as badvoc, t1.term as term1, t2._vocab_key as goodvoc, t2._term_key, t2.term as term2
into temp table toupdate5
from gxd_htsample_rnaseqset isr, voc_term t1, voc_term t2
where isr._emapa_key = t1._term_key and t1._vocab_key = 91
and t1.term = t2.term
and t2._vocab_key = 90
order by t1.term
;

select * from toupdate1;
select * from toupdate2;

update GXD_GelLaneStructure isr
set _emapa_term_key = g._term_key
from toupdate1 g
where isr._gellanestructure_key = g._gellanestructure_key
;

update gxd_isresultstructure isr
set _emapa_term_key = g._term_key
from toupdate2 g
where isr._resultstructure_key = g._resultstructure_key
;

update mgi_setmember s
set _object_key = g._term_key
from toupdate3 g
where s._setmember_key = g._setmember_key
;

select isr._gellanestructure_key, isr._emapa_term_key, t1._vocab_key, t1.term
from GXD_GelLaneStructure isr, voc_term t1, toupdate1 g
where g._gellanestructure_key = isr._gellanestructure_key
and isr._emapa_term_key = t1._term_key
;

select isr._resultstructure_key, isr._emapa_term_key, t1._vocab_key, t1.term
from gxd_isresultstructure isr, voc_term t1, toupdate2 g
where g._resultstructure_key = isr._resultstructure_key
and isr._emapa_term_key = t1._term_key
;

select isr._gellanestructure_key, isr._emapa_term_key, t1._vocab_key as badvoc, t1.term as term1, t2._vocab_key as goodvoc, t2._term_key, t2.term as term2
from GXD_GelLaneStructure isr, voc_term t1, voc_term t2
where isr._emapa_term_key = t1._term_key and t1._vocab_key = 91
and t1.term = t2.term
and t2._vocab_key = 90
order by t1.term
;

select isr._resultstructure_key, isr._emapa_term_key, t1._vocab_key as badvoc, t1.term as term1, t2._vocab_key as goodvoc, t2._term_key, t2.term as term2
from gxd_isresultstructure isr, voc_term t1, voc_term t2
where isr._emapa_term_key = t1._term_key and t1._vocab_key = 91
and t1.term = t2.term
and t2._vocab_key = 90
order by t1.term
;

select s.*, t1._vocab_key as badvoc, t1.term as term1, t2._vocab_key as goodvoc, t2._term_key, t2.term as term2
from mgi_setmember s, voc_term t1, voc_term t2
where s._object_key = t1._term_key and t1._vocab_key = 91
and s._set_key = 1046
and t1.term = t2.term
and t2._vocab_key = 90
order by t1.term
;

EOSQL

${MGICACHELOAD}/gxdexpression.csh | tee -a $LOG

date |tee -a $LOG

