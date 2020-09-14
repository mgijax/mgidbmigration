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

select t.term, n._note_key, n._notetype_key, c.note
into toUpdate
from MGI_Note n, VOC_Term t, MGI_NoteChunk c
where n._notetype_key = 1001
and n._Object_key = t._Term_key
and t._Vocab_key = 5
and n._note_key = c._note_key
order by t.term
;

update MGI_Note
set _notetype_key = 1000
from toUpdate
where toUpdate._note_key = MGI_Note._note_key
;

select t.term, n._note_key, n._notetype_key, c.note
from MGI_Note n, VOC_Term t, MGI_NoteChunk c
where n._notetype_key = 1000
and n._Object_key = t._Term_key
and t._Vocab_key = 5
and n._note_key = c._note_key
order by t.term
;

EOSQL

date |tee -a $LOG

