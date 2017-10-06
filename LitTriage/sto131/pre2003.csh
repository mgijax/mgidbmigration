#!/bin/csh

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

select r.*
into temporary table pre2002
from MRK_Reference m, BIB_All_View r
where m._Refs_key = r._Refs_key
and r.journal not in ('GenBank Submission', 'Mouse News Lett') 
and r.creation_date < '03/13/2002' 
and not exists (select 1 from BIB_DataSet_Assoc ba
          where r._Refs_key = ba._Refs_key and 
          ba._DataSet_key = 1005 and 
          ba.isNeverUsed = 1)
and exists (select 1 from BIB_DataSet_Assoc ba
          where r._Refs_key = ba._Refs_key and 
          --ba._DataSet_key in (1002, 1004))
          ba._DataSet_key in (1002))
and exists (select 1 from MGI_Reference_Allele_View aa where r._Refs_key = aa._Refs_key)
;

create index idx_refs_key on pre2002(_Refs_key);

select count(*) from pre2002
;

select count(r.*)
from pre2002 r
where exists (select 1 from BIB_Workflow_Status ws, VOC_Term wst1, VOC_Term wst2
        where r._Refs_key = ws._Refs_Key
        and ws._Group_key = wst1._Term_key
        and wst1.abbreviation in ('GO')
        and ws._Status_key = wst2._Term_key
        and wst2.term in ('Rejected')
        and ws.isCurrent = 1 
        )
;

EOSQL
