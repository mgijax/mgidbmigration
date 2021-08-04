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

WITH results AS (
select _object_key, _term_key from voc_annot 
where _annottype_key = 1009 
group by _object_key, _term_key having count(*) > 1
)
select v.*
from VOC_Annot v, results r
where v._annottype_key = 1009
and v._object_key = r._object_key
and v._term_key = r._term_key
order by r._object_key, r._term_key
;

EOSQL

date |tee -a $LOG

