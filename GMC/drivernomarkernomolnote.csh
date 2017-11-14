#!/bin/csh -f

#
# driver notes
#
# non-mouse : marker = no, mol note = no
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

\echo 'non-mouse : marker = no, mol note = no'

WITH nonmouse AS (
select distinct a._allele_key, a.symbol, n._object_key, substring(c.note,1,25) as note
from mgi_note n, mgi_notechunk c, all_allele a
where n._notetype_key = 1034 
and n._note_key = c._note_key
and n._object_key = a._allele_key
and c.note not like 'unknown%'
and (
	not exists (select 1 from mrk_marker m where c.note = m.symbol)
        or a._Allele_Type_key != 847116
	or a.symbol like 'Gt(ROSA)%'
	or a.symbol like 'Hprt<%'
	or a.symbol like 'Col1a1<%'
    )
)

(

select distinct nm.symbol, nm.note, null, 0, null
from nonmouse nm
where not exists (select 1 from mrk_marker m where nm.note = m.symbol and m._organism_key != 1)
and not exists (select 1 from mgi_note nn where nm._object_key = nn._object_key and nn._notetype_key = 1021)

)
order by nm.symbol
;

EOSQL

date |tee -a $LOG

