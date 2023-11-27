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

select distinct ve.inferredfrom
from voc_annot v, voc_evidence ve
where v._annottype_key = 1000
and v._annot_key = ve._annot_key
and ve.inferredfrom is not null
order by ve.inferredfrom
;

EOSQL

rm -rf newinferredfrom
#cut -f1 -d":" newinferredfrom.csh.log | sort | uniq > newinferredfrom

date |tee -a $LOG

