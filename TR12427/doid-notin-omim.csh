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
\echo '-- in DO, not in OMIM'
\echo '-- should be empty'
\echo ''

select a1.accID, oo.term
from ACC_Accession a1, VOC_Term oo
where a1._MGIType_key = 13
and a1.prefixPart = 'OMIM:'
and a1._Object_key = oo._Term_key
and oo._Vocab_key = 125
and not exists (select 1 from ACC_Accession a2, VOC_Term oo2
	where a1.accID = a2.accID
	and a2._LogicalDB_key = 15
	and a2._MGIType_key = 13
	and a2._Object_key = oo2._Term_key
	and oo2._Vocab_key = 44
	)
order by a1.accID
;

EOSQL

date |tee -a $LOG

