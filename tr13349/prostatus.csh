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

-- add new group 'PRO'
--insert into VOC_Term values(nextval('voc_term_seq'), 127, 'PRO', 'PRO', null, 1, 0, 1001, 1001, now(), now());

--  set of distinct GO Status with MGI:PRO tags
--
--  should be:  Chosen/MGI:PRO_selected, Full-coded/MGI:PRO_used
--
--  31576671 | Chosen     |  34693808 | MGI:PRO_selected        correct
--  31576671 | Chosen     |  31576693 | MGI:PRO_used
--  31576674 | Full-coded |  34693808 | MGI:PRO_selected
--  31576674 | Full-coded |  31576693 | MGI:PRO_used            correct
--  31576673 | Indexed    |  34693808 | MGI:PRO_selected
--  31576673 | Indexed    |  31576693 | MGI:PRO_used
--  31576669 | Not Routed |  34693808 | MGI:PRO_selected
--  31576672 | Rejected   |  34693808 | MGI:PRO_selected
--  31576670 | Routed     |  34693808 | MGI:PRO_selected

select distinct t2._term_key, t2.term as status, tgterm._term_key, tgterm.term as tgterm
from bib_citation_cache c, bib_refs r,
        bib_workflow_status s, voc_term t2, mgi_user u2,
        bib_workflow_tag tg, voc_term tgterm
where r._refs_key = c._refs_key
and r._refs_key = s._refs_key
and s.isCurrent = 1
and s._status_key = t2._term_key
and s._group_key = 31576666
and s._createdby_key = u2._user_key
and r._refs_key = tg._refs_key
and tg._tag_key in (34693808,31576693)
and tg._tag_key = tgterm._term_key
order by status, tgterm
;

select c._refs_key, c.mgiID, c.jnumid, c.pubmedid,
t2.term as status, tgterm.term as tgterm, r.creation_date,
u2.login as littriageuser, c.short_citation
from bib_citation_cache c, bib_refs r,
        bib_workflow_status s, voc_term t2, mgi_user u2,
        bib_workflow_tag tg, voc_term tgterm
where r._refs_key = c._refs_key
and r._refs_key = s._refs_key
and s.isCurrent = 1
and s._status_key = t2._term_key
and s._group_key = 31576666
and s._createdby_key = u2._user_key
and r._refs_key = tg._refs_key
and tg._tag_key in (34693808,31576693)
and tg._tag_key = tgterm._term_key
order by status, tgterm, c.short_citation
;

--insert into BIB_Workflow_Status
--select nextval('bib_workflow_status_seq'), r._refs_key, 
--      (select _term_key from voc_term where _vocab_key = 127 and abbreviation = 'PRO'), s._Status_key, 1, 1001, 1001, now(), now()
--from bib_refs r, bib_workflow_status s, bib_workflow_tag tg
--where r._refs_key = s._refs_key
--and s.isCurrent = 1
--and s._group_key = 31576666
--and r._refs_key = tg._refs_key
--and tg._tag_key in (34693808,31576693)
--;

EOSQL

date |tee -a $LOG

