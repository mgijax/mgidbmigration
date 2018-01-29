#!/bin/csh -f

#
# test triggers
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

select r._Refs_key, r.jnumID, r.mgiID, r.pubmedID, r.journal, t.term
from BIB_Citation_Cache r, BIB_Workflow_Status s, VOC_Term t
where r._Refs_key = s._Refs_key
and s._Status_key in (31576669)
and s._Group_key = 31576665
and s._Status_key = t._Term_key
limit 5
;

select r._Refs_key, r.jnumID, r.mgiID, r.pubmedID, r.journal, t.term
from BIB_Citation_Cache r, BIB_Workflow_Status s, VOC_Term t
where r._Refs_key = s._Refs_key
and s._Status_key in (31576672)
and s._Group_key = 31576665
and s._Status_key = t._Term_key
limit 5
;

-- new status
select r._Refs_key, r.jnumID, r.mgiID, r.pubmedID, r.journal, t.term
from BIB_Citation_Cache r, BIB_Workflow_Status s, VOC_Term t
where r._Refs_key = s._Refs_key
and s._Status_key in (31576673)
and s._Group_key = 31576665
and s._Status_key = t._Term_key
and r.pubmedID in (
'28459441',
'28530662',
'28315443',
'28533339',
'28341809',
'28280111',
'28428068',
'28432218',
'28420711',
'28473526',
'28535209',
'28580661',
'28068322',
'26312487',
'28552778'
)
;

-- new tags
select r._Refs_key, r.jnumID, r.mgiID, r.pubmedID, r.journal, t.term
from BIB_Citation_Cache r, BIB_Workflow_Status s, VOC_Term t
where r._Refs_key = s._Refs_key
and s._Status_key in (31576673)
and s._Group_key = 31576665
and s._Status_key = t._Term_key
and r.pubmedID in (
'25377076',
'28283570',
'28286126',
'28366718',
'28522693',
'28270506',
'28300657',
'28359951',
'28483947',
'28571676',
'28288124',
'28314773',
'28356294',
'28376230',
'28728543',
'28274939',
'28381645',
'28529313',
'28556366',
'28624616',
'25185988',
'28254410',
'28442366',
'28606934',
'28641136'
)
;

-- add GXD Assay for Not Routed -> Chosen
-- add GXD Assay for Rejected -> Chosen
-- add GXD Index for Not Routed -> Indexed
-- add GXD Index for Rejected -> Indexed

-- add GO annotation for Not Routed -> Indexed

-- add GO annotation for Rejected -> Indexed

EOSQL

