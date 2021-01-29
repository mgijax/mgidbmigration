#!/bin/csh -f

#
# create new group = PRO
# create new bib_workflow_status/isCurrent = 1 for group/PRO
# delete obsolete MGI:PRO tags from bib_workflow_tag
# no qc report changes
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

-- add new group 'PRO'
--insert into VOC_Term values(nextval('voc_term_seq'), 127, 'PRO', 'PRO', null, 1, 0, 1001, 1001, now(), now());

select c._refs_key, c.mgiID, c.jnumid, c.pubmedid,
tgterm.term as tgterm, c.short_citation
from bib_citation_cache c, bib_workflow_tag tg, voc_term tgterm
where c._refs_key = tg._refs_key
and tg._tag_key in (34693808,31576693,51604409)
and tg._tag_key = tgterm._term_key
order by tgterm, c.short_citation
;

--  MGI:PRO_used (31576693) -> Full-coded (31576674)
insert into BIB_Workflow_Status
select nextval('bib_workflow_status_seq'), r._refs_key, 
      (select _term_key from voc_term where _vocab_key = 127 and abbreviation = 'PRO'), 31576674, 1, 1001, 1001, now(), now()
from bib_refs r, bib_workflow_status s, bib_workflow_tag tg
where r._refs_key = s._refs_key
and s.isCurrent = 1
and s._group_key = 31576666
and r._refs_key = tg._refs_key
and tg._tag_key in (31576693)
and not exists (select 1 from bib_workflow_status ss 
        where r._refs_key = ss._refs_key and ss._group_key = (select _term_key from voc_term where _vocab_key = 127 and abbreviation = 'PRO'))
;

--  GO:hjd_PRO_in_progress (51604409) -> Full-coded (31576674)
insert into BIB_Workflow_Status
select nextval('bib_workflow_status_seq'), r._refs_key, 
      (select _term_key from voc_term where _vocab_key = 127 and abbreviation = 'PRO'), 31576674, 1, 1001, 1001, now(), now()
from bib_refs r, bib_workflow_status s, bib_workflow_tag tg
where r._refs_key = s._refs_key
and s.isCurrent = 1
and s._group_key = 31576666
and r._refs_key = tg._refs_key
and tg._tag_key in (51604409)
and not exists (select 1 from bib_workflow_status ss 
        where r._refs_key = ss._refs_key and ss._group_key = (select _term_key from voc_term where _vocab_key = 127 and abbreviation = 'PRO'))
;

--  MGI:PRO_selected (34693808) -> Chosen (31576671)
insert into BIB_Workflow_Status
select nextval('bib_workflow_status_seq'), r._refs_key, 
      (select _term_key from voc_term where _vocab_key = 127 and abbreviation = 'PRO'), 31576671, 1, 1001, 1001, now(), now()
from bib_refs r, bib_workflow_status s, bib_workflow_tag tg
where r._refs_key = s._refs_key
and s.isCurrent = 1
and s._group_key = 31576666
and r._refs_key = tg._refs_key
and tg._tag_key in (34693808)
and not exists (select 1 from bib_workflow_status ss 
        where r._refs_key = ss._refs_key and ss._group_key = (select _term_key from voc_term where _vocab_key = 127 and abbreviation = 'PRO'))
;

-- rest = 'Not Routed'/31576669
insert into BIB_Workflow_Status
select nextval('bib_workflow_status_seq'), r._refs_key, 
      (select _term_key from voc_term where _vocab_key = 127 and abbreviation = 'PRO'), 31576669, 1, 1001, 1001, now(), now()
from bib_refs r, bib_workflow_status s, bib_workflow_tag tg
where r._refs_key = s._refs_key
and s.isCurrent = 1
and s._group_key = 31576666
and r._refs_key = tg._refs_key
and tg._tag_key not in (34693808,31576669,51604409)
and not exists (select 1 from bib_workflow_status ss 
        where r._refs_key = ss._refs_key and ss._group_key = (select _term_key from voc_term where _vocab_key = 127 and abbreviation = 'PRO'))
;

--select c._refs_key, c.mgiID, c.jnumid, c.pubmedid,
--tg.term as tgterm, ts.term as tsterm, c.short_citation
--from bib_citation_cache c, bib_workflow_tag g, voc_term tg, bib_workflow_status s, voc_term ts
--where c._refs_key = g._refs_key
--and g._tag_key in (34693808,31576693,51604409)
--and g._tag_key = tg._term_key
--and c._refs_key = s._refs_key
--and s.isCurrent = 1
--and s._group_key = 75601866
--and s._status_key = ts._term_key
--order by tgterm, c.short_citation
--;

-- delete MGI:PRO tags
--delete from voc_term where _term_key in (34693808, 31576693);

EOSQL

date |tee -a $LOG

