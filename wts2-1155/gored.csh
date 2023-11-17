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

-- ND exists and non-ND exists
select distinct a.accid, m.symbol
from voc_annot va, mrk_marker m, acc_accession a
where va._annottype_key = 1000
and va._term_key not in (120, 6113, 1098)
and va._object_key = m._marker_key
and va._object_key = a._object_key
and a._mgitype_key = 2
and a.preferred = 1
and a.prefixpart = 'MGI:'

and exists (select 1 from voc_annot va2
        where va2._annottype_key = 1000
        and va._object_key = va2._object_key
        and va2._term_key in (120, 6113, 1098)
        )
order by m.symbol
;

EOSQL

date |tee -a $LOG

