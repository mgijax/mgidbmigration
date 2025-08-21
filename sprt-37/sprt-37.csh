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

select * from mrk_status
;

select distinct m._marker_key, m._marker_status_key, m.symbol
from mrk_marker m, gxd_htsample_rnaseq rna
where rna._marker_key = m._marker_key
and m._marker_status_key = 2
;

EOSQL

date |tee -a $LOG

