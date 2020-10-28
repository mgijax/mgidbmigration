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

-- insert new BIB_Refs table (isDiscard removed)
insert into BIB_Refs
select m._Refs_key, m._ReferenceType_key, m.authors, m._primary, m.title,
m.journal, m.vol, m.issue, m.date, m.year, m.pgs, m.abstract, m.isReviewArticle,
m._CreatedBy_key, m._ModifiedBy_key, m.creation_date, m.modification_date
from BIB_Refs_old m
;

-- (0)
-- if isDiscard = 1
--      then _relevance_key = 70594666 (discard)
insert into BIB_Workflow_Relevance
select nextval('bib_workflow_relevance_seq'), m._Refs_key, 70594666, 1, null, '6-0-17-1',
m._CreatedBy_key, m._ModifiedBy_key, m.creation_date, m.modification_date
from BIB_Refs_old m
where m.isDiscard = 1
and not exists (select 1 from bib_workflow_relevance r where m._refs_key = r._refs_key) 
;

-- (1)
-- if isDiscard = 0 and _referencetype_key != 31576687 (Peer Reviewed Article)
--      then _relevance_key = 70594667 (keep)
insert into BIB_Workflow_Relevance
select nextval('bib_workflow_relevance_seq'), m._Refs_key, 70594667, 1, null, '6-0-17-1',
m._CreatedBy_key, m._ModifiedBy_key, m.creation_date, m.modification_date
from BIB_Refs_old m
where m.isDiscard = 0
and m._referencetype_key != 31576687
and not exists (select 1 from bib_workflow_relevance r where m._refs_key = r._refs_key) 
;

-- (2)
-- if workflow status is: Chosen, Indexed, Full Coded for ANY group
-- if isDiscard = 0 
-- exclude created by = pm2geneload
--      then _relevance_key = 70594667 (keep)
select distinct m.*
into #toadd2
from BIB_Refs_old m, bib_workflow_status s
where m.isDiscard = 0
and m._createdby_key != 1571
and m._refs_key = s._refs_key
and s.isCurrent = 1
and s._Status_key in (31576671, 31576673, 31576674)
and not exists (select 1 from bib_workflow_relevance r where m._refs_key = r._refs_key) 
;

insert into BIB_Workflow_Relevance
select nextval('bib_workflow_relevance_seq'), _Refs_key, 70594667, 1, null, '6-0-17-1',
_CreatedBy_key, _ModifiedBy_key, creation_date, modification_date
from #toadd2
;

-- (3)
-- if _refs_key does not exist in bib_workflow_relevance
-- if isDiscard = 0 
-- if workflow status is: Rejected for AP, GXD, GO
-- if workflow status is: Rejected or Not Routed for QTL
-- if worlflow status is: Rejected for Tumor or tag = Tumor:NotSelected (32970313)
--      then _relevance_key = 70594666 (discard)
select distinct m.*
into #toadd3
from BIB_Refs_old m
where m.isDiscard = 0
and exists (select 1 from bib_workflow_status s
        where m._refs_key = s._refs_key and s.isCurrent = 1
        and s._group_key in (31576664, 31576665, 31576666) and r._status_key in (31576672))
        )
and exists (select 1 from bib_workflow_status s
        where m._refs_key = s._refs_key and s.isCurrent = 1
        and s._group_key in (31576668) and r._status_key in (31576672, 31576669)
        )
and exists (
        (
        select 1 from bib_workflow_status s
        where m._refs_key = s._refs_key and s.isCurrent = 1
        and s._group_key in (31576667) and r._status_key in (31576672)
        )
        or
        (
        select 1 from bib_workflow_tag s
        where m._refs_key = s._refs_key and s.isCurrent = 1
        and s._group_key in (31576667) and r._tag_key in (3297031)
        )
and not exists (select 1 from bib_workflow_relevance r where m._refs_key = r._refs_key) 
;

insert into BIB_Workflow_Relevance
select nextval('bib_workflow_relevance_seq'), _Refs_key, 70594666, 1, null, '6-0-17-1',
_CreatedBy_key, _ModifiedBy_key, creation_date, modification_date
from #toadd3
;

-- (4)
--if workflow status is Routed for some group?
--      then _relevance_key = 70594667 (keep)
--insert into BIB_Workflow_Relevance
--select nextval('bib_workflow_relevance_seq'), m._Refs_key, 70594668, 1, null, '6-0-17-1',
--m._CreatedBy_key, m._ModifiedBy_key, m.creation_date, m.modification_date
--from BIB_Refs_old m
--where not exists (select 1 from bib_workflow_relevance r where m._refs_key = r._refs_key) 
--;

-- (5)
-- if anything is left in bib_refs_old that is not in bib_workflow_relevance
--      then _relevance_key = 70594668 (Not Specified)
insert into BIB_Workflow_Relevance
select nextval('bib_workflow_relevance_seq'), m._Refs_key, 70594668, 1, null, '6-0-17-1',
m._CreatedBy_key, m._ModifiedBy_key, m.creation_date, m.modification_date
from BIB_Refs_old m
where not exists (select 1 from bib_workflow_relevance r where m._refs_key = r._refs_key) 
;

-- discard
select count(*) from bib_workflow_relevance where _relevance_key = 70594666;
-- keep
select count(*) from bib_workflow_relevance where _relevance_key = 70594667;
-- Not Specified
select count(*) from bib_workflow_relevance where _relevance_key = 70594668;

EOSQL

date |tee -a $LOG

