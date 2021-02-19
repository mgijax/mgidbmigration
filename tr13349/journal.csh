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

--select distinct r.journal, n.*, t.*, c.note
select distinct r.journal
from BIB_Refs r, VOC_Term t, MGI_Note n, MGI_NoteChunk c
where n._NoteType_key = 1026
and n._MGIType_key = 13
and n._Note_key = c._Note_key
and n._Object_key = t._Term_key
and t._Vocab_key = 48
and t.term = r.journal
order by r.journal
;

-- copy note to term/abbreviation
update VOC_Term t
set abbreviation = c.note
from MGI_Note n, MGI_NoteChunk c
where n._NoteType_key = 1026
and n._MGIType_key = 13
and n._Note_key = c._Note_key
and n._Object_key = t._Term_key
;

-- remove _notetype_key = 1026
delete from MGI_Note where _NoteType_key = 1026;
delete from MGI_NoteType where _NoteType_key = 1026;
-- remove procedure/BIB_getCopyright
DROP FUNCTION IF EXISTS BIB_getCopyright(int);

EOSQL

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG
select term, abbreviation, note
from voc_term
where _vocab_key = 48
order by term
;

--FOR TESTING ONLY/TO REMOVE NEW TERMS
--delete from voc_term where _vocab_key = 48 and _term_key >= 75601550;

EOSQL

$PYTHON journal.py | tee -a $LOG

date |tee -a $LOG

