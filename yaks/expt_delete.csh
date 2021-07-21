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

echo "saving notes for those experiments that will be deleted" | tee -a $LOG 
${PYTHON} "${DBUTILS}/mgidbmigration/yaks/expt_delete_notes.py"

date | tee -a $LOG
echo "running deletes" | tee -a $LOG
cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG

-- get all experiments where
-- curation state 'Not Applicable' or 'Not Done'
-- evaluation state 'Not Evaluated' or 'No'
select h.*
into temporary table del 
from gxd_htexperiment h
where h._curationstate_key in (20475420, 20475422)
or h._evaluationstate_key in (20225941, 20225943)
;

create index idx1 on del(_experiment_key)
;

-- narrow down to the set of GEO experiments to delete
select a.accid, d.*
into temporary table toDelete
from del d, acc_accession a
where a._mgitype_key = 42
and a._logicaldb_key = 190 -- GEO
and a._object_key = d._experiment_key
;

create index idx2 on toDelete(_experiment_key)
;

select * from toDelete;
;

delete from gxd_htexperiment g
using toDelete d
where d._experiment_key = g._experiment_key
;

EOSQL

date | tee -a $LOG
