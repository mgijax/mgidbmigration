#!/bin/csh -f

#
# driver notes
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

select distinct m._organism_key, m._marker_key, a._marker_key, m.symbol, a._allele_key, a.symbol, substring(c.note,1,25)
from mgi_note n, mgi_notechunk c, mrk_marker m, all_allele a
where n._notetype_key = 1034 
and n._note_key = c._note_key
and c.note = m.symbol
and m._organism_key = 1
and n._object_key = a._allele_key
and a._Allele_Type_key = 847116
and a.symbol not like 'Gt(ROSA)%'
and a.symbol not like 'Hprt<%'
and a.symbol not like 'Col1a1<%'
order by m.symbol, m._organism_key
;

EOSQL

date |tee -a $LOG

