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

select r.journal, count(r.journal)
from bib_refs r, voc_term t
where r.journal = t.term
and t._vocab_key = 184
and r.year between 2018 and 2022
group by r.journal
order by r.journal
;

EOSQL

date |tee -a $LOG

