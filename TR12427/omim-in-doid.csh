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

-- OMIM id is in OMIM original vocabulary *and* in DOI
select a1.accID, a2.accID, o1.term
from ACC_Accession a1, VOC_Term o1, ACC_Accession a2, VOC_Term o2
where a1._MGIType_key = 13
and a1._Object_key = o1._Term_key
and o1._Vocab_key = 44
and a1.accID = a2.accID
and a2._LogicalDB_key = 15
and a2._MGIType_key = 13
and a2._Object_key = o2._Term_key
and o2._Vocab_key = 125
;

EOSQL

date |tee -a $LOG

