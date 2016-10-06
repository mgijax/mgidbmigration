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

\echo ''
\echo '--DO vocabulary
\echo ''

--select a.accID, t.term, t.isObsolete, tt.note
--     	LEFT OUTER JOIN VOC_Text tt on (t._Term_key = tt._Term_key)
select a.accID, t.term, t.isObsolete
from ACc_Accession a, 
     VOC_Term t 
where t._Vocab_key = 125
and t._Term_key = a._Object_key
and a._MGIType_key = 13
and a._LogicalDB_key = 191
and a.preferred = 1
order by t.isObsolete, t.term
;

EOSQL

date |tee -a $LOG

