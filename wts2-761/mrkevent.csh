#!/bin/csh -f

#
# merge single table vocabularies to voc_vocab/voc_term
#
# 1. make backups
# 2. drop foreign keys
# 3. add any new voc_vocab
# 4. call vocab.py; add new terms to voc_term; move old key to new voc_term._term_key
# 5. drop old single tables
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
 
${PG_DBUTILS}/bin/dumpTableData.csh ${MGD_DBSERVER} ${MGD_DBNAME} mgd MRK_History ${MGI_LIVE}/dbutils/mgidbmigration/wts2-761/MRK_History.bcp "|"

#remove after new production backup is available
cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG
delete from VOC_Term where _vocab_key in (33,34);
update voc_vocab set name = 'Marker Event' where _vocab_key = 33;
update voc_vocab set name = 'Marker Event Reason' where _vocab_key = 34;
insert into VOC_Term values(106563602, 33, 'Not Specified', null, null, 1, 0, 1001, 1001, now(), now());
insert into VOC_Term values(106563603, 33, 'Not Applicable', null, null, 2, 0, 1001, 1001, now(), now());
insert into VOC_Term values(106563604, 33, 'assigned', null, null, 3, 0, 1001, 1001, now(), now());
insert into VOC_Term values(106563605, 33, 'rename', null, null, 4, 0, 1001, 1001, now(), now());
insert into VOC_Term values(106563606, 33, 'merged', null, null, 5, 0, 1001, 1001, now(), now());
insert into VOC_Term values(106563607, 33, 'allele of', null, null, 6, 0, 1001, 1001, now(), now());
insert into VOC_Term values(106563608, 33, 'split', null, null, 7, 0, 1001, 1001, now(), now());
insert into VOC_Term values(106563609, 33, 'deleted', null, null, 8, 0, 1001, 1001, now(), now());
insert into VOC_Term values(106563610, 34, 'Not Specified', null, null, 1, 0, 1001, 1001, now(), now());
insert into VOC_Term values(106563611, 34, 'Not Applicable', null, null, 2, 0, 1001, 1001, now(), now());
insert into VOC_Term values(106563612, 34, 'per gene family revision', null, null, 3, 0, 1001, 1001, now(), now());
insert into VOC_Term values(106563613, 34, 'sequence removed by provider', null, null, 4, 0, 1001, 1001, now(), now());
insert into VOC_Term values(106563614, 34, 'problematic sequences', null, null, 5, 0, 1001, 1001, now(), now());
insert into VOC_Term values(106563615, 34, 'to conform w/nomen guidelines', null, null, 6, 0, 1001, 1001, now(), now());
insert into VOC_Term values(106563616, 34, 'to conform w/human', null, null, 7, 0, 1001, 1001, now(), now());
insert into VOC_Term values(106563617, 34, 'personal comm w/authors', null, null, 8, 0, 1001, 1001, now(), now());
insert into VOC_Term values(106563618, 34, 'personal comm w/expert', null, null, 9, 0, 1001, 1001, now(), now());
EOSQL

# drop foreign key contraints
cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG

ALTER TABLE mgd.MRK_History DROP CONSTRAINT MRK_History__Marker_Event_key_fkey CASCADE;
ALTER TABLE mgd.MRK_History DROP CONSTRAINT MRK_History__Marker_EventReason_key_fkey CASCADE;

update MRK_History m
set _marker_event_key = t._term_key
from MRK_Event e, VOC_Term t
where m._marker_event_key = e._marker_event_key
and e.event = t.term
and t._vocab_key = 33
;

update MRK_History m
set _marker_eventreason_key = t._term_key
from MRK_EventReason e, VOC_Term t
where m._marker_eventreason_key = e._marker_eventreason_key
and e.eventreason = t.term
and t._vocab_key = 34
;

EOSQL

${PG_MGD_DBSCHEMADIR}/key/VOC_Term_drop.object | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/key/VOC_Term_create.object | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/view/MRK_History_View_create.object | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/procedure/MRK_insertHistory_create.objectMRK_History_View_create.object | tee -a $LOG

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG
drop table mgd.MRK_Event;
drop table mgd.MRK_EventReason;
EOSQL

${PG_MGD_DBSCHEMADIR}/objectCounter.sh | tee -a $LOG

date |tee -a $LOG

