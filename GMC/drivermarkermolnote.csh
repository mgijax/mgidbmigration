#!/bin/csh -f

#
# driver notes
#
# non-mouse : marker = yes, mol note = yes
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

\echo '\tnon-mouse : marker = yes, mol note = yes'

WITH nonmouse AS (
select distinct a._allele_key, a.symbol, n._object_key, substring(c.note,1,25) as note, b.jnumID
from mgi_note n, mgi_notechunk c, all_allele a, mgi_reference_assoc r, bib_citation_cache b
where n._notetype_key = 1034 
and n._note_key = c._note_key
and n._object_key = a._allele_key
and a._allele_key = r._object_key
and r._mgitype_key = 11
and r._refassoctype_key in (1012)
and r._refs_key = b._refs_key
and (
	not exists (select 1 from mrk_marker m where c.note = m.symbol)
	or a._Allele_Type_key != 847116
	or a.symbol like 'Gt(ROSA)%'
	or a.symbol like 'Hprt<%'
	or a.symbol like 'Col1a1<%'
    )
)

(

--, cc.note
select distinct nm.symbol as allelesymbol, m.symbol, m._organism_key
from nonmouse nm, mrk_marker m, mgi_note nn, mgi_notechunk cc
where nm.note = m.symbol
and m._organism_key != 1
and nm._object_key = nn._object_key
and nn._notetype_key = 1021
and nn._note_key = cc._note_key

)
order by nm.symbol
;

EOSQL

date |tee -a $LOG

