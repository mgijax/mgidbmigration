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

select n._notetype_key, n._object_key, t.term, c.note 
from mgi_note n, mgi_notechunk c , voc_term t
where n._notetype_key = 1026 
and n._note_key = c._note_key
and c.note like '%Elsevier%'
and n._object_key = t._term_key
;

update mgi_notechunk c
set note = 'Reprinted with permission from Elsevier from \DXDOI(||) \Elsevier(||).'
from mgi_note n
where n._notetype_key = 1026 
and n._note_key = c._note_key
and c.note like '%Elsevier%'
;

select n._notetype_key, n._object_key, t.term, c.note 
from mgi_note n, mgi_notechunk c , voc_term t
where n._notetype_key = 1026 
and n._note_key = c._note_key
and c.note like '%Elsevier%'
and n._object_key = t._term_key
;

EOSQL

${PG_MGD_DBSCHEMADIR}/procedure/BIB_getCopyright_create.object | tee -a $LOG

date |tee -a $LOG

