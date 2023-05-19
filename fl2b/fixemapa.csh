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

select isr._resultstructure_key, isr._emapa_term_key, t1._vocab_key as badvoc, t1.term as term1, t2._vocab_key as goodvoc, t2._term_key, t2.term as term2
into temp table toupdate
from gxd_isresultstructure isr, voc_term t1, voc_term t2
where isr._emapa_term_key = t1._term_key and t1._vocab_key = 91
and t1.term = t2.term
and t2._vocab_key = 90
order by t1.term
;

select * from toupdate;

update gxd_isresultstructure isr
set _emapa_term_key = g._term_key
from toupdate g
where isr._resultstructure_key = g._resultstructure_key
;

select isr._resultstructure_key, isr._emapa_term_key, t1._vocab_key, t1.term
from gxd_isresultstructure isr, voc_term t1, toupdate g
where g._resultstructure_key = isr._resultstructure_key
and isr._emapa_term_key = t1._term_key
;

select isr._resultstructure_key, isr._emapa_term_key, t1._vocab_key as badvoc, t1.term as term1, t2._vocab_key as goodvoc, t2._term_key, t2.term as term2
from gxd_isresultstructure isr, voc_term t1, voc_term t2
where isr._emapa_term_key = t1._term_key and t1._vocab_key = 91
and t1.term = t2.term
and t2._vocab_key = 90
order by t1.term
;

EOSQL

date |tee -a $LOG

