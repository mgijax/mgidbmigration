#!/bin/csh -f

#
# create new group = GXDHT
# create new bib_workflow_status/isCurrent = 1 for group/GXDHT
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

-- add new group 'GXDHT'
--insert into voc_term values(114000000, 127, 'GXD HT Index', 'GXDHT' , null, 7, 0, 1001, 1001, now(), now());

delete from BIB_Workflow_Status where _group_key = 114000000;

-- set GXDHT status to: Not Routed (31576669)
insert into BIB_Workflow_Status
select nextval('bib_workflow_status_seq'), r._refs_key, 114000000, 31576669, 1, 1001, 1001, now(), now()
from bib_refs r
;

select count(s.*)
from bib_workflow_status s
where s.isCurrent = 1
and s._group_key = 114000000
and s._status_key = 31576669
;

select count(*) from bib_refs;

EOSQL

date |tee -a $LOG

