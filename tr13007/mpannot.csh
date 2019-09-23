#!/bin/csh -f

#
# Find MP annot that have same _object_key/_term_key but different _annot_key
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

./mpannot.py | tee -a $LOG

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG

WITH mpAnnot AS (
select _object_key, _term_key  
from voc_annot 
where _annottype_key = 1002 
group by _object_key, _term_key having count(*) > 1 
)
select a._annot_key, a._object_key, a._term_key, e._annotevidence_key, aa.accID
from voc_annot a, mpAnnot m, voc_evidence e, acc_accession aa
where a._annottype_key = 1002
and a._object_key = m._object_key
and a._term_key = m._term_key
and a._annot_key = e._annot_key
and a._object_key = aa._object_key
and aa._mgitype_key = 12
and aa._logicaldb_key = 1 
order by a._object_key, a._term_key, a._annot_key
;

EOSQL

date |tee -a $LOG

