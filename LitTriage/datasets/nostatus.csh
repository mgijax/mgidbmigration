#!/bin/csh -f

#
# all Tags should have a Status
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

select r._Refs_key, r.jnumID, r.short_citation
from BIB_Citation_Cache r
where not exists (select 1 from BIB_Workflow_Status s
	where r._Refs_key = s._Refs_key)
;

select count(*) from BIB_Refs;
select count(distinct _Refs_key) from BIB_Workflow_Status ;

select 'A&P', r._Refs_key, r.jnumID, r.short_citation
from BIB_Citation_Cache r
where not exists (select 1 from BIB_Workflow_Status s
	where r._Refs_key = s._Refs_key
	and s._Group_key = 31576664)
;

select 'GXD', r._Refs_key, r.jnumID, r.short_citation
from BIB_Citation_Cache r
where not exists (select 1 from BIB_Workflow_Status s
	where r._Refs_key = s._Refs_key
	and s._Group_key = 31576665)
;

select 'GO', r._Refs_key, r.jnumID, r.short_citation
from BIB_Citation_Cache r
where not exists (select 1 from BIB_Workflow_Status s
	where r._Refs_key = s._Refs_key
	and s._Group_key = 31576666)
;

--select 'Tumor', r._Refs_key, r.jnumID, r.short_citation
select count(r._Refs_key)
from BIB_Citation_Cache r
where not exists (select 1 from BIB_Workflow_Status s
	where r._Refs_key = s._Refs_key
	and s._Group_key = 31576667)
;

select 'QTL', r._Refs_key, r.jnumID, r.short_citation
from BIB_Citation_Cache r
where not exists (select 1 from BIB_Workflow_Status s
	where r._Refs_key = s._Refs_key
	and s._Group_key = 31576668)
;

EOSQL

