#!/bin/csh -f

#
# remove experiment variables that are now in gxd_htsample._rnaseqtype_key.
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

delete from gxd_htexperimentvariable where _term_key in (114732569, 114732570, 114732571);
delete from voc_term where _term_key in (114732569, 114732570, 114732571);

select count(e.*) from gxd_htexperiment e
where not exists (select 1 from gxd_htexperimentvariable v where e._experiment_key = v._experiment_key)
;

EOSQL

$PYTHON removeVariables.py | tee -a $LOG

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG
select count(e.*) from gxd_htexperiment e
where not exists (select 1 from gxd_htexperimentvariable v where e._experiment_key = v._experiment_key)
;
EOSQL

date |tee -a $LOG

