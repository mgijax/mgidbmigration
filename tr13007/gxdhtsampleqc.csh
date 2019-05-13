#!/bin/csh -f

#
# Template
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

select distinct r._Relevance_key, t.term, t._vocab_key
from gxd_htsample r, voc_term t
where r._relevance_key = t._term_key
;

--select distinct age 
--from gxd_htsample 
--order by age;

select distinct age, agemin, agemax 
from gxd_htsample 
order by age;

select e.*, s.age, s.agemin, s.agemax
from GXD_HTExperiment e, GXD_HTSample s
where e._Experiment_key = s._Experiment_key
and s.agemin is null
;

select distinct age, agemin, agemax 
from gxd_specimen
order by age;

select distinct age, agemin, agemax 
from gxd_gellane
order by age;

EOSQL

date |tee -a $LOG

