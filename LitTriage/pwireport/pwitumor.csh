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

WITH ref_results AS (
select r.mgiID, d.extractedText 
from BIB_Citation_Cache r, BIB_Workflow_Status s, BIB_Workflow_Data d
where r.isDiscard = 0
and r._Refs_key = s._Refs_key
and s.isCurrent = 1
and s._Group_key = 31576667
and s._Status_key = 31576669
and r._Refs_key = d._Refs_key
and not exists (select 1 from BIB_Workflow_Tag tt
    where r._Refs_key = tt._Refs_key
    and tt._Tag_key in (32970313))
)
(
select r.mgiID from ref_results r where lower(r.extractedText) like lower('%tumo%')
union
select r.mgiID from ref_results r where lower(r.extractedText) like lower('%%inoma%')
union
select r.mgiID from ref_results r where lower(r.extractedText) like lower('%adenoma%')
union
select r.mgiID from ref_results r where lower(r.extractedText) like lower('%sarcoma%')
union
select r.mgiID from ref_results r where lower(r.extractedText) like lower('%lymphoma%')
union
select r.mgiID from ref_results r where lower(r.extractedText) like lower('%neoplas%')
union
select r.mgiID from ref_results r where lower(r.extractedText) like lower('%gioma%')
union
select r.mgiID from ref_results r where lower(r.extractedText) like lower('%papilloma%')
union
select r.mgiID from ref_results r where lower(r.extractedText) like lower('%leukemia%')
union
select r.mgiID from ref_results r where lower(r.extractedText) like lower('%leukaemia%')
union
select r.mgiID from ref_results r where lower(r.extractedText) like lower('%ocytoma%')
union
select r.mgiID from ref_results r where lower(r.extractedText) like lower('%thelioma%')
union
select r.mgiID from ref_results r where lower(r.extractedText) like lower('%blastoma%')
union
select r.mgiID from ref_results r where lower(r.extractedText) like lower('%hepatoma%')
union
select r.mgiID from ref_results r where lower(r.extractedText) like lower('%melanoma%')
union
select r.mgiID from ref_results r where lower(r.extractedText) like lower('%lipoma%')
union
select r.mgiID from ref_results r where lower(r.extractedText) like lower('%myoma%')
union
select r.mgiID from ref_results r where lower(r.extractedText) like lower('%acanthoma%')
union
select r.mgiID from ref_results r where lower(r.extractedText) like lower('%fibroma%')
union
select r.mgiID from ref_results r where lower(r.extractedText) like lower('%teratoma%')
union
select r.mgiID from ref_results r where lower(r.extractedText) like lower('%glioma%')
union
select r.mgiID from ref_results r where lower(r.extractedText) like lower('%thymoma%')
)
order by mgiID
;

EOSQL

date | tee -a $LOG
