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
 
${PG_MGD_DBSCHEMADIR}/table/BIB_Workflow_Relevance_truncate.object | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/autosequence/BIB_Workflow_Relevance_drop.object | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/autosequence/BIB_Workflow_Relevance_create.object | tee -a $LOG

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG

-- (0)
-- if isDiscard = 1
--      then _relevance_key = 70594666 (discard)
select distinct m._Refs_key
into temp table toadd0
from BIB_Refs_old m
where m.isDiscard = 1
and not exists (select 1 from bib_workflow_relevance r where m._refs_key = r._refs_key) 
;
select m._Refs_key, a.accID
from toadd0 m, ACC_Accession a
where m._Refs_key = a._object_key
and a._mgitype_key = 1
and a.prefixpart = 'MGI:'
limit 200
;
insert into BIB_Workflow_Relevance
select nextval('bib_workflow_relevance_seq'), _Refs_key, 70594666, 1, null, '6-0-17-1', 1001, 1001, now(), now()
from toadd0
;

-- (1)
-- if isDiscard = 0 
-- if _referencetype_key != 31576687 (Peer Reviewed Article)
-- if reference does not already exist in bib_workflow_relevance
--      then _relevance_key = 70594667 (keep)
select distinct m._Refs_key
into temp table toadd1
from BIB_Refs_old m
where m.isDiscard = 0
and m._referencetype_key != 31576687
and not exists (select 1 from bib_workflow_relevance r where m._refs_key = r._refs_key) 
;
select m._Refs_key, a.accID
from toadd1 m, ACC_Accession a
where m._Refs_key = a._object_key
and a._mgitype_key = 1
and a.prefixpart = 'MGI:'
limit 200
;
insert into BIB_Workflow_Relevance
select nextval('bib_workflow_relevance_seq'), _Refs_key, 70594667, 1, null, '6-0-17-1', 1001, 1001, now(), now()
from toadd1
;

-- (2)
-- if isDiscard = 0 
-- if _referencetype_key = 31576687 (Peer Reviewed Article)
-- if reference does not already exist in bib_workflow_relevance
-- if workflow status is: Chosen, Indexed, Full Coded for ANY group
-- exclude created by = pm2geneload
--      then _relevance_key = 70594667 (keep)
select distinct m._refs_key
into temp table toadd2
from BIB_Refs_old m, bib_workflow_status s
where m.isDiscard = 0
and m._referencetype_key = 31576687
and m._createdby_key != 1571
and m._refs_key = s._refs_key
and s.isCurrent = 1
and s._Status_key in (31576671, 31576673, 31576674)
and not exists (select 1 from bib_workflow_relevance r where m._refs_key = r._refs_key) 
;
select m._Refs_key, a.accID
from toadd2 m, ACC_Accession a
where m._Refs_key = a._object_key
and a._mgitype_key = 1
and a.prefixpart = 'MGI:'
limit 200
;
insert into BIB_Workflow_Relevance
select nextval('bib_workflow_relevance_seq'), _Refs_key, 70594667, 1, null, '6-0-17-1', 1001, 1001, now(), now()
from toadd2
;

-- (3)
--
-- if isDiscard = 0 
-- if reference does not already exist in bib_workflow_relevance
-- if _referencetype_key = 31576687 (Peer Reviewed Article)
-- if workflow status is: Rejected for AP, GXD, GO
-- if workflow status is: Rejected or Not Routed for QTL
--
-- AND
--      worlflow status is: Rejected for Tumor 
--      OR 
--      tag = Tumor:NotSelected (32970313)
--
-- AND
--      *data_tag set
--      AP:DiseaseReview AP:NewTransgene AP:strains 
==      MGI:mapping MGI:markers MGI:nomen_selected MGI:PRO_selected MGI:PRO_used MGI:probe
--
--      OR
-- 
--      **mgi_data type set
--      markers, alleles , probes, strains, sequences, antibodies
--
-- then _relevance_key = 70594666 (discard)
--
select distinct m._refs_key
into temp table toadd3
from BIB_Refs_old m
where m.isDiscard = 0
and m._referencetype_key = 31576687
and exists (select 1 from bib_workflow_status s
        where m._refs_key = s._refs_key and s.isCurrent = 1
        and s._group_key in (31576664) and s._status_key in (31576672)
        )
and exists (select 1 from bib_workflow_status s
        where m._refs_key = s._refs_key and s.isCurrent = 1
        and s._group_key in (31576665) and s._status_key in (31576672)
        )
and exists (select 1 from bib_workflow_status s
        where m._refs_key = s._refs_key and s.isCurrent = 1
        and s._group_key in (31576666) and s._status_key in (31576672)
        )
