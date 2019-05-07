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

select t.term, c.note
from mgi_note n, mgi_notechunk c, voc_term t
where n._notetype_key = 1026
and n._note_key = c._note_key
and n._object_key = t._term_key
;

select r.jnumID, t.term, c.note
from mgi_note n, mgi_notechunk c, voc_term t, bib_citation_cache r
where n._notetype_key = 1026
and n._note_key = c._note_key
and n._object_key = t._term_key
and t.term = r.journal
limit 10
;

EOSQL

date |tee -a $LOG

