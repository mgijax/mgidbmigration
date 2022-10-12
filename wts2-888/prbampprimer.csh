#!/bin/csh -f

if ( ${?MGICONFIG} == 0 ) then
        setenv 'MGICONFIG /usr/local/mgi/live/mgiconfig
endif

source ${MGICONFIG}/master.config.csh

cd `dirname $0`

setenv LOG $0.log
rm -rf $LOG
touch $LOG
 
date | tee -a $LOG
 
cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG

select p.name, m1.symbol, amp.name, m2.symbol
from prb_probe p, prb_probe amp, prb_marker pm, prb_marker amp_pm, mrk_marker m1, mrk_marker m2
where p._probe_key = pm._probe_key
and pm._marker_key = m1._marker_key
and p.ampPrimer = amp._probe_key
and amp._probe_key = amp_pm._probe_key
and amp_pm._marker_key = m2._marker_key
and m1.symbol != m2.symbol
order by p.name
;

EOSQL

date |tee -a $LOG