and exists (select 1 from bib_workflow_status s
        where m._refs_key = s._refs_key and s.isCurrent = 1
        and s._group_key in (31576668) and s._status_key in (31576672, 31576669)
        )
and (
        exists (select 1 from bib_workflow_status s
                where m._refs_key = s._refs_key and s.isCurrent = 1
                and s._group_key in (31576667) and s._status_key in (31576672)
                )
        or exists (select 1 from bib_workflow_tag s
                where m._refs_key = s._refs_key and s._tag_key in (3297031)
                )
)
and (
        exists (select 1 from bib_workflow_tag wt, voc_term t
                where m._refs_key = wt._refs_key
                and wt._tag_key = t._term_key
                and t.term in (
                'AP:DiseaseReview',
                'AP:NewTransgene',
                'AP:strains',
                'MGI:mapping',
                'MGI:markers',
                'MGI:nomen_selected',
                'MGI:PRO_selected',
                'MGI:PRO_used',
                'MGI:probe'
                )
        )
        or ( 
                exists (select 1 from mrk_reference t where m._refs_key = t._refs_key)
                or exists (select 1 from prb_reference t where m._refs_key = t._refs_key)
                or exists (select 1 from mgi_reference_assoc t where m._refs_key = t._refs_key and t._mgitype_key = 11)
                or exists (select 1 from mgi_reference_assoc t where m._refs_key = t._refs_key and t._mgitype_key = 10)
                or exists (select 1 from mgi_reference_assoc t where m._refs_key = t._refs_key and t._mgitype_key = 19)
                or exists (select 1 from mgi_reference_assoc t where m._refs_key = t._refs_key and t._mgitype_key = 6)
        )
)
and not exists (select 1 from bib_workflow_relevance r where m._refs_key = r._refs_key) 
;

select m._Refs_key, a.accID
from todd3 m, ACC_Accession a
where m._Refs_key = a._object_key
and a._mgitype_key = 1
and a.prefixpart = 'MGI:'
limit 200
;
insert into BIB_Workflow_Relevance
select nextval('bib_workflow_relevance_seq'), _Refs_key, 70594666, 1, null, '6-0-17-1', 1001, 1001, now(), now()
from toadd3
;

-- (4)
-- if _referencetype_key = 31576687 (Peer Reviewed Article)
-- if reference does not already exist in bib_workflow_relevance
-- if workflow status is Routed for any group
--      then _relevance_key = 70594667 (keep)
select distinct m._Refs_key
into temp table toadd4
from BIB_Refs_old m
where m._referencetype_key = 31576687
and exists (select 1 from bib_workflow_status s
        where m._refs_key = s._refs_key and s.isCurrent = 1
        and s._status_key in (31576670)
        )
and not exists (select 1 from bib_workflow_relevance r where m._refs_key = r._refs_key) 
;
select m._Refs_key, a.accID
from toadd4 m, ACC_Accession a
where m._Refs_key = a._object_key
and a._mgitype_key = 1
and a.prefixpart = 'MGI:'
limit 200
;
insert into BIB_Workflow_Relevance
select nextval('bib_workflow_relevance_seq'), _Refs_key, 70594667, 1, null, '6-0-17-1', 1001, 1001, now(), now()
from toadd4
;

-- (5)
-- if anything is left in bib_refs_old that is not in bib_workflow_relevance
--      then _relevance_key = 70594668 (Not Specified)
select distinct m._Refs_key
into temp table toadd5
from BIB_Refs_old m
where not exists (select 1 from bib_workflow_relevance r where m._refs_key = r._refs_key) 
;
select m._Refs_key, a.accID
from toadd5 m, ACC_Accession a
where m._Refs_key = a._object_key
and a._mgitype_key = 1
and a.prefixpart = 'MGI:'
limit 200
;
insert into BIB_Workflow_Relevance
select nextval('bib_workflow_relevance_seq'), _Refs_key, 70594668, 1, null, '6-0-17-1', 1001, 1001, now(), now()
from toadd5
;


-- rebuild cache
select  * from BIB_reloadCache();

--- counts
select count(*) from bib_refs;
select count(*) from bib_citation_cache;
select count(*) from bib_workflow_relevance;
-- discard
select count(*) from bib_workflow_relevance where _relevance_key = 70594666;
-- keep
select count(*) from bib_workflow_relevance where _relevance_key = 70594667;
-- Not Specified
select count(*) from bib_workflow_relevance where _relevance_key = 70594668;

EOSQL

date |tee -a $LOG

