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

select distinct split_part(ve.inferredfrom, ':', 1) as inferredfrom
from voc_annot v, voc_evidence ve
where v._annottype_key = 1000
and v._annot_key = ve._annot_key
and ve.inferredfrom is not null
and ve.inferredfrom like '%:%'
order by inferredfrom
;

EOSQL

date |tee -a $LOG

